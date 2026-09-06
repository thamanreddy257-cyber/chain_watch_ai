import sqlite3
from pathlib import Path
from contextlib import contextmanager

DB_PATH = Path(__file__).parent / "chainwatch.db"

SCHEMA = """
CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    txid TEXT UNIQUE,
    timestamp TEXT,
    fee REAL,
    script_type TEXT,
    num_inputs INTEGER,
    num_outputs INTEGER,
    input_addresses TEXT,
    output_addresses TEXT,
    input_amounts TEXT,
    output_amounts TEXT,
    total_input REAL,
    total_output REAL,
    src_ip TEXT,
    dst_ip TEXT,
    src_port INTEGER,
    dst_port INTEGER,
    geo_country TEXT,
    asn TEXT
);

CREATE TABLE IF NOT EXISTS network_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT,
    src_ip TEXT,
    dst_ip TEXT,
    src_port INTEGER,
    dst_port INTEGER,
    txid TEXT,
    geo_country TEXT,
    asn TEXT
);

CREATE TABLE IF NOT EXISTS wallet_features (
    address TEXT PRIMARY KEY,
    degree_in INTEGER,
    degree_out INTEGER,
    total_degree INTEGER,
    distinct_counterparties INTEGER,
    distinct_ips INTEGER,
    distinct_asns INTEGER,
    clustering_coeff REAL,
    community_id INTEGER,
    community_size INTEGER,
    num_tx INTEGER
);

CREATE TABLE IF NOT EXISTS tx_scores (
    txid TEXT PRIMARY KEY,
    primary_wallet TEXT,
    risk_score REAL,
    timestamp TEXT
);

CREATE TABLE IF NOT EXISTS alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entity_id TEXT,
    entity_type TEXT,
    risk_score REAL,
    confidence REAL,
    top_reasons TEXT,
    community_id INTEGER,
    created_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_tx_timestamp ON transactions(timestamp);
CREATE INDEX IF NOT EXISTS idx_alerts_risk ON alerts(risk_score);
"""


def get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    conn = get_conn()
    try:
        conn.executescript(SCHEMA)
        conn.commit()
    finally:
        conn.close()


def reset_transactional_tables():
    """Clear ingestion/derived tables so the pipeline can be re-run cleanly (keeps schema)."""
    conn = get_conn()
    try:
        for table in ["transactions", "network_events", "wallet_features", "alerts", "tx_scores"]:
            conn.execute(f"DELETE FROM {table}")
        conn.commit()
    finally:
        conn.close()


@contextmanager
def db_session():
    conn = get_conn()
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()
