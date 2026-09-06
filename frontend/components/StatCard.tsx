import type { LucideIcon } from "lucide-react";

export default function StatCard({
  label,
  value,
  icon: Icon,
  accent = "teal",
}: {
  label: string;
  value: string | number;
  icon: LucideIcon;
  accent?: "teal" | "blue" | "amber" | "red";
}) {
  const accentClass = {
    teal: "text-signal-teal bg-signal-teal/10",
    blue: "text-signal-blue bg-signal-blue/10",
    amber: "text-signal-amber bg-signal-amber/10",
    red: "text-signal-red bg-signal-red/10",
  }[accent];

  return (
    <div className="card flex items-center gap-3 p-4">
      <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${accentClass}`}>
        <Icon size={18} strokeWidth={2} />
      </div>
      <div className="min-w-0">
        <div className="truncate text-xs font-medium text-ink-500">{label}</div>
        <div className="mono-tabular text-xl font-semibold text-ink-100">{value}</div>
      </div>
    </div>
  );
}
