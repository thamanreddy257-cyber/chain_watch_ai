"use client";

import { Loader2, PlayCircle, Radar, Search, Share2, UploadCloud } from "lucide-react";
import { useState } from "react";

export default function PipelineBar({
  onRunFull,
  onIngest,
  onBuildGraph,
  onDetect,
  onSearch,
  running,
}: {
  onRunFull: () => Promise<void>;
  onIngest: () => Promise<void>;
  onBuildGraph: () => Promise<void>;
  onDetect: () => Promise<void>;
  onSearch: (q: string) => void;
  running: boolean;
}) {
  const [query, setQuery] = useState("");

  return (
    <div className="sticky top-0 z-20 border-b border-base-700 bg-base-950/85 backdrop-blur">
      <div className="mx-auto flex max-w-[1400px] flex-wrap items-center gap-3 px-6 py-4">
        <div className="flex items-center gap-2.5">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-signal-teal/15 text-signal-teal shadow-glow">
            <Radar size={18} strokeWidth={2.2} />
          </div>
          <div>
            <div className="text-sm font-semibold leading-tight text-ink-100">ChainWatch AI</div>
            <div className="text-[11px] leading-tight text-ink-500">Offline Bitcoin Traffic Correlation</div>
          </div>
        </div>

        <div className="relative ml-2 min-w-[220px] flex-1">
          <Search size={15} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-500" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && query.trim().length >= 2) onSearch(query.trim());
            }}
            placeholder="Search wallet, txid, or IP…"
            className="w-full rounded-lg border border-base-700 bg-base-900 py-2 pl-9 pr-3 text-sm text-ink-100 placeholder:text-ink-600 focus:border-signal-teal/50 focus:outline-none focus:ring-1 focus:ring-signal-teal/30"
          />
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={onIngest}
            disabled={running}
            title="Re-ingest synthetic/uploaded dataset"
            className="flex items-center gap-1.5 rounded-lg border border-base-700 bg-base-900 px-3 py-2 text-xs font-medium text-ink-300 transition hover:border-base-600 hover:text-ink-100 disabled:opacity-40"
          >
            <UploadCloud size={14} /> Ingest
          </button>
          <button
            onClick={onBuildGraph}
            disabled={running}
            title="Rebuild entity graph"
            className="flex items-center gap-1.5 rounded-lg border border-base-700 bg-base-900 px-3 py-2 text-xs font-medium text-ink-300 transition hover:border-base-600 hover:text-ink-100 disabled:opacity-40"
          >
            <Share2 size={14} /> Graph
          </button>
          <button
            onClick={onDetect}
            disabled={running}
            title="Run anomaly detection"
            className="flex items-center gap-1.5 rounded-lg border border-base-700 bg-base-900 px-3 py-2 text-xs font-medium text-ink-300 transition hover:border-base-600 hover:text-ink-100 disabled:opacity-40"
          >
            <Radar size={14} /> Detect
          </button>
          <button
            onClick={onRunFull}
            disabled={running}
            className="flex items-center gap-1.5 rounded-lg bg-signal-teal px-3.5 py-2 text-xs font-semibold text-base-950 shadow-glow transition hover:bg-signal-teal/90 disabled:opacity-50"
          >
            {running ? <Loader2 size={14} className="animate-spin" /> : <PlayCircle size={14} />}
            {running ? "Running…" : "Run Full Pipeline"}
          </button>
        </div>
      </div>
    </div>
  );
}
