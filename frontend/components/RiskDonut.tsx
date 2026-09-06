"use client";

import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from "recharts";

export default function RiskDonut({ high, medium, low }: { high: number; medium: number; low: number }) {
  const total = high + medium + low;
  const data = [
    { name: "High", value: high, color: "#f43f5e" },
    { name: "Medium", value: medium, color: "#f5a524" },
    { name: "Low", value: low, color: "#2dd4bf" },
  ];

  return (
    <div className="card p-4">
      <div className="mb-2 text-sm font-medium text-ink-300">Risk Distribution</div>
      {total === 0 ? (
        <div className="flex h-48 items-center justify-center text-sm text-ink-500">No alerts yet</div>
      ) : (
        <div className="relative h-48">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={data}
                dataKey="value"
                nameKey="name"
                innerRadius={55}
                outerRadius={78}
                paddingAngle={3}
                strokeWidth={0}
              >
                {data.map((d) => (
                  <Cell key={d.name} fill={d.color} />
                ))}
              </Pie>
              <Tooltip
                contentStyle={{
                  background: "#111826",
                  border: "1px solid #1e2a3d",
                  borderRadius: 8,
                  fontSize: 12,
                }}
                itemStyle={{ color: "#e8edf5" }}
              />
            </PieChart>
          </ResponsiveContainer>
          <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center">
            <div className="mono-tabular text-2xl font-semibold text-ink-100">{total}</div>
            <div className="text-xs text-ink-500">alerts</div>
          </div>
        </div>
      )}
      <div className="mt-2 flex justify-center gap-4 text-xs">
        {data.map((d) => (
          <div key={d.name} className="flex items-center gap-1.5">
            <span className="h-2 w-2 rounded-full" style={{ background: d.color }} />
            <span className="text-ink-500">
              {d.name} <span className="mono-tabular text-ink-300">{d.value}</span>
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
