import type { AlertsResponse, EntityDetail, GraphData, Stats } from "./types";

async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(path, init);
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.detail || `Request failed: ${res.status} ${res.statusText}`);
  }
  return res.json() as Promise<T>;
}

export function getHealth() {
  return apiFetch<{ status: string; time: string }>("/api/health");
}

export function getStats() {
  return apiFetch<Stats>("/api/stats");
}

export function getAlerts(params: { entityType?: "wallet" | "tx"; riskTier?: "high" | "medium" | "low"; limit?: number } = {}) {
  const qs = new URLSearchParams();
  if (params.entityType) qs.set("entity_type", params.entityType);
  if (params.riskTier) qs.set("risk_tier", params.riskTier);
  qs.set("limit", String(params.limit ?? 200));
  return apiFetch<AlertsResponse>(`/api/alerts?${qs.toString()}`);
}

export function getGraph(limit = 400) {
  return apiFetch<GraphData>(`/api/graph?limit=${limit}`);
}

export function getEntity(entityId: string) {
  return apiFetch<EntityDetail>(`/api/entity/${encodeURIComponent(entityId)}`);
}

export function searchEntities(q: string) {
  return apiFetch<{ wallets: string[]; ips: string[]; txids: string[] }>(
    `/api/entity-search?q=${encodeURIComponent(q)}`
  );
}

export function runIngest() {
  return apiFetch<Record<string, unknown>>("/api/ingest", { method: "POST" });
}

export function runBuildGraph() {
  return apiFetch<Record<string, unknown>>("/api/graph", { method: "POST" });
}

export function runDetect() {
  return apiFetch<Record<string, unknown>>("/api/detect", { method: "POST" });
}

export async function runFullPipeline() {
  const ingest = await runIngest();
  const graph = await runBuildGraph();
  const detect = await runDetect();
  return { ingest, graph, detect };
}
