"use client";

import type { EntityDetail } from "@/lib/types";
import { AlertTriangle, Loader2, X } from "lucide-react";

function riskTier(score: number): "high" | "medium" | "low" {
  if (score >= 75) return "high";
  if (score >= 45) return "medium";
  return "low";
}

const tierClass: Record<string, string> = {
  high: "text-signal-red border-signal-red/30 bg-signal-red/10",
  medium: "text-signal-amber border-signal-amber/30 bg-signal-amber/10",
  low: "text-signal-teal border-signal-teal/30 bg-signal-teal/10",
};

export default function EntityDrawer({
  entityId,
  detail,
  loading,
  error,
  onClose,
  onNavigate,
}: {
  entityId: string;
  detail: EntityDetail | null;
  loading: boolean;
  error: string | null;
  onClose: () => void;
  onNavigate: (id: string) => void;
}) {
  return (
    <div className="fixed inset-0 z-30 flex justify-end bg-black/50 backdrop-blur-sm animate-fade-in" onClick={onClose}>
      <div
        className="h-full w-full max-w-md overflow-y-auto border-l border-base-700 bg-base-900 shadow-2xl animate-slide-in"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="sticky top-0 flex items-center justify-between border-b border-base-700 bg-base-900/95 px-5 py-4 backdrop-blur">
          <div className="min-w-0">
            <div className="text-[11px] uppercase tracking-wide text-ink-500">Entity</div>
            <div className="truncate font-mono text-sm text-ink-100">{entityId}</div>
          </div>
          <button onClick={onClose} className="rounded-lg p-1.5 text-ink-500 hover:bg-base-800 hover:text-ink-100">
            <X size={18} />
          </button>
        </div>

        <div className="p-5">
          {loading && (
            <div className="flex items-center justify-center gap-2 py-16 text-sm text-ink-500">
              <Loader2 size={16} className="animate-spin" /> Loading…
            </div>
          )}
          {error && (
            <div className="flex items-center gap-2 rounded-lg border border-signal-red/30 bg-signal-red/10 p-3 text-sm text-signal-red">
              <AlertTriangle size={16} /> {error}
            </div>
          )}
          {detail && !loading && (
            <div className="space-y-5">
              {detail.alert && (
                <div className={`rounded-xl border p-4 ${tierClass[riskTier(detail.alert.risk_score)]}`}>
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-semibold uppercase tracking-wide">
                      {riskTier(detail.alert.risk_score)} risk
                    </span>
                    <span className="mono-tabular text-2xl font-bold">{detail.alert.risk_score.toFixed(0)}</span>
                  </div>
                  <div className="mt-1 text-xs opacity-80">
                    Confidence {(detail.alert.confidence * 100).toFixed(0)}%
                  </div>
                  <ul className="mt-3 space-y-1.5 text-xs leading-relaxed opacity-90">
                    {detail.alert.top_reasons.map((r, i) => (
                      <li key={i}>• {r.text}</li>
                    ))}
                  </ul>
                </div>
              )}

              {detail.graph_features && (
                <section>
                  <h3 className="mb-2 text-xs font-semibold uppercase tracking-wide text-ink-500">Graph Features</h3>
                  <div className="grid grid-cols-2 gap-2 text-xs">
                    {Object.entries(detail.graph_features)
                      .filter(([k]) => k !== "address")
                      .map(([k, v]) => (
                        <div key={k} className="rounded-lg bg-base-800 px-2.5 py-2">
                          <div className="text-ink-500">{k.replace(/_/g, " ")}</div>
                          <div className="mono-tabular text-ink-100">{String(v)}</div>
                        </div>
                      ))}
                  </div>
                </section>
              )}

              <section>
                <h3 className="mb-2 text-xs font-semibold uppercase tracking-wide text-ink-500">
                  Associated Network
                </h3>
                <div className="flex flex-wrap gap-1.5">
                  {detail.associated_ips.length === 0 && <span className="text-xs text-ink-600">none</span>}
                  {detail.associated_ips.map((ip) => (
                    <span key={ip} className="rounded bg-base-800 px-2 py-1 font-mono text-[11px] text-ink-300">
                      {ip}
                    </span>
                  ))}
                </div>
              </section>

              {detail.counterparties.length > 0 && (
                <section>
                  <h3 className="mb-2 text-xs font-semibold uppercase tracking-wide text-ink-500">
                    Counterparties ({detail.counterparties.length})
                  </h3>
                  <div className="max-h-40 space-y-1 overflow-y-auto">
                    {detail.counterparties.map((c) => (
                      <button
                        key={c}
                        onClick={() => onNavigate(c)}
                        className="block w-full truncate rounded-lg px-2 py-1.5 text-left font-mono text-[11px] text-ink-400 hover:bg-base-800 hover:text-signal-teal"
                      >
                        {c}
                      </button>
                    ))}
                  </div>
                </section>
              )}

              <section>
                <h3 className="mb-2 text-xs font-semibold uppercase tracking-wide text-ink-500">
                  Transactions ({detail.transactions.length})
                </h3>
                <div className="space-y-2">
                  {detail.transactions.slice(0, 20).map((tx) => (
                    <div key={tx.txid} className="rounded-lg bg-base-800 px-3 py-2 text-[11px]">
                      <div className="flex items-center justify-between">
                        <span className="truncate font-mono text-ink-300">{tx.txid.slice(0, 16)}…</span>
                        <span className="mono-tabular text-ink-500">{tx.timestamp.replace("T", " ")}</span>
                      </div>
                      <div className="mt-1 flex items-center justify-between text-ink-500">
                        <span>
                          {tx.num_inputs}→{tx.num_outputs} · {tx.script_type}
                        </span>
                        <span className="mono-tabular text-ink-300">
                          {tx.total_output.toFixed(6)} BTC · fee {tx.fee.toFixed(6)}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
