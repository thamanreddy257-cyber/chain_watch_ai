"use client";

import { Area, AreaChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

export default function VolumeChart({ data }: { data: { bucket: string; count: number }[] }) {
  const chartData = data.map((d) => ({ ...d, label: d.bucket.slice(11) + ":00" }));

  return (
    <div className="card p-4">
      <div className="mb-2 text-sm font-medium text-ink-300">Transaction Volume</div>
      {chartData.length === 0 ? (
        <div className="flex h-48 items-center justify-center text-sm text-ink-500">No data yet</div>
      ) : (
        <ResponsiveContainer width="100%" height={192}>
          <AreaChart data={chartData} margin={{ top: 8, right: 8, left: -20, bottom: 0 }}>
            <defs>
              <linearGradient id="volumeFill" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#2dd4bf" stopOpacity={0.35} />
                <stop offset="100%" stopColor="#2dd4bf" stopOpacity={0} />
              </linearGradient>
            </defs>
            <XAxis
              dataKey="label"
              tick={{ fill: "#5a677c", fontSize: 11 }}
              axisLine={{ stroke: "#1e2a3d" }}
              tickLine={false}
            />
            <YAxis tick={{ fill: "#5a677c", fontSize: 11 }} axisLine={false} tickLine={false} width={32} />
            <Tooltip
              contentStyle={{ background: "#111826", border: "1px solid #1e2a3d", borderRadius: 8, fontSize: 12 }}
              labelStyle={{ color: "#aeb9c9" }}
              itemStyle={{ color: "#2dd4bf" }}
            />
            <Area type="monotone" dataKey="count" stroke="#2dd4bf" strokeWidth={2} fill="url(#volumeFill)" />
          </AreaChart>
        </ResponsiveContainer>
      )}
    </div>
  );
}
