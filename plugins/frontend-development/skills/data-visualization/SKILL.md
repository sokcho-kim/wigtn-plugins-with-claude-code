---
name: data-visualization
description: Build interactive charts and dashboards with Recharts, Chart.js, and D3. Includes line charts, bar charts, pie charts, area charts, real-time streaming charts, and dashboard widget patterns. Use when creating data visualizations, analytics dashboards, or reporting interfaces.
disable-model-invocation: true
---

# Data Visualization

Comprehensive patterns for building interactive charts, graphs, and dashboards using modern React charting libraries. Covers Recharts, Chart.js, and D3 integration with real-time data streaming support.

## When to Use This Skill

- Building analytics dashboards
- Creating interactive charts and graphs
- Visualizing real-time data streams
- Building reporting interfaces
- Implementing KPI widgets and metrics displays

## Library Comparison

| Feature | Recharts | Chart.js | D3.js |
|---------|----------|----------|-------|
| **Learning Curve** | Easy | Medium | Steep |
| **React Integration** | Native | Wrapper | Manual |
| **Customization** | High | Medium | Unlimited |
| **Bundle Size** | ~200kb | ~60kb | ~240kb |
| **Animations** | Built-in | Built-in | Manual |
| **Best For** | React apps | Simple charts | Complex viz |

## Quick Start

### Installation

```bash
# Recharts (Recommended for React)
npm install recharts

# Chart.js with React
npm install chart.js react-chartjs-2

# D3 (for advanced visualizations)
npm install d3 @types/d3
```

---

## Recharts Patterns

### 1. Line Chart

```typescript
// components/charts/line-chart.tsx
"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

interface DataPoint {
  name: string;
  value: number;
  value2?: number;
}

interface LineChartProps {
  data: DataPoint[];
  title?: string;
  height?: number;
  showGrid?: boolean;
  colors?: string[];
}

export function CustomLineChart({
  data,
  title,
  height = 300,
  showGrid = true,
  colors = ["#8884d8", "#82ca9d"],
}: LineChartProps) {
  return (
    <div className="w-full">
      {title && <h3 className="mb-4 text-lg font-semibold">{title}</h3>}
      <ResponsiveContainer width="100%" height={height}>
        <LineChart
          data={data}
          margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
        >
          {showGrid && <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />}
          <XAxis
            dataKey="name"
            tick={{ fill: "#666", fontSize: 12 }}
            tickLine={{ stroke: "#666" }}
          />
          <YAxis
            tick={{ fill: "#666", fontSize: 12 }}
            tickLine={{ stroke: "#666" }}
            tickFormatter={(value) => value.toLocaleString()}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: "#fff",
              border: "1px solid #ccc",
              borderRadius: "8px",
            }}
            formatter={(value: number) => [value.toLocaleString(), "Value"]}
          />
          <Legend />
          <Line
            type="monotone"
            dataKey="value"
            stroke={colors[0]}
            strokeWidth={2}
            dot={{ fill: colors[0], strokeWidth: 2, r: 4 }}
            activeDot={{ r: 6, strokeWidth: 2 }}
          />
          {data[0]?.value2 !== undefined && (
            <Line
              type="monotone"
              dataKey="value2"
              stroke={colors[1]}
              strokeWidth={2}
              dot={{ fill: colors[1], strokeWidth: 2, r: 4 }}
            />
          )}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
```

### 2. Bar Chart

```typescript
// components/charts/bar-chart.tsx
"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Cell,
} from "recharts";

interface BarChartProps {
  data: Array<{ name: string; value: number; color?: string }>;
  title?: string;
  height?: number;
  layout?: "horizontal" | "vertical";
  stacked?: boolean;
  showValues?: boolean;
}

const COLORS = ["#0088FE", "#00C49F", "#FFBB28", "#FF8042", "#8884d8"];

export function CustomBarChart({
  data,
  title,
  height = 300,
  layout = "horizontal",
  showValues = false,
}: BarChartProps) {
  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="rounded-lg border bg-white p-3 shadow-lg">
          <p className="font-medium">{label}</p>
          <p className="text-sm text-gray-600">
            Value: {payload[0].value.toLocaleString()}
          </p>
        </div>
      );
    }
    return null;
  };

  return (
    <div className="w-full">
      {title && <h3 className="mb-4 text-lg font-semibold">{title}</h3>}
      <ResponsiveContainer width="100%" height={height}>
        <BarChart
          data={data}
          layout={layout === "vertical" ? "vertical" : "horizontal"}
          margin={{ top: 20, right: 30, left: 20, bottom: 5 }}
        >
          <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
          {layout === "vertical" ? (
            <>
              <XAxis type="number" />
              <YAxis dataKey="name" type="category" width={80} />
            </>
          ) : (
            <>
              <XAxis dataKey="name" />
              <YAxis />
            </>
          )}
          <Tooltip content={<CustomTooltip />} />
          <Legend />
          <Bar
            dataKey="value"
            radius={[4, 4, 0, 0]}
            label={showValues ? { position: "top", fontSize: 12 } : false}
          >
            {data.map((entry, index) => (
              <Cell
                key={`cell-${index}`}
                fill={entry.color || COLORS[index % COLORS.length]}
              />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

// Stacked Bar Chart
export function StackedBarChart({
  data,
  keys,
  colors,
}: {
  data: any[];
  keys: string[];
  colors: string[];
}) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart data={data}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip />
        <Legend />
        {keys.map((key, index) => (
          <Bar
            key={key}
            dataKey={key}
            stackId="a"
            fill={colors[index]}
            radius={index === keys.length - 1 ? [4, 4, 0, 0] : [0, 0, 0, 0]}
          />
        ))}
      </BarChart>
    </ResponsiveContainer>
  );
}
```

### 3. Pie / Donut Chart

```typescript
// components/charts/pie-chart.tsx
"use client";

import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from "recharts";

interface PieChartProps {
  data: Array<{ name: string; value: number; color?: string }>;
  title?: string;
  height?: number;
  donut?: boolean;
  showLabels?: boolean;
}

const COLORS = ["#0088FE", "#00C49F", "#FFBB28", "#FF8042", "#8884d8", "#82ca9d"];

export function CustomPieChart({
  data,
  title,
  height = 300,
  donut = false,
  showLabels = true,
}: PieChartProps) {
  const total = data.reduce((sum, item) => sum + item.value, 0);

  const renderCustomLabel = ({
    cx,
    cy,
    midAngle,
    innerRadius,
    outerRadius,
    percent,
    name,
  }: any) => {
    const RADIAN = Math.PI / 180;
    const radius = innerRadius + (outerRadius - innerRadius) * 1.4;
    const x = cx + radius * Math.cos(-midAngle * RADIAN);
    const y = cy + radius * Math.sin(-midAngle * RADIAN);

    if (percent < 0.05) return null;

    return (
      <text
        x={x}
        y={y}
        fill="#666"
        textAnchor={x > cx ? "start" : "end"}
        dominantBaseline="central"
        fontSize={12}
      >
        {`${name} (${(percent * 100).toFixed(0)}%)`}
      </text>
    );
  };

  return (
    <div className="w-full">
      {title && <h3 className="mb-4 text-lg font-semibold">{title}</h3>}
      <ResponsiveContainer width="100%" height={height}>
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            labelLine={showLabels}
            label={showLabels ? renderCustomLabel : false}
            outerRadius={donut ? 100 : 80}
            innerRadius={donut ? 60 : 0}
            dataKey="value"
            animationBegin={0}
            animationDuration={800}
          >
            {data.map((entry, index) => (
              <Cell
                key={`cell-${index}`}
                fill={entry.color || COLORS[index % COLORS.length]}
                stroke="#fff"
                strokeWidth={2}
              />
            ))}
          </Pie>
          <Tooltip
            formatter={(value: number) => [
              `${value.toLocaleString()} (${((value / total) * 100).toFixed(1)}%)`,
              "Value",
            ]}
          />
          {!showLabels && <Legend />}
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}

// Donut with center text
export function DonutWithCenter({
  data,
  centerText,
  centerValue,
}: {
  data: Array<{ name: string; value: number }>;
  centerText: string;
  centerValue: string | number;
}) {
  return (
    <div className="relative">
      <ResponsiveContainer width="100%" height={250}>
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            innerRadius={60}
            outerRadius={80}
            dataKey="value"
          >
            {data.map((_, index) => (
              <Cell key={index} fill={COLORS[index % COLORS.length]} />
            ))}
          </Pie>
          <Tooltip />
        </PieChart>
      </ResponsiveContainer>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-2xl font-bold">{centerValue}</span>
        <span className="text-sm text-gray-500">{centerText}</span>
      </div>
    </div>
  );
}
```

### 4. Area Chart

```typescript
// components/charts/area-chart.tsx
"use client";

import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";

interface AreaChartProps {
  data: any[];
  areas: Array<{
    dataKey: string;
    color: string;
    name?: string;
  }>;
  title?: string;
  height?: number;
  stacked?: boolean;
  gradient?: boolean;
}

export function CustomAreaChart({
  data,
  areas,
  title,
  height = 300,
  stacked = false,
  gradient = true,
}: AreaChartProps) {
  return (
    <div className="w-full">
      {title && <h3 className="mb-4 text-lg font-semibold">{title}</h3>}
      <ResponsiveContainer width="100%" height={height}>
        <AreaChart data={data} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
          <defs>
            {areas.map((area) => (
              <linearGradient
                key={area.dataKey}
                id={`gradient-${area.dataKey}`}
                x1="0"
                y1="0"
                x2="0"
                y2="1"
              >
                <stop offset="5%" stopColor={area.color} stopOpacity={0.8} />
                <stop offset="95%" stopColor={area.color} stopOpacity={0.1} />
              </linearGradient>
            ))}
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
          <XAxis dataKey="name" tick={{ fontSize: 12 }} />
          <YAxis tick={{ fontSize: 12 }} />
          <Tooltip />
          <Legend />
          {areas.map((area) => (
            <Area
              key={area.dataKey}
              type="monotone"
              dataKey={area.dataKey}
              name={area.name || area.dataKey}
              stroke={area.color}
              fill={gradient ? `url(#gradient-${area.dataKey})` : area.color}
              fillOpacity={gradient ? 1 : 0.3}
              stackId={stacked ? "1" : undefined}
            />
          ))}
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
```

### 5. Radar Chart

```typescript
// components/charts/radar-chart.tsx
"use client";

import {
  Radar,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  ResponsiveContainer,
  Legend,
  Tooltip,
} from "recharts";

interface RadarChartProps {
  data: Array<{ subject: string; [key: string]: string | number }>;
  dataKeys: Array<{ key: string; color: string; name?: string }>;
  title?: string;
  height?: number;
}

export function CustomRadarChart({
  data,
  dataKeys,
  title,
  height = 300,
}: RadarChartProps) {
  return (
    <div className="w-full">
      {title && <h3 className="mb-4 text-lg font-semibold">{title}</h3>}
      <ResponsiveContainer width="100%" height={height}>
        <RadarChart data={data}>
          <PolarGrid stroke="#e0e0e0" />
          <PolarAngleAxis dataKey="subject" tick={{ fontSize: 12 }} />
          <PolarRadiusAxis angle={30} domain={[0, 100]} tick={{ fontSize: 10 }} />
          {dataKeys.map(({ key, color, name }) => (
            <Radar
              key={key}
              name={name || key}
              dataKey={key}
              stroke={color}
              fill={color}
              fillOpacity={0.3}
            />
          ))}
          <Legend />
          <Tooltip />
        </RadarChart>
      </ResponsiveContainer>
    </div>
  );
}
```

---

## Real-Time Streaming Charts

### 1. Live Line Chart

```typescript
// components/charts/live-line-chart.tsx
"use client";

import { useState, useEffect, useCallback } from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer,
} from "recharts";

interface DataPoint {
  time: string;
  value: number;
}

interface LiveLineChartProps {
  maxPoints?: number;
  updateInterval?: number;
  fetchData: () => Promise<number>;
}

export function LiveLineChart({
  maxPoints = 20,
  updateInterval = 1000,
  fetchData,
}: LiveLineChartProps) {
  const [data, setData] = useState<DataPoint[]>([]);
  const [isPaused, setIsPaused] = useState(false);

  const addDataPoint = useCallback(async () => {
    const value = await fetchData();
    const time = new Date().toLocaleTimeString();

    setData((prev) => {
      const newData = [...prev, { time, value }];
      return newData.slice(-maxPoints);
    });
  }, [fetchData, maxPoints]);

  useEffect(() => {
    if (isPaused) return;

    const interval = setInterval(addDataPoint, updateInterval);
    return () => clearInterval(interval);
  }, [addDataPoint, updateInterval, isPaused]);

  return (
    <div className="w-full">
      <div className="mb-4 flex items-center justify-between">
        <h3 className="text-lg font-semibold">Live Data</h3>
        <button
          onClick={() => setIsPaused(!isPaused)}
          className="rounded bg-gray-200 px-3 py-1 text-sm hover:bg-gray-300"
        >
          {isPaused ? "Resume" : "Pause"}
        </button>
      </div>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="time" tick={{ fontSize: 10 }} />
          <YAxis domain={["auto", "auto"]} />
          <Line
            type="monotone"
            dataKey="value"
            stroke="#8884d8"
            strokeWidth={2}
            dot={false}
            isAnimationActive={false}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}

// Usage
function Dashboard() {
  const fetchMetric = async () => {
    // Simulate API call
    return Math.random() * 100;
  };

  return <LiveLineChart fetchData={fetchMetric} updateInterval={2000} />;
}
```

### 2. WebSocket Streaming Chart

```typescript
// components/charts/websocket-chart.tsx
"use client";

import { useState, useEffect, useRef } from "react";
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer } from "recharts";

interface StreamingChartProps {
  wsUrl: string;
  maxPoints?: number;
}

export function WebSocketChart({ wsUrl, maxPoints = 50 }: StreamingChartProps) {
  const [data, setData] = useState<Array<{ time: number; value: number }>>([]);
  const [isConnected, setIsConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);

  useEffect(() => {
    const ws = new WebSocket(wsUrl);
    wsRef.current = ws;

    ws.onopen = () => {
      setIsConnected(true);
      console.log("WebSocket connected");
    };

    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      setData((prev) => {
        const newData = [
          ...prev,
          { time: Date.now(), value: message.value },
        ];
        return newData.slice(-maxPoints);
      });
    };

    ws.onclose = () => {
      setIsConnected(false);
      console.log("WebSocket disconnected");
    };

    ws.onerror = (error) => {
      console.error("WebSocket error:", error);
    };

    return () => {
      ws.close();
    };
  }, [wsUrl, maxPoints]);

  return (
    <div className="w-full">
      <div className="mb-2 flex items-center gap-2">
        <div
          className={`h-2 w-2 rounded-full ${
            isConnected ? "bg-green-500" : "bg-red-500"
          }`}
        />
        <span className="text-sm text-gray-500">
          {isConnected ? "Connected" : "Disconnected"}
        </span>
      </div>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <XAxis
            dataKey="time"
            type="number"
            domain={["auto", "auto"]}
            tickFormatter={(t) => new Date(t).toLocaleTimeString()}
          />
          <YAxis domain={["auto", "auto"]} />
          <Line
            type="monotone"
            dataKey="value"
            stroke="#82ca9d"
            strokeWidth={2}
            dot={false}
            isAnimationActive={false}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
```

---

## Dashboard Widgets

### 1. KPI Card

```typescript
// components/dashboard/kpi-card.tsx
import { ArrowUp, ArrowDown, Minus } from "lucide-react";

interface KPICardProps {
  title: string;
  value: string | number;
  change?: number;
  changeLabel?: string;
  icon?: React.ReactNode;
  trend?: "up" | "down" | "neutral";
  loading?: boolean;
}

export function KPICard({
  title,
  value,
  change,
  changeLabel = "vs last period",
  icon,
  trend,
  loading = false,
}: KPICardProps) {
  const getTrendColor = () => {
    if (trend === "up") return "text-green-600 bg-green-100";
    if (trend === "down") return "text-red-600 bg-red-100";
    return "text-gray-600 bg-gray-100";
  };

  const getTrendIcon = () => {
    if (trend === "up") return <ArrowUp className="h-4 w-4" />;
    if (trend === "down") return <ArrowDown className="h-4 w-4" />;
    return <Minus className="h-4 w-4" />;
  };

  if (loading) {
    return (
      <div className="rounded-lg border bg-white p-6 shadow-sm">
        <div className="animate-pulse">
          <div className="mb-2 h-4 w-24 rounded bg-gray-200" />
          <div className="h-8 w-32 rounded bg-gray-200" />
        </div>
      </div>
    );
  }

  return (
    <div className="rounded-lg border bg-white p-6 shadow-sm transition-shadow hover:shadow-md">
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-gray-500">{title}</span>
        {icon && <span className="text-gray-400">{icon}</span>}
      </div>
      <div className="mt-2">
        <span className="text-3xl font-bold text-gray-900">{value}</span>
      </div>
      {change !== undefined && (
        <div className="mt-2 flex items-center gap-2">
          <span
            className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium ${getTrendColor()}`}
          >
            {getTrendIcon()}
            {Math.abs(change)}%
          </span>
          <span className="text-xs text-gray-500">{changeLabel}</span>
        </div>
      )}
    </div>
  );
}
```

### 2. Sparkline

```typescript
// components/dashboard/sparkline.tsx
"use client";

import { LineChart, Line, ResponsiveContainer } from "recharts";

interface SparklineProps {
  data: number[];
  color?: string;
  height?: number;
}

export function Sparkline({
  data,
  color = "#8884d8",
  height = 40,
}: SparklineProps) {
  const chartData = data.map((value, index) => ({ value, index }));

  return (
    <ResponsiveContainer width="100%" height={height}>
      <LineChart data={chartData}>
        <Line
          type="monotone"
          dataKey="value"
          stroke={color}
          strokeWidth={2}
          dot={false}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

### 3. Progress Ring

```typescript
// components/dashboard/progress-ring.tsx
interface ProgressRingProps {
  progress: number;
  size?: number;
  strokeWidth?: number;
  color?: string;
  bgColor?: string;
  children?: React.ReactNode;
}

export function ProgressRing({
  progress,
  size = 120,
  strokeWidth = 8,
  color = "#8884d8",
  bgColor = "#e0e0e0",
  children,
}: ProgressRingProps) {
  const radius = (size - strokeWidth) / 2;
  const circumference = radius * 2 * Math.PI;
  const strokeDashoffset = circumference - (progress / 100) * circumference;

  return (
    <div className="relative inline-flex items-center justify-center">
      <svg width={size} height={size} className="-rotate-90 transform">
        {/* Background circle */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke={bgColor}
          strokeWidth={strokeWidth}
        />
        {/* Progress circle */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke={color}
          strokeWidth={strokeWidth}
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          strokeLinecap="round"
          className="transition-all duration-500 ease-out"
        />
      </svg>
      <div className="absolute flex flex-col items-center justify-center">
        {children || <span className="text-2xl font-bold">{progress}%</span>}
      </div>
    </div>
  );
}
```

### 4. Mini Stats Grid

```typescript
// components/dashboard/stats-grid.tsx
import { KPICard } from "./kpi-card";
import { Sparkline } from "./sparkline";

interface StatItem {
  title: string;
  value: string | number;
  change: number;
  trend: "up" | "down" | "neutral";
  sparklineData: number[];
}

interface StatsGridProps {
  stats: StatItem[];
}

export function StatsGrid({ stats }: StatsGridProps) {
  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
      {stats.map((stat, index) => (
        <div key={index} className="rounded-lg border bg-white p-4 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-gray-500">
              {stat.title}
            </span>
            <span
              className={`text-xs font-medium ${
                stat.trend === "up"
                  ? "text-green-600"
                  : stat.trend === "down"
                  ? "text-red-600"
                  : "text-gray-600"
              }`}
            >
              {stat.change > 0 ? "+" : ""}
              {stat.change}%
            </span>
          </div>
          <div className="mt-2 text-2xl font-bold">{stat.value}</div>
          <div className="mt-2">
            <Sparkline
              data={stat.sparklineData}
              color={stat.trend === "up" ? "#22c55e" : "#ef4444"}
              height={30}
            />
          </div>
        </div>
      ))}
    </div>
  );
}
```

---

## Chart.js Patterns

### Setup with React

```typescript
// components/charts/chartjs-setup.tsx
"use client";

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from "chart.js";

// Register Chart.js components
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

export { ChartJS };
```

### Chart.js Line Chart

```typescript
// components/charts/chartjs-line.tsx
"use client";

import { Line } from "react-chartjs-2";
import type { ChartData, ChartOptions } from "chart.js";

interface ChartJSLineProps {
  labels: string[];
  datasets: Array<{
    label: string;
    data: number[];
    borderColor: string;
    backgroundColor?: string;
  }>;
  title?: string;
}

export function ChartJSLine({ labels, datasets, title }: ChartJSLineProps) {
  const data: ChartData<"line"> = {
    labels,
    datasets: datasets.map((ds) => ({
      ...ds,
      tension: 0.4,
      fill: true,
      backgroundColor: ds.backgroundColor || `${ds.borderColor}20`,
    })),
  };

  const options: ChartOptions<"line"> = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: "top" as const,
      },
      title: {
        display: !!title,
        text: title,
      },
    },
    scales: {
      y: {
        beginAtZero: true,
      },
    },
  };

  return (
    <div className="h-[300px] w-full">
      <Line data={data} options={options} />
    </div>
  );
}
```

---

## Complete Dashboard Example

```typescript
// app/dashboard/page.tsx
"use client";

import { useState, useEffect } from "react";
import { KPICard } from "@/components/dashboard/kpi-card";
import { CustomLineChart } from "@/components/charts/line-chart";
import { CustomBarChart } from "@/components/charts/bar-chart";
import { CustomPieChart } from "@/components/charts/pie-chart";
import { StatsGrid } from "@/components/dashboard/stats-grid";
import { DollarSign, Users, ShoppingCart, TrendingUp } from "lucide-react";

export default function DashboardPage() {
  const [data, setData] = useState({
    revenue: [],
    sales: [],
    categories: [],
    stats: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fetch dashboard data
    async function fetchData() {
      // Replace with actual API call
      setData({
        revenue: [
          { name: "Jan", value: 4000 },
          { name: "Feb", value: 3000 },
          { name: "Mar", value: 5000 },
          { name: "Apr", value: 4500 },
          { name: "May", value: 6000 },
          { name: "Jun", value: 5500 },
        ],
        sales: [
          { name: "Product A", value: 400 },
          { name: "Product B", value: 300 },
          { name: "Product C", value: 200 },
          { name: "Product D", value: 278 },
        ],
        categories: [
          { name: "Electronics", value: 400 },
          { name: "Clothing", value: 300 },
          { name: "Home", value: 200 },
          { name: "Other", value: 100 },
        ],
        stats: [
          {
            title: "Page Views",
            value: "24.5K",
            change: 12,
            trend: "up" as const,
            sparklineData: [10, 15, 12, 18, 20, 22, 24],
          },
          // ... more stats
        ],
      });
      setLoading(false);
    }

    fetchData();
  }, []);

  return (
    <div className="space-y-6 p-6">
      <h1 className="text-2xl font-bold">Dashboard</h1>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
        <KPICard
          title="Total Revenue"
          value="$45,231"
          change={12.5}
          trend="up"
          icon={<DollarSign className="h-5 w-5" />}
          loading={loading}
        />
        <KPICard
          title="Active Users"
          value="2,345"
          change={-5.2}
          trend="down"
          icon={<Users className="h-5 w-5" />}
          loading={loading}
        />
        <KPICard
          title="Orders"
          value="1,234"
          change={8.1}
          trend="up"
          icon={<ShoppingCart className="h-5 w-5" />}
          loading={loading}
        />
        <KPICard
          title="Conversion"
          value="3.2%"
          change={0}
          trend="neutral"
          icon={<TrendingUp className="h-5 w-5" />}
          loading={loading}
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div className="rounded-lg border bg-white p-4 shadow-sm">
          <CustomLineChart
            data={data.revenue}
            title="Revenue Over Time"
            height={300}
          />
        </div>
        <div className="rounded-lg border bg-white p-4 shadow-sm">
          <CustomBarChart
            data={data.sales}
            title="Sales by Product"
            height={300}
          />
        </div>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="rounded-lg border bg-white p-4 shadow-sm lg:col-span-2">
          <StatsGrid stats={data.stats} />
        </div>
        <div className="rounded-lg border bg-white p-4 shadow-sm">
          <CustomPieChart
            data={data.categories}
            title="Sales by Category"
            donut
            height={250}
          />
        </div>
      </div>
    </div>
  );
}
```

---

## Best Practices

### Do's
- Use `ResponsiveContainer` for responsive charts
- Disable animations for real-time charts (`isAnimationActive={false}`)
- Use proper color contrast for accessibility
- Memoize chart data to prevent unnecessary re-renders
- Add loading states for async data
- Use tooltips for detailed information

### Don'ts
- Don't overload charts with too many data points
- Don't use 3D effects (hard to read)
- Don't use too many colors
- Don't forget axis labels
- Don't ignore mobile responsiveness
- Don't animate real-time data

## Accessibility

- Provide text alternatives for charts
- Use high contrast colors
- Support keyboard navigation where possible
- Include data tables as alternatives
- Test with screen readers
