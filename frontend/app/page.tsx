"use client";

import AlertsPanel from "@/components/AlertsPanel";
import EntityDrawer from "@/components/EntityDrawer";
import NetworkGraph from "@/components/NetworkGraph";
import PipelineBar from "@/components/PipelineBar";
import RiskDonut from "@/components/RiskDonut";
import SearchResults from "@/components/SearchResults";
import StatCard from "@/components/StatCard";
import VolumeChart from "@/components/VolumeChart";
import * as api from "@/lib/api";
import type { Alert, EntityDetail, GraphData, Stats } from "@/lib/types";
import { AlertOctagon, Globe2, Layers, Network, ShieldAlert, Waves } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

export default function Dashboard() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [graph, setGraph] = useState<GraphData>({ nodes: [], edges: [] });
  const [running, setRunning] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [selectedEntity, setSelectedEntity] = useState<string | null>(null);
  const [entityDetail, setEntityDetail] = useState<EntityDetail | null>(null);
  const [entityLoading, setEntityLoading] = useState(false);
  const [entityError, setEntityError] = useState<string | null>(null);

  const [searchResults, setSearchResults] = useState<{ wallets: string[]; ips: string[]; txids: string[] } | null>(
    null
  );

  const refreshAll = useCallback(async () => {
    try {
      const [s, a, g] = await Promise.all([api.getStats(), api.getAlerts({ limit: 300 }), api.getGraph(300)]);
      setStats(s);
      setAlerts(a.alerts);
      setGraph(g);
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to load data");
    }
  }, []);

  useEffect(() => {
    refreshAll();
  }, [refreshAll]);

  const openEntity = useCallback(async (id: string) => {
    setSelectedEntity(id);
    setSearchResults(null);
    setEntityLoading(true);
    setEntityError(null);
    setEntityDetail(null);
    try {
      const d = await api.getEntity(id);
      setEntityDetail(d);
    } catch (e) {
      setEntityError(e instanceof Error ? e.message : "Entity not found");
    } finally {
      setEntityLoading(false);
    }
  }, []);

  const withRunning = useCallback(
    async (fn: () => Promise<unknown>) => {
      setRunning(true);
      try {
        await fn();
        await refreshAll();
        setError(null);
      } catch (e) {
        setError(e instanceof Error ? e.message : "Pipeline step failed");
      } finally {
        setRunning(false);
      }
    },
    [refreshAll]
  );

  const handleSearch = async (q: string) => {
    try {
      const r = await api.searchEntities(q);
      setSearchResults(r);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Search failed");
    }
  };

  return (
    <main className="min-h-screen bg-base-950">
      <PipelineBar
        running={running}
        onRunFull={() => withRunning(api.runFullPipeline)}
        onIngest={() => withRunning(api.runIngest)}
        onBuildGraph={() => withRunning(api.runBuildGraph)}
        onDetect={() => withRunning(api.runDetect)}
        onSearch={handleSearch}
      />

      <div className="mx-auto max-w-[1400px] space-y-4 px-6 py-5">
        {error && (
          <div className="rounded-lg border border-signal-red/30 bg-signal-red/10 px-4 py-2.5 text-sm text-signal-red">
            {error}
          </div>
        )}

        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-6">
          <StatCard label="Transactions" value={stats?.transactions_ingested ?? "—"} icon={Waves} accent="blue" />
          <StatCard label="Entities Clustered" value={stats?.entities_clustered ?? "—"} icon={Layers} accent="teal" />
          <StatCard label="High-Risk Alerts" value={stats?.high_risk_alerts ?? "—"} icon={ShieldAlert} accent="red" />
          <StatCard label="Distinct IPs" value={stats?.distinct_ips ?? "—"} icon={Globe2} accent="blue" />
          <StatCard label="Distinct ASNs" value={stats?.distinct_asns ?? "—"} icon={Network} accent="amber" />
          <StatCard
            label="Communities"
            value={stats?.communities_detected ?? "—"}
            icon={AlertOctagon}
            accent="teal"
          />
        </div>

        <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
          <div className="lg:col-span-2">
            <VolumeChart data={stats?.volume_timeline ?? []} />
          </div>
          <RiskDonut
            high={stats?.risk_distribution.high ?? 0}
            medium={stats?.risk_distribution.medium ?? 0}
            low={stats?.risk_distribution.low ?? 0}
          />
        </div>

        <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
          <div className="lg:col-span-2">
            <NetworkGraph data={graph} onSelect={openEntity} />
          </div>
          <div className="h-[420px]">
            <AlertsPanel alerts={alerts} onSelect={openEntity} selectedId={selectedEntity} />
          </div>
        </div>
      </div>

      {selectedEntity && (
        <EntityDrawer
          entityId={selectedEntity}
          detail={entityDetail}
          loading={entityLoading}
          error={entityError}
          onClose={() => setSelectedEntity(null)}
          onNavigate={openEntity}
        />
      )}

      {searchResults && (
        <SearchResults results={searchResults} onSelect={openEntity} onClose={() => setSearchResults(null)} />
      )}
    </main>
  );
}
