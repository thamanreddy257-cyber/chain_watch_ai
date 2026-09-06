import json
from pathlib import Path

import pandas as pd

from db import db_session, reset_transactional_tables

REQUIRED_COLUMNS = [
    "timestamp", "src_ip", "dst_ip", "src_port", "dst_port", "txid",
    "input_addresses", "output_addresses", "input_amounts", "output_amounts",
    "fee", "script_type", "geo_country", "asn",
]


def _parse_list_cell(value):
    if isinstance(value, list):
        return value
    if value is None or (isinstance(value, float)):
        return []
    try:
        parsed = json.loads(value)
        return parsed if isinstance(parsed, list) else [parsed]
    except (json.JSONDecodeError, TypeError):
        return [v.strip() for v in str(value).split("|") if v.strip()]


def ingest_csv(csv_path: Path) -> dict:
    df = pd.read_csv(csv_path)
    missing = [c for c in REQUIRED_COLUMNS if c not in df.columns]
    if missing:
        raise ValueError(f"CSV is missing required columns: {missing}")

    reset_transactional_tables()

    wallets = set()
    ips = set()
    tx_rows = []
    net_rows = []

    for _, row in df.iterrows():
        input_addrs = _parse_list_cell(row["input_addresses"])
        output_addrs = _parse_list_cell(row["output_addresses"])
        input_amounts = [float(x) for x in _parse_list_cell(row["input_amounts"])]
        output_amounts = [float(x) for x in _parse_list_cell(row["output_amounts"])]

        wallets.update(input_addrs)
        wallets.update(output_addrs)
        ips.add(row["src_ip"])
        ips.add(row["dst_ip"])

        tx_rows.append((
            str(row["txid"]), str(row["timestamp"]), float(row["fee"]), str(row["script_type"]),
            len(input_addrs), len(output_addrs),
            json.dumps(input_addrs), json.dumps(output_addrs),
            json.dumps(input_amounts), json.dumps(output_amounts),
            round(sum(input_amounts), 8), round(sum(output_amounts), 8),
            str(row["src_ip"]), str(row["dst_ip"]), int(row["src_port"]), int(row["dst_port"]),
            str(row["geo_country"]), str(row["asn"]),
        ))
        net_rows.append((
            str(row["timestamp"]), str(row["src_ip"]), str(row["dst_ip"]),
            int(row["src_port"]), int(row["dst_port"]), str(row["txid"]),
            str(row["geo_country"]), str(row["asn"]),
        ))

    with db_session() as conn:
        conn.executemany(
            """INSERT OR IGNORE INTO transactions
               (txid, timestamp, fee, script_type, num_inputs, num_outputs,
                input_addresses, output_addresses, input_amounts, output_amounts,
                total_input, total_output, src_ip, dst_ip, src_port, dst_port,
                geo_country, asn)
               VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
            tx_rows,
        )
        conn.executemany(
            """INSERT INTO network_events
               (timestamp, src_ip, dst_ip, src_port, dst_port, txid, geo_country, asn)
               VALUES (?,?,?,?,?,?,?,?)""",
            net_rows,
        )

    return {
        "transactions_ingested": len(tx_rows),
        "network_events_ingested": len(net_rows),
        "distinct_wallets": len(wallets),
        "distinct_ips": len(ips),
        "source_file": str(csv_path.name),
    }
