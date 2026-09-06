export interface Stats {
  transactions_ingested: number;
  entities_clustered: number;
  high_risk_alerts: number;
  distinct_ips: number;
  distinct_asns: number;
  communities_detected: number;
  risk_distribution: { high: number; medium: number; low: number };
  volume_timeline: { bucket: string; count: number }[];
}

export interface Reason {
  feature: string;
  z_score: number;
  text: string;
}

export interface Alert {
  id: number;
  entity_id: string;
  entity_type: "wallet" | "tx";
  risk_score: number;
  confidence: number;
  top_reasons: Reason[];
  community_id: number;
  created_at: string;
}

export interface AlertsResponse {
  count: number;
  alerts: Alert[];
}

export interface GraphNode {
  id: string;
  type: "wallet" | "ip";
  degree: number;
  community_id: number | null;
  risk_score: number;
}

export interface GraphEdge {
  source: string;
  target: string;
  type: "tx" | "network";
  weight: number;
}

export interface GraphData {
  nodes: GraphNode[];
  edges: GraphEdge[];
}

export interface TransactionRecord {
  id: number;
  txid: string;
  timestamp: string;
  fee: number;
  script_type: string;
  num_inputs: number;
  num_outputs: number;
  input_addresses: string[];
  output_addresses: string[];
  input_amounts: number[];
  output_amounts: number[];
  total_input: number;
  total_output: number;
  src_ip: string;
  dst_ip: string;
  src_port: number;
  dst_port: number;
  geo_country: string;
  asn: string;
}

export interface EntityDetail {
  entity_id: string;
  entity_type: "wallet" | "ip";
  graph_features: Record<string, number | string> | null;
  alert: Alert | null;
  transactions: TransactionRecord[];
  associated_ips: string[];
  associated_ports: number[];
  counterparties: string[];
  risk_score_history: { txid: string; timestamp: string; risk_score: number }[];
  network_events: {
    id: number;
    timestamp: string;
    src_ip: string;
    dst_ip: string;
    src_port: number;
    dst_port: number;
    txid: string;
    geo_country: string;
    asn: string;
  }[];
}

export interface PipelineStepResult {
  step: "ingest" | "graph" | "detect";
  data: Record<string, unknown>;
}
