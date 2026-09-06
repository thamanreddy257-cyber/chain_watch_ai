"use client";

import type { Alert } from "@/lib/types";
import { useMemo, useState } from "react";

function riskTier(score: number): "high" | "medium" | "low" {
  if (score >= 75) return "high";
  if (score >= 45) return "medium";
  return "low";
}

const tierClass: Record<string, string> = {
  high: "bg-signal-red/15 text-signal-red border-signal-red/30",
  medium: "bg-signal-amber/15 text-signal-amber border-signal-amber/30",
  low: "bg-signal-teal/15 text-signal-teal border-signal-teal/30",
};

export default function AlertsPanel({
  alerts,
  onSelect,
  selectedId,
}: {
  alerts: Alert[];
  onSelect: (entityId: string) => void;
  selectedId: string | null;
}) {
  const [tab, setTab] = useState<"all" | "wallet" | "tx">("all");

  const filtered = useMemo(
    () => (tab === "all" ? alerts : alerts.filter((a) => a.entity_type === tab)),
    [alerts, tab]
  );

  return (
    <div className="card flex h-full flex-col">
      <div className="flex items-center justify-between border-b border-base-700 px-4 py-3">
        <div className="text-sm font-medium text-ink-300">Alerts</div>
        <div className="flex gap-1 rounded-lg bg-base-800 p-0.5 text-xs">
          {(["all", "wallet", "tx"] as const).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`rounded-md px-2.5 py-1 capitalize transition ${
                tab === t ? "bg-base-700 text-ink-100" : "text-ink-500 hover:text-ink-300"
              }`}
            >
              {t}
            </button>
          ))}
        </div>
      </div>
      <div className="flex-1 overflow-y-auto">
        {filtered.length === 0 ? (
          <div className="flex h-full items-center justify-center p-6 text-center text-sm text-ink-500">
            No alerts. Run the pipeline to generate scored transactions and wallets.
          </div>
        ) : (
          <ul className="divide-y divide-base-800">
            {filtered.map((a) => {
              const tier = riskTier(a.risk_score);
              const active = selectedId === a.entity_id;
              return (
                <li key={`${a.entity_type}-${a.entity_id}`}>
                  <button
                    onClick={() => onSelect(a.entity_id)}
                    className={`w-full px-4 py-3 text-left transition hover:bg-base-800/60 ${
                      active ? "bg-base-800" : ""
                    }`}
                  >
                    <div className="flex items-center justify-between gap-2">
                      <span className="truncate font-mono text-xs text-ink-300">{a.entity_id}</span>
                      <span
                        className={`shrink-0 rounded-full border px-2 py-0.5 text-[10px] font-semibold uppercase ${tierClass[tier]}`}
                      >
                        {a.risk_score.toFixed(0)}
                      </span>
                    </div>
                    <div className="mt-1 flex items-center gap-2 text-[11px] text-ink-500">
                      <span className="rounded bg-base-800 px-1.5 py-0.5 uppercase tracking-wide">
                        {a.entity_type}
                      </span>
                      <span>conf {(a.confidence * 100).toFixed(0)}%</span>
                      {a.community_id >= 0 && <span>community #{a.community_id}</span>}
                    </div>
                    {a.top_reasons[0] && (
                      <div className="mt-1.5 truncate text-[11px] text-ink-600">{a.top_reasons[0].text}</div>
                    )}
                  </button>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </div>
  );
}
