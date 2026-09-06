"use client";

export default function SearchResults({
  results,
  onSelect,
  onClose,
}: {
  results: { wallets: string[]; ips: string[]; txids: string[] };
  onSelect: (id: string) => void;
  onClose: () => void;
}) {
  const groups: { label: string; items: string[] }[] = [
    { label: "Wallets", items: results.wallets },
    { label: "Transactions", items: results.txids },
    { label: "IP Addresses", items: results.ips },
  ].filter((g) => g.items.length > 0);

  return (
    <div className="fixed inset-0 z-30 bg-black/50 backdrop-blur-sm" onClick={onClose}>
      <div
        className="mx-auto mt-24 w-full max-w-lg overflow-hidden rounded-xl border border-base-700 bg-base-900 shadow-2xl animate-fade-in"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="border-b border-base-700 px-4 py-3 text-sm font-medium text-ink-300">Search Results</div>
        <div className="max-h-96 overflow-y-auto p-2">
          {groups.length === 0 ? (
            <div className="p-6 text-center text-sm text-ink-500">No matches found</div>
          ) : (
            groups.map((g) => (
              <div key={g.label} className="mb-2">
                <div className="px-2 py-1 text-[11px] font-semibold uppercase tracking-wide text-ink-500">
                  {g.label}
                </div>
                {g.items.map((item) => (
                  <button
                    key={item}
                    onClick={() => onSelect(item)}
                    className="block w-full truncate rounded-lg px-2 py-2 text-left font-mono text-xs text-ink-300 hover:bg-base-800 hover:text-signal-teal"
                  >
                    {item}
                  </button>
                ))}
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
