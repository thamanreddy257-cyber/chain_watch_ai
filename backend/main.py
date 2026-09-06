import json
from datetime import datetime
from pathlib import Path
from typing import Optional

import pandas as pd
from fastapi import FastAPI, UploadFile, File, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

from db import init_db, db_session, DB_PATH
from data_gen import ensure_dataset, DEFAULT_OUT
from ingest import ingest_csv
from graph_builder import build_graph_from_db, graph_to_json
from ml_detect import run_detection

app = FastAPI(title="ChainWatch AI — Offline Bitcoin Traffic Correlation API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def _startup():
    init_db()
    ensure_dataset(DEFAULT_OUT, total=500)
    # Auto-run the full pipeline once at boot so the dashboard has real data
    # immediately; the "Run Detection Pipeline" button re-runs it live on demand.
    with db_session() as conn:
        has_data = conn.execute("SELECT COUNT(*) AS c FROM transactions").fetchone()["c"]
    if not has_data:
        ingest_csv(DEFAULT_OUT)
        build_graph_from_db()
        run_detection()


@app.get("/api/health")
def health():
    return {"status": "ok", "time": datetime.utcnow().isoformat()}


@app.post("/api/ingest")
async def api_ingest(file: Optional[UploadFile] = File(None)):
    if file is not None:
        tmp_path = Path(__file__).parent / "data" / "uploaded.csv"
        tmp_path.parent.mkdir(parents=True, exist_ok=True)
        content = await file.read()
        tmp_path.write_bytes(content)
        target = tmp_path
    else:
        target = ensure_dataset(DEFAULT_OUT, total=500)

    try:
        summary = ingest_csv(target)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return summary


@app.post("/api/graph")
def api_build_graph():
    with db_session() as conn:
        has_data = conn.execute("SELECT COUNT(*) AS c FROM transactions").fetchone()["c"]
    if not has_data:
        raise HTTPException(status_code=400, detail="No transactions ingested yet. Call /api/ingest first.")
    return build_graph_from_db()


@app.get("/api/graph")
def api_get_graph(limit: int = Query(400, ge=10, le=2000)):
    return graph_to_json(limit_nodes=limit)


@app.post("/api/detect")
def api_detect():
    with db_session() as conn:
        has_features = conn.execute("SELECT COUNT(*) AS c FROM wallet_features").fetchone()["c"]
    if not has_features:
        raise HTTPException(status_code=400, detail="No graph built yet. Call /api/graph first.")
    return run_detection()


@app.get("/api/alerts")
def api_alerts(
    entity_type: Optional[str] = Query(None, pattern="^(wallet|tx)$"),
    risk_tier: Optional[str] = Query(None, pattern="^(high|medium|low)$"),
    limit: int = Query(200, ge=1, le=2000),
):
    query = "SELECT * FROM alerts WHERE 1=1"
    params = []
    if entity_type:
        query += " AND entity_type = ?"
        params.append(entity_type)
    if risk_tier == "high":
        query += " AND risk_score >= 75"
    elif risk_tier == "medium":
        query += " AND risk_score >= 45 AND risk_score < 75"
    elif risk_tier == "low":
        query += " AND risk_score < 45"
    query += " ORDER BY risk_score DESC LIMIT ?"
    params.append(limit)

    with db_session() as conn:
        rows = [dict(r) for r in conn.execute(query, params).fetchall()]
    for r in rows:
        r["top_reasons"] = json.loads(r["top_reasons"]) if r["top_reasons"] else []
    return {"count": len(rows), "alerts": rows}


@app.get("/api/stats")
def api_stats():
    with db_session() as conn:
        tx_count = conn.execute("SELECT COUNT(*) AS c FROM transactions").fetchone()["c"]
        wallet_count = conn.execute("SELECT COUNT(*) AS c FROM wallet_features").fetchone()["c"]
        ip_count = conn.execute("SELECT COUNT(DISTINCT src_ip) AS c FROM network_events").fetchone()["c"]
        asn_count = conn.execute("SELECT COUNT(DISTINCT asn) AS c FROM network_events").fetchone()["c"]
        high_risk = conn.execute("SELECT COUNT(*) AS c FROM alerts WHERE risk_score >= 75").fetchone()["c"]
        med_risk = conn.execute("SELECT COUNT(*) AS c FROM alerts WHERE risk_score >= 45 AND risk_score < 75").fetchone()["c"]
        low_risk = conn.execute("SELECT COUNT(*) AS c FROM alerts WHERE risk_score < 45").fetchone()["c"]
        communities = conn.execute("SELECT COUNT(DISTINCT community_id) AS c FROM wallet_features WHERE community_id >= 0").fetchone()["c"]
        timeline_rows = conn.execute(
            """SELECT substr(timestamp, 1, 13) AS bucket, COUNT(*) AS c
               FROM transactions GROUP BY bucket ORDER BY bucket"""
        ).fetchall()

    return {
        "transactions_ingested": tx_count,
        "entities_clustered": wallet_count,
        "high_risk_alerts": high_risk,
        "distinct_ips": ip_count,
        "distinct_asns": asn_count,
        "communities_detected": communities,
        "risk_distribution": {"high": high_risk, "medium": med_risk, "low": low_risk},
        "volume_timeline": [{"bucket": r["bucket"], "count": r["c"]} for r in timeline_rows],
    }


@app.get("/api/entity/{entity_id}")
def api_entity(entity_id: str):
    with db_session() as conn:
        wf = conn.execute("SELECT * FROM wallet_features WHERE address = ?", (entity_id,)).fetchone()
        alert = conn.execute(
            "SELECT * FROM alerts WHERE entity_id = ? ORDER BY risk_score DESC LIMIT 1", (entity_id,)
        ).fetchone()

        tx_as_input = conn.execute(
            "SELECT * FROM transactions WHERE input_addresses LIKE ?", (f'%"{entity_id}"%',)
        ).fetchall()
        tx_as_output = conn.execute(
            "SELECT * FROM transactions WHERE output_addresses LIKE ?", (f'%"{entity_id}"%',)
        ).fetchall()
        score_history = conn.execute(
            "SELECT * FROM tx_scores WHERE primary_wallet = ? ORDER BY timestamp", (entity_id,)
        ).fetchall()

        # also support looking up by IP address
        net_events = conn.execute(
            "SELECT * FROM network_events WHERE src_ip = ? ORDER BY timestamp DESC LIMIT 100", (entity_id,)
        ).fetchall()

    all_tx = {row["txid"]: dict(row) for row in list(tx_as_input) + list(tx_as_output)}
    for tx in all_tx.values():
        tx["input_addresses"] = json.loads(tx["input_addresses"])
        tx["output_addresses"] = json.loads(tx["output_addresses"])
        tx["input_amounts"] = json.loads(tx["input_amounts"])
        tx["output_amounts"] = json.loads(tx["output_amounts"])

    distinct_ips = sorted({tx["src_ip"] for tx in all_tx.values()})
    distinct_ports = sorted({tx["src_port"] for tx in all_tx.values()})
    counterparties = set()
    for tx in all_tx.values():
        counterparties.update(tx["input_addresses"])
        counterparties.update(tx["output_addresses"])
    counterparties.discard(entity_id)

    if not all_tx and not net_events:
        raise HTTPException(status_code=404, detail="Entity not found in ingested data")

    return {
        "entity_id": entity_id,
        "entity_type": "wallet" if wf or all_tx else "ip",
        "graph_features": dict(wf) if wf else None,
        "alert": (
            {**dict(alert), "top_reasons": json.loads(alert["top_reasons"])} if alert else None
        ),
        "transactions": sorted(all_tx.values(), key=lambda t: t["timestamp"]),
        "associated_ips": distinct_ips,
        "associated_ports": distinct_ports,
        "counterparties": sorted(counterparties)[:50],
        "risk_score_history": [
            {"txid": r["txid"], "timestamp": r["timestamp"], "risk_score": r["risk_score"]}
            for r in score_history
        ],
        "network_events": [dict(r) for r in net_events],
    }


@app.get("/api/entity-search")
def api_entity_search(q: str = Query(..., min_length=2)):
    like = f"%{q}%"
    with db_session() as conn:
        wallets = conn.execute(
            "SELECT address FROM wallet_features WHERE address LIKE ? LIMIT 20", (like,)
        ).fetchall()
        ips = conn.execute(
            "SELECT DISTINCT src_ip FROM network_events WHERE src_ip LIKE ? LIMIT 20", (like,)
        ).fetchall()
        txids = conn.execute(
            "SELECT txid FROM transactions WHERE txid LIKE ? LIMIT 20", (like,)
        ).fetchall()
    return {
        "wallets": [r["address"] for r in wallets],
        "ips": [r["src_ip"] for r in ips],
        "txids": [r["txid"] for r in txids],
    }
