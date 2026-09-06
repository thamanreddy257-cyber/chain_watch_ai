import json

import networkx as nx
from networkx.algorithms.community import greedy_modularity_communities

from db import db_session


def build_graph_from_db() -> dict:
    """Builds an entity graph: nodes = wallets + IPs, edges = wallet<->wallet (tx flow)
    and ip<->wallet (network co-occurrence). Runs real networkx computations:
    degree, distinct counterparties/IPs/ASNs, clustering coefficient, and
    greedy-modularity community detection to cluster wallets into entity groups.
    """
    with db_session() as conn:
        tx_rows = conn.execute(
            "SELECT txid, input_addresses, output_addresses, src_ip, asn FROM transactions"
        ).fetchall()

    # Directed graph carries both wallet-wallet tx edges and ip-wallet network edges.
    G = nx.DiGraph()
    wallet_ip_map = {}   # wallet -> set(ips)
    wallet_asn_map = {}  # wallet -> set(asns)

    for row in tx_rows:
        inputs = json.loads(row["input_addresses"])
        outputs = json.loads(row["output_addresses"])
        src_ip = row["src_ip"]
        asn = row["asn"]

        for addr in inputs + outputs:
            if not G.has_node(addr):
                G.add_node(addr, type="wallet")
            wallet_ip_map.setdefault(addr, set()).add(src_ip)
            wallet_asn_map.setdefault(addr, set()).add(asn)

        if not G.has_node(src_ip):
            G.add_node(src_ip, type="ip")

        # wallet -> wallet transaction-flow edges (all input/output combinations)
        for i_addr in inputs:
            for o_addr in outputs:
                if G.has_edge(i_addr, o_addr):
                    G[i_addr][o_addr]["weight"] += 1
                    G[i_addr][o_addr]["txids"].append(row["txid"])
                else:
                    G.add_edge(i_addr, o_addr, type="tx", weight=1, txids=[row["txid"]])

        # ip -> wallet network co-occurrence edges (observed together)
        for addr in inputs:
            if G.has_edge(src_ip, addr):
                G[src_ip][addr]["weight"] += 1
            else:
                G.add_edge(src_ip, addr, type="network", weight=1)

    # ----- wallet-only undirected subgraph, used for degree/clustering/community -----
    wallet_nodes = [n for n, d in G.nodes(data=True) if d.get("type") == "wallet"]
    wallet_edges = [(u, v) for u, v, d in G.edges(data=True) if d.get("type") == "tx"]
    WG = nx.Graph()
    WG.add_nodes_from(wallet_nodes)
    WG.add_edges_from(wallet_edges)

    clustering = nx.clustering(WG)

    communities = list(greedy_modularity_communities(WG)) if WG.number_of_edges() > 0 else []
    community_of = {}
    for cid, members in enumerate(communities):
        for m in members:
            community_of[m] = cid
    community_size = {cid: len(members) for cid, members in enumerate(communities)}

    wallet_feature_rows = []
    for addr in wallet_nodes:
        degree_in = G.in_degree(addr, weight=None)
        degree_out = G.out_degree(addr, weight=None)
        # only count 'tx' type neighbors for counterparties (exclude ip edges)
        counterparties = set()
        for _, v, d in G.out_edges(addr, data=True):
            if d.get("type") == "tx":
                counterparties.add(v)
        for u, _, d in G.in_edges(addr, data=True):
            if d.get("type") == "tx":
                counterparties.add(u)

        cid = community_of.get(addr, -1)
        wallet_feature_rows.append((
            addr,
            degree_in,
            degree_out,
            degree_in + degree_out,
            len(counterparties),
            len(wallet_ip_map.get(addr, set())),
            len(wallet_asn_map.get(addr, set())),
            float(clustering.get(addr, 0.0)),
            cid,
            community_size.get(cid, 1),
            0,  # num_tx filled by ml_detect feature step
        ))

    with db_session() as conn:
        conn.executemany(
            """INSERT INTO wallet_features
               (address, degree_in, degree_out, total_degree, distinct_counterparties,
                distinct_ips, distinct_asns, clustering_coeff, community_id, community_size, num_tx)
               VALUES (?,?,?,?,?,?,?,?,?,?,?)
               ON CONFLICT(address) DO UPDATE SET
                 degree_in=excluded.degree_in, degree_out=excluded.degree_out,
                 total_degree=excluded.total_degree,
                 distinct_counterparties=excluded.distinct_counterparties,
                 distinct_ips=excluded.distinct_ips, distinct_asns=excluded.distinct_asns,
                 clustering_coeff=excluded.clustering_coeff, community_id=excluded.community_id,
                 community_size=excluded.community_size""",
            wallet_feature_rows,
        )

    return {
        "nodes_total": G.number_of_nodes(),
        "wallet_nodes": len(wallet_nodes),
        "ip_nodes": G.number_of_nodes() - len(wallet_nodes),
        "edges_total": G.number_of_edges(),
        "communities_detected": len(communities),
    }


def graph_to_json(limit_nodes: int = 400) -> dict:
    """Returns the persisted graph (rebuilt fresh from DB) as {nodes, edges} for
    the frontend force-graph visualization, joined with latest alert risk scores.
    """
    with db_session() as conn:
        tx_rows = conn.execute(
            "SELECT txid, input_addresses, output_addresses, src_ip FROM transactions"
        ).fetchall()
        wf_rows = {r["address"]: dict(r) for r in conn.execute("SELECT * FROM wallet_features").fetchall()}
        alert_rows = conn.execute(
            "SELECT entity_id, risk_score FROM alerts WHERE entity_type = 'wallet'"
        ).fetchall()
    risk_by_wallet = {r["entity_id"]: r["risk_score"] for r in alert_rows}

    G = nx.DiGraph()
    for row in tx_rows:
        inputs = json.loads(row["input_addresses"])
        outputs = json.loads(row["output_addresses"])
        src_ip = row["src_ip"]
        for addr in inputs + outputs:
            if not G.has_node(addr):
                G.add_node(addr, type="wallet")
        if not G.has_node(src_ip):
            G.add_node(src_ip, type="ip")
        for i_addr in inputs:
            for o_addr in outputs:
                if G.has_edge(i_addr, o_addr):
                    G[i_addr][o_addr]["weight"] += 1
                else:
                    G.add_edge(i_addr, o_addr, type="tx", weight=1)
            if G.has_edge(src_ip, i_addr):
                G[src_ip][i_addr]["weight"] += 1
            else:
                G.add_edge(src_ip, i_addr, type="network", weight=1)

    # keep the graph readable in the UI: cap to the highest-degree nodes
    degrees = dict(G.degree())
    top_nodes = sorted(degrees, key=lambda n: degrees[n], reverse=True)[:limit_nodes]
    top_set = set(top_nodes)
    SG = G.subgraph(top_set)

    nodes = []
    for n, d in SG.nodes(data=True):
        node_type = d.get("type", "wallet")
        wf = wf_rows.get(n, {})
        nodes.append({
            "id": n,
            "type": node_type,
            "degree": degrees.get(n, 0),
            "community_id": wf.get("community_id", -1) if node_type == "wallet" else None,
            "risk_score": risk_by_wallet.get(n, 0) if node_type == "wallet" else 0,
        })

    edges = [
        {"source": u, "target": v, "type": d.get("type"), "weight": d.get("weight", 1)}
        for u, v, d in SG.edges(data=True)
    ]

    return {"nodes": nodes, "edges": edges}
