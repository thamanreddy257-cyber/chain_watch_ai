"""
Real, unsupervised anomaly detection over engineered transaction/wallet features.

Trains a scikit-learn IsolationForest on the ingested + graph-enriched dataset
(no labeled illicit data exists, hence unsupervised), converts its decision
function into a 0-100 risk score, and explains every flagged entity by
comparing its raw feature values against the dataset mean/std (z-scores) to
surface the top-3 deviating signals in plain English.
"""
import json
from datetime import datetime, timezone

import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest

from db import db_session

FEATURES = [
    "total_input", "fee", "fee_to_amount_ratio", "num_inputs", "num_outputs",
    "output_amount_cv", "time_delta_since_last_tx", "distinct_ips_used_by_wallet",
    "ip_wallet_fanout", "graph_degree", "community_size", "is_high_risk_asn",
]

FLAG_PERCENTILE = 88  # top ~12% of risk scores get written to the alerts table


def _load_high_risk_asns() -> set:
    import json as _json
    from pathlib import Path
    geoip_path = Path(__file__).parent / "geoip_data.json"
    with open(geoip_path) as f:
        prefixes = _json.load(f)["prefixes"]
    return {v["asn"] for v in prefixes.values() if v.get("risk_flag")}


def _primary_wallet(input_addrs, output_addrs):
    if input_addrs:
        return input_addrs[0]
    if output_addrs:
        return output_addrs[0]
    return "unknown"


def _build_feature_frame() -> pd.DataFrame:
    with db_session() as conn:
        tx_rows = [dict(r) for r in conn.execute("SELECT * FROM transactions").fetchall()]
        wf_rows = {r["address"]: dict(r) for r in conn.execute("SELECT * FROM wallet_features").fetchall()}

    if not tx_rows:
        return pd.DataFrame(columns=["txid", "timestamp", "primary_wallet"] + FEATURES)

    high_risk_asns = _load_high_risk_asns()
    records = []
    for row in tx_rows:
        input_addrs = json.loads(row["input_addresses"])
        output_addrs = json.loads(row["output_addresses"])
        output_amounts = json.loads(row["output_amounts"])
        primary_wallet = _primary_wallet(input_addrs, output_addrs)

        total_input = row["total_input"] or 0.0001
        fee = row["fee"]
        fee_ratio = fee / total_input if total_input > 0 else 0.0

        if len(output_amounts) > 1 and np.mean(output_amounts) > 0:
            output_cv = float(np.std(output_amounts) / np.mean(output_amounts))
        else:
            output_cv = 0.0

        wf = wf_rows.get(primary_wallet, {})

        records.append({
            "txid": row["txid"],
            "timestamp": row["timestamp"],
            "primary_wallet": primary_wallet,
            "src_ip": row["src_ip"],
            "asn": row["asn"],
            "total_input": total_input,
            "fee": fee,
            "fee_to_amount_ratio": fee_ratio,
            "num_inputs": row["num_inputs"],
            "num_outputs": row["num_outputs"],
            "output_amount_cv": output_cv,
            "distinct_ips_used_by_wallet": wf.get("distinct_ips", 1),
            "graph_degree": wf.get("total_degree", 0),
            "community_size": wf.get("community_size", 1),
            "is_high_risk_asn": 1 if row["asn"] in high_risk_asns else 0,
        })

    df = pd.DataFrame(records)
    df["timestamp"] = pd.to_datetime(df["timestamp"])

    # time since this wallet's previous transaction as an input-spender (seconds)
    df = df.sort_values("timestamp")
    df["time_delta_since_last_tx"] = (
        df.groupby("primary_wallet")["timestamp"].diff().dt.total_seconds()
    )
    median_delta = df["time_delta_since_last_tx"].median()
    fill_value = median_delta if pd.notna(median_delta) else 3600.0
    df["time_delta_since_last_tx"] = df["time_delta_since_last_tx"].fillna(fill_value)

    # ip_wallet_fanout: how many distinct primary wallets share this transaction's src_ip
    fanout = df.groupby("src_ip")["primary_wallet"].transform("nunique")
    df["ip_wallet_fanout"] = fanout

    return df.reset_index(drop=True)


def _reason_text(feature: str, value: float, mean: float, std: float, z: float) -> str:
    if feature == "fee_to_amount_ratio":
        if z > 0:
            mult = value / mean if mean > 0 else 0
            return f"Fee-to-amount ratio {value:.5f} is ~{mult:.1f}x the dataset average ({mean:.5f}) — abnormal priority-fee pattern"
        return f"Fee-to-amount ratio {value:.6f} is far below average ({mean:.5f}) — fixed minimal fee regardless of value moved, consistent with a peeling-chain step"
    if feature == "output_amount_cv":
        if z < 0:
            return f"Output amounts are nearly identical (variance coefficient {value:.3f} vs avg {mean:.3f}) — classic mixing/tumbler signature"
        return f"Output amounts vary sharply (variance coefficient {value:.3f} vs avg {mean:.3f}) — irregular fan-out"
    if feature == "distinct_ips_used_by_wallet":
        return f"{int(value)} distinct IPs used by this wallet (dataset avg {mean:.1f}) — Sybil-like behavior"
    if feature == "ip_wallet_fanout":
        return f"{int(value)} distinct wallets observed from the same source IP/port (dataset avg {mean:.1f}) — possible Sybil cluster or shared infrastructure"
    if feature == "time_delta_since_last_tx":
        if z < 0:
            return f"Only {value:.0f}s since this wallet's previous transaction (avg {mean:.0f}s) — rapid-fire automated behavior"
        return f"{value:.0f}s since this wallet's previous transaction — unusually long dormancy vs avg {mean:.0f}s"
    if feature == "graph_degree":
        return f"Transaction-graph degree {int(value)} is far above average ({mean:.1f}) — hub-like entity connecting many counterparties"
    if feature == "community_size":
        return f"Part of a densely-clustered community of {int(value)} wallets (avg {mean:.1f}) — coordinated flow pattern"
    if feature == "is_high_risk_asn":
        return "Source ASN is flagged as a known high-risk / bulletproof-hosting provider"
    if feature == "total_input":
        return f"Transaction value {value:.4f} BTC is far above the typical {mean:.4f} BTC — large-value outlier"
    if feature == "fee":
        return f"Absolute fee {value:.6f} BTC is far above the typical {mean:.6f} BTC"
    if feature == "num_outputs":
        return f"{int(value)} outputs in a single transaction (avg {mean:.1f}) — fan-out pattern"
    if feature == "num_inputs":
        return f"{int(value)} inputs consolidated into a single transaction (avg {mean:.1f}) — fan-in pattern"
    return f"{feature} = {value:.4f} deviates from dataset average {mean:.4f}"


def run_detection() -> dict:
    df = _build_feature_frame()
    if df.empty or len(df) < 5:
        return {"alerts_generated": 0, "high_risk_count": 0, "message": "Not enough ingested transactions to train a model."}

    X = df[FEATURES].astype(float).replace([np.inf, -np.inf], 0).fillna(0)

    model = IsolationForest(n_estimators=250, contamination=0.12, random_state=42)
    model.fit(X)
    # decision_function: higher = more normal. Flip so higher = more anomalous.
    raw_anomaly = -model.decision_function(X)

    lo, hi = raw_anomaly.min(), raw_anomaly.max()
    risk_score = 100 * (raw_anomaly - lo) / (hi - lo + 1e-9)
    df["risk_score"] = risk_score

    means = X.mean()
    stds = X.std().replace(0, 1e-9)

    threshold = float(np.percentile(risk_score, FLAG_PERCENTILE))

    with db_session() as conn:
        conn.execute("DELETE FROM alerts")
        conn.execute("DELETE FROM tx_scores")

        tx_score_rows = [
            (r.txid, r.primary_wallet, float(r.risk_score), str(r.timestamp))
            for r in df.itertuples()
        ]
        conn.executemany(
            "INSERT INTO tx_scores (txid, primary_wallet, risk_score, timestamp) VALUES (?,?,?,?)",
            tx_score_rows,
        )

        wf_lookup = {
            r["address"]: r["community_id"]
            for r in conn.execute("SELECT address, community_id FROM wallet_features").fetchall()
        }

        now = datetime.now(timezone.utc).isoformat()
        tx_alert_rows = []
        wallet_best = {}  # wallet -> (risk_score, confidence, reasons, community_id)

        for r in df.itertuples():
            if r.risk_score < threshold:
                continue
            row_vals = {f: getattr(r, f) for f in FEATURES}
            z_scores = {f: (row_vals[f] - means[f]) / stds[f] for f in FEATURES}
            top_features = sorted(z_scores.items(), key=lambda kv: abs(kv[1]), reverse=True)[:3]
            reasons = [
                {"feature": f, "z_score": round(float(z), 2),
                 "text": _reason_text(f, row_vals[f], float(means[f]), float(stds[f]), float(z))}
                for f, z in top_features
            ]
            strong = sum(1 for _, z in top_features if abs(z) > 2)
            confidence = round(min(0.99, max(0.05, 0.35 + 0.5 * (r.risk_score / 100) + 0.05 * strong)), 2)
            community_id = wf_lookup.get(r.primary_wallet, -1)

            tx_alert_rows.append((
                r.txid, "tx", round(float(r.risk_score), 2), confidence,
                json.dumps(reasons), community_id, now,
            ))

            prev = wallet_best.get(r.primary_wallet)
            if prev is None or r.risk_score > prev[0]:
                wallet_best[r.primary_wallet] = (float(r.risk_score), confidence, reasons, community_id)

        conn.executemany(
            """INSERT INTO alerts (entity_id, entity_type, risk_score, confidence, top_reasons, community_id, created_at)
               VALUES (?,?,?,?,?,?,?)""",
            tx_alert_rows,
        )

        wallet_alert_rows = [
            (wallet, "wallet", round(score, 2), conf, json.dumps(reasons), cid, now)
            for wallet, (score, conf, reasons, cid) in wallet_best.items()
        ]
        conn.executemany(
            """INSERT INTO alerts (entity_id, entity_type, risk_score, confidence, top_reasons, community_id, created_at)
               VALUES (?,?,?,?,?,?,?)""",
            wallet_alert_rows,
        )

        # keep wallet_features.num_tx in sync with the trained feature set
        num_tx_by_wallet = df.groupby("primary_wallet").size().to_dict()
        conn.executemany(
            "UPDATE wallet_features SET num_tx = ? WHERE address = ?",
            [(int(n), w) for w, n in num_tx_by_wallet.items()],
        )

    return {
        "transactions_scored": int(len(df)),
        "risk_threshold": round(threshold, 2),
        "alerts_generated": len(tx_alert_rows) + len(wallet_alert_rows),
        "tx_alerts": len(tx_alert_rows),
        "wallet_alerts": len(wallet_alert_rows),
        "high_risk_count": int((df["risk_score"] >= 75).sum()),
    }
