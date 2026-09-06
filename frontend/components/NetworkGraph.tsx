"use client";

import type { GraphData } from "@/lib/types";
import dynamic from "next/dynamic";
import { useMemo } from "react";

const ForceGraph2D = dynamic(() => import("react-force-graph-2d"), { ssr: false });

function nodeColor(node: { type: string; risk_score: number }) {
  if (node.type === "ip") return "#5a677c";
  if (node.risk_score >= 75) return "#f43f5e";
  if (node.risk_score >= 45) return "#f5a524";
  return "#2dd4bf";
}

export default function NetworkGraph({
  data,
  onSelect,
  height = 420,
}: {
  data: GraphData;
  onSelect: (id: string) => void;
  height?: number;
}) {
  const graph = useMemo(
    () => ({
      nodes: data.nodes.map((n) => ({ ...n })),
      links: data.edges.map((e) => ({ ...e })),
    }),
    [data]
  );

  return (
    <div className="card overflow-hidden p-0">
      <div className="flex items-center justify-between border-b border-base-700 px-4 py-3">
        <div className="text-sm font-medium text-ink-300">Entity Graph</div>
        <div className="flex items-center gap-3 text-[11px] text-ink-500">
          <span className="flex items-center gap-1">
            <span className="h-2 w-2 rounded-full bg-signal-red" /> high
          </span>
          <span className="flex items-center gap-1">
            <span className="h-2 w-2 rounded-full bg-signal-amber" /> medium
          </span>
          <span className="flex items-center gap-1">
            <span className="h-2 w-2 rounded-full bg-signal-teal" /> low
          </span>
          <span className="flex items-center gap-1">
            <span className="h-2 w-2 rounded-full bg-ink-600" /> ip
          </span>
        </div>
      </div>
      {graph.nodes.length === 0 ? (
        <div className="flex items-center justify-center text-sm text-ink-500" style={{ height }}>
          No graph built yet
        </div>
      ) : (
        <ForceGraph2D
          graphData={graph}
          height={height}
          backgroundColor="#0d1219"
          nodeRelSize={3.2}
          nodeVal={(n: any) => Math.max(1, Math.sqrt(n.degree || 1))}
          nodeColor={(n: any) => nodeColor(n)}
          nodeLabel={(n: any) => `${n.id}\n${n.type} · degree ${n.degree}${n.risk_score ? ` · risk ${n.risk_score.toFixed(0)}` : ""}`}
          linkColor={(l: any) => (l.type === "network" ? "rgba(90,103,124,0.25)" : "rgba(61,81,112,0.5)")}
          linkWidth={(l: any) => Math.min(3, 0.4 + Math.log2((l.weight || 1) + 1))}
          linkDirectionalParticles={(l: any) => (l.type === "tx" ? 1 : 0)}
          linkDirectionalParticleWidth={1.4}
          linkDirectionalParticleColor={() => "#2dd4bf"}
          onNodeClick={(n: any) => onSelect(n.id)}
          cooldownTicks={80}
        />
      )}
    </div>
  );
}
