"""
Synthetic Bitcoin transaction + network-metadata generator.

Produces a CSV matching the PS-26146 schema:
timestamp, src_ip, dst_ip, src_port, dst_port, txid, input_addresses,
output_addresses, input_amounts, output_amounts, fee, script_type,
geo_country, asn

~90% of rows look like normal P2P traffic. ~10% carry realistic illicit-pattern
signals (peeling chains, rapid-fire same-IP bursts, mixing-like many-in/many-out,
abnormally high fees, high-risk-ASN clusters, IP/port reuse across wallets).

Everything is generated locally with `random` — no network access, no downloads.
GeoIP enrichment uses the bundled geoip_data.json lookup table.
"""
import json
import random
import string
import csv
from datetime import datetime, timedelta
from pathlib import Path

BASE_DIR = Path(__file__).parent
GEOIP_PATH = BASE_DIR / "geoip_data.json"
DEFAULT_OUT = BASE_DIR / "data" / "synthetic_transactions.csv"

SCRIPT_TYPES = ["P2PKH", "P2SH", "P2WPKH", "P2WSH", "P2TR"]


def _load_geoip():
    with open(GEOIP_PATH, "r") as f:
        return json.load(f)["prefixes"]


def _random_address(script_type: str) -> str:
    chars = string.ascii_letters + string.digits
    if script_type == "P2WPKH" or script_type == "P2WSH" or script_type == "P2TR":
        return "bc1q" + "".join(random.choices(chars.lower(), k=38))
    prefix = "1" if script_type == "P2PKH" else "3"
    return prefix + "".join(random.choices(chars, k=33))


def _random_txid() -> str:
    return "".join(random.choices("0123456789abcdef", k=64))


def _ip_from_prefix(prefix: str) -> str:
    return f"{prefix}.{random.randint(1, 254)}"


def _enrich(ip: str, geoip: dict):
    prefix = ".".join(ip.split(".")[:3])
    meta = geoip.get(prefix)
    if meta is None:
        return "XX", "AS0000", False
    return meta["country"], meta["asn"], meta["risk_flag"]


class SyntheticGenerator:
    def __init__(self, seed: int = 42):
        random.seed(seed)
        self.geoip = _load_geoip()
        self.normal_prefixes = [p for p, m in self.geoip.items() if not m["risk_flag"]]
        self.risky_prefixes = [p for p, m in self.geoip.items() if m["risk_flag"]]
        # reusable wallet pool so a realistic tx graph forms (counterparties repeat)
        self.wallet_pool = [_random_address(random.choice(SCRIPT_TYPES)) for _ in range(160)]
        self.mixer_addresses = [_random_address("P2WSH") for _ in range(6)]
        self.rows = []
        self.t0 = datetime(2026, 8, 24, 6, 0, 0)

    def _new_ts(self, offset_seconds: float) -> str:
        return (self.t0 + timedelta(seconds=offset_seconds)).strftime("%Y-%m-%dT%H:%M:%S")

    def _base_row(self, ts_offset, src_ip, dst_ip, script_type, input_addrs, output_addrs,
                   input_amounts, output_amounts, fee):
        country, asn, _ = _enrich(src_ip, self.geoip)
        return {
            "timestamp": self._new_ts(ts_offset),
            "src_ip": src_ip,
            "dst_ip": dst_ip,
            "src_port": random.randint(1024, 65535),
            "dst_port": random.choice([8333, 8333, 8333, 443]),
            "txid": _random_txid(),
            "input_addresses": json.dumps(input_addrs),
            "output_addresses": json.dumps(output_addrs),
            "input_amounts": json.dumps(input_amounts),
            "output_amounts": json.dumps(output_amounts),
            "fee": round(fee, 8),
            "script_type": script_type,
            "geo_country": country,
            "asn": asn,
        }

    # ---------- normal traffic ----------
    def gen_normal(self, n: int, t_cursor: list):
        for _ in range(n):
            t_cursor[0] += random.uniform(20, 400)
            script_type = random.choice(SCRIPT_TYPES)
            src_ip = _ip_from_prefix(random.choice(self.normal_prefixes))
            dst_ip = _ip_from_prefix(random.choice(self.normal_prefixes))
            n_in = random.choice([1, 1, 1, 2, 2, 3])
            n_out = random.choice([1, 2, 2, 3])
            input_addrs = random.sample(self.wallet_pool, n_in)
            output_addrs = random.sample(self.wallet_pool, n_out)
            input_amounts = [round(random.uniform(0.001, 2.0), 8) for _ in range(n_in)]
            total_in = sum(input_amounts)
            fee = round(total_in * random.uniform(0.0002, 0.001), 8)
            remaining = max(total_in - fee, 0.0001)
            splits = sorted([random.random() for _ in range(n_out)])
            splits = [s / sum(splits) for s in splits] if sum(splits) > 0 else [1 / n_out] * n_out
            output_amounts = [round(remaining * s, 8) for s in splits]
            self.rows.append(self._base_row(
                t_cursor[0], src_ip, dst_ip, script_type,
                input_addrs, output_addrs, input_amounts, output_amounts, fee
            ))

    # ---------- illicit pattern: peeling chain ----------
    def gen_peeling_chain(self, t_cursor: list):
        source_wallet = _random_address("P2PKH")
        current_amount = round(random.uniform(8, 25), 6)
        src_ip = _ip_from_prefix(random.choice(self.normal_prefixes))
        chain_len = random.randint(6, 10)
        for i in range(chain_len):
            t_cursor[0] += random.uniform(30, 90)
            peel_amount = round(current_amount * random.uniform(0.04, 0.09), 8)
            change_amount = round(current_amount - peel_amount - 0.00015, 8)
            peel_target = _random_address("P2WPKH")
            change_target = _random_address("P2PKH") if i < chain_len - 1 else _random_address("P2WPKH")
            self.rows.append(self._base_row(
                t_cursor[0], src_ip, _ip_from_prefix(random.choice(self.normal_prefixes)),
                "P2PKH", [source_wallet], [peel_target, change_target],
                [current_amount], [peel_amount, max(change_amount, 0.0001)], 0.00015
            ))
            source_wallet = change_target
            current_amount = max(change_amount, 0.0001)

    # ---------- illicit pattern: rapid-fire same-IP burst (Sybil-ish) ----------
    def gen_rapid_fire(self, t_cursor: list):
        burst_ip = _ip_from_prefix(random.choice(self.normal_prefixes))
        burst_port = random.randint(1024, 65535)
        t_cursor[0] += random.uniform(50, 200)
        base_t = t_cursor[0]
        for i in range(random.randint(6, 10)):
            wallet_a = random.choice(self.wallet_pool)
            wallet_b = _random_address("P2WPKH")
            amt = round(random.uniform(0.01, 0.5), 8)
            row = self._base_row(
                base_t + i * random.uniform(0.5, 4.0), burst_ip,
                _ip_from_prefix(random.choice(self.normal_prefixes)),
                "P2WPKH", [wallet_a], [wallet_b], [amt], [round(amt - 0.00012, 8)], 0.00012
            )
            row["src_port"] = burst_port  # same IP+port reused across distinct wallets => Sybil signal
            self.rows.append(row)
        t_cursor[0] = base_t + 40

    # ---------- illicit pattern: mixing-like many-in/many-out ----------
    def gen_mixing(self, t_cursor: list):
        t_cursor[0] += random.uniform(60, 200)
        n_in = random.randint(6, 10)
        n_out = random.randint(6, 10)
        input_addrs = random.sample(self.wallet_pool, min(n_in, len(self.wallet_pool)))
        output_addrs = random.sample(self.mixer_addresses, min(n_out, len(self.mixer_addresses)))
        while len(output_addrs) < n_out:
            output_addrs.append(random.choice(self.mixer_addresses))
        equal_amt = round(random.uniform(0.05, 0.2), 8)
        input_amounts = [round(equal_amt * random.uniform(0.98, 1.05), 8) for _ in range(len(input_addrs))]
        output_amounts = [equal_amt for _ in range(len(output_addrs))]  # near-identical => mixing signature
        fee = round(sum(input_amounts) * 0.0015, 8)
        self.rows.append(self._base_row(
            t_cursor[0], _ip_from_prefix(random.choice(self.risky_prefixes)),
            _ip_from_prefix(random.choice(self.normal_prefixes)),
            "P2WSH", input_addrs, output_addrs, input_amounts, output_amounts, fee
        ))

    # ---------- illicit pattern: abnormally high fee ----------
    def gen_high_fee(self, t_cursor: list):
        t_cursor[0] += random.uniform(30, 150)
        wallet_a = random.choice(self.wallet_pool)
        wallet_b = _random_address("P2SH")
        amt = round(random.uniform(0.05, 1.0), 8)
        fee = round(amt * random.uniform(0.08, 0.25), 8)  # 10-50x+ a normal fee ratio
        self.rows.append(self._base_row(
            t_cursor[0], _ip_from_prefix(random.choice(self.normal_prefixes)),
            _ip_from_prefix(random.choice(self.normal_prefixes)),
            "P2SH", [wallet_a], [wallet_b], [amt], [round(amt - fee, 8)], fee
        ))

    # ---------- illicit pattern: high-risk ASN cluster ----------
    def gen_bad_asn_cluster(self, t_cursor: list):
        risky_ip = _ip_from_prefix(random.choice(self.risky_prefixes))
        t_cursor[0] += random.uniform(30, 150)
        base_t = t_cursor[0]
        for i in range(random.randint(3, 5)):
            wallet_a = _random_address("P2WPKH")
            wallet_b = random.choice(self.wallet_pool)
            amt = round(random.uniform(0.02, 0.6), 8)
            self.rows.append(self._base_row(
                base_t + i * random.uniform(15, 60), risky_ip,
                _ip_from_prefix(random.choice(self.risky_prefixes)),
                "P2WPKH", [wallet_a], [wallet_b], [amt], [round(amt - 0.0002, 8)], 0.0002
            ))
        t_cursor[0] = base_t + 300

    def generate(self, total: int = 500, illicit_ratio: float = 0.10):
        n_illicit_target = int(total * illicit_ratio)
        t_cursor = [0.0]

        illicit_generators = [
            self.gen_peeling_chain,
            self.gen_rapid_fire,
            self.gen_mixing,
            self.gen_high_fee,
            self.gen_bad_asn_cluster,
        ]
        produced_illicit = 0
        while produced_illicit < n_illicit_target:
            gen = random.choice(illicit_generators)
            before = len(self.rows)
            gen(t_cursor)
            produced_illicit += len(self.rows) - before

        n_normal = max(total - len(self.rows), 0)
        self.gen_normal(n_normal, t_cursor)

        random.shuffle(self.rows)
        self.rows.sort(key=lambda r: r["timestamp"])
        return self.rows

    def write_csv(self, path: Path = DEFAULT_OUT, total: int = 500, illicit_ratio: float = 0.10):
        rows = self.generate(total=total, illicit_ratio=illicit_ratio)
        path.parent.mkdir(parents=True, exist_ok=True)
        fieldnames = [
            "timestamp", "src_ip", "dst_ip", "src_port", "dst_port", "txid",
            "input_addresses", "output_addresses", "input_amounts", "output_amounts",
            "fee", "script_type", "geo_country", "asn",
        ]
        with open(path, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)
        return path, len(rows)


def ensure_dataset(path: Path = DEFAULT_OUT, total: int = 500) -> Path:
    """Generate the synthetic dataset if it doesn't already exist on disk."""
    if not path.exists():
        SyntheticGenerator(seed=42).write_csv(path=path, total=total)
    return path


if __name__ == "__main__":
    p, n = SyntheticGenerator(seed=42).write_csv()
    print(f"Wrote {n} rows to {p}")
