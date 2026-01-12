---
name: charts
description: Recharts patterns for admin dashboards, data visualization. Use when building charts and graphs.
---

# Charts

Recharts를 사용한 데이터 시각화 패턴입니다.

## Basic Setup

```typescript
// components/charts/base-chart.tsx
'use client';

import {
  ResponsiveContainer,
  Tooltip,
  Legend,
  TooltipProps,
} from 'recharts';

// Common tooltip styling
export function ChartTooltip({ active, payload, label }: TooltipProps<any, any>) {
  if (!active || !payload?.length) return null;

  return (
    <div className="rounded-lg border bg-background p-2 shadow-sm">
      <p className="text-sm font-medium">{label}</p>
      {payload.map((item, index) => (
        <p key={index} className="text-sm" style={{ color: item.color }}>
          {item.name}: {item.value.toLocaleString()}
        </p>
      ))}
    </div>
  );
}
```

## Line Chart

```typescript
// components/charts/line-chart.tsx
'use client';

import {
  LineChart as RechartsLineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';

interface LineChartProps {
  data: Array<Record<string, any>>;
  xKey: string;
  lines: Array<{
    dataKey: string;
    name: string;
    color: string;
  }>;
  height?: number;
}

export function LineChart({
  data,
  xKey,
  lines,
  height = 350,
}: LineChartProps) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <RechartsLineChart
        data={data}
        margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
      >
        <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
        <XAxis
          dataKey={xKey}
          tick={{ fontSize: 12 }}
          tickLine={false}
          axisLine={false}
        />
        <YAxis
          tick={{ fontSize: 12 }}
          tickLine={false}
          axisLine={false}
          tickFormatter={(value) => value.toLocaleString()}
        />
        <Tooltip content={<ChartTooltip />} />
        <Legend />
        {lines.map((line) => (
          <Line
            key={line.dataKey}
            type="monotone"
            dataKey={line.dataKey}
            name={line.name}
            stroke={line.color}
            strokeWidth={2}
            dot={false}
            activeDot={{ r: 6 }}
          />
        ))}
      </RechartsLineChart>
    </ResponsiveContainer>
  );
}

// Usage
<LineChart
  data={salesData}
  xKey="date"
  lines={[
    { dataKey: 'revenue', name: 'Revenue', color: '#8884d8' },
    { dataKey: 'orders', name: 'Orders', color: '#82ca9d' },
  ]}
/>
```

## Bar Chart

```typescript
// components/charts/bar-chart.tsx
'use client';

import {
  BarChart as RechartsBarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';

interface BarChartProps {
  data: Array<Record<string, any>>;
  xKey: string;
  bars: Array<{
    dataKey: string;
    name: string;
    color: string;
  }>;
  height?: number;
  stacked?: boolean;
}

export function BarChart({
  data,
  xKey,
  bars,
  height = 350,
  stacked = false,
}: BarChartProps) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <RechartsBarChart
        data={data}
        margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
      >
        <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
        <XAxis
          dataKey={xKey}
          tick={{ fontSize: 12 }}
          tickLine={false}
          axisLine={false}
        />
        <YAxis
          tick={{ fontSize: 12 }}
          tickLine={false}
          axisLine={false}
          tickFormatter={(value) => value.toLocaleString()}
        />
        <Tooltip content={<ChartTooltip />} />
        <Legend />
        {bars.map((bar) => (
          <Bar
            key={bar.dataKey}
            dataKey={bar.dataKey}
            name={bar.name}
            fill={bar.color}
            stackId={stacked ? 'stack' : undefined}
            radius={[4, 4, 0, 0]}
          />
        ))}
      </RechartsBarChart>
    </ResponsiveContainer>
  );
}

// Usage
<BarChart
  data={monthlySales}
  xKey="month"
  bars={[
    { dataKey: 'desktop', name: 'Desktop', color: '#8884d8' },
    { dataKey: 'mobile', name: 'Mobile', color: '#82ca9d' },
  ]}
  stacked
/>
```

## Area Chart

```typescript
// components/charts/area-chart.tsx
'use client';

import {
  AreaChart as RechartsAreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';

interface AreaChartProps {
  data: Array<Record<string, any>>;
  xKey: string;
  dataKey: string;
  color?: string;
  height?: number;
  gradient?: boolean;
}

export function AreaChart({
  data,
  xKey,
  dataKey,
  color = '#8884d8',
  height = 350,
  gradient = true,
}: AreaChartProps) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <RechartsAreaChart
        data={data}
        margin={{ top: 10, right: 30, left: 0, bottom: 0 }}
      >
        {gradient && (
          <defs>
            <linearGradient id={`gradient-${dataKey}`} x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor={color} stopOpacity={0.3} />
              <stop offset="95%" stopColor={color} stopOpacity={0} />
            </linearGradient>
          </defs>
        )}
        <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
        <XAxis dataKey={xKey} tick={{ fontSize: 12 }} />
        <YAxis tick={{ fontSize: 12 }} />
        <Tooltip content={<ChartTooltip />} />
        <Area
          type="monotone"
          dataKey={dataKey}
          stroke={color}
          fill={gradient ? `url(#gradient-${dataKey})` : color}
          fillOpacity={gradient ? 1 : 0.3}
        />
      </RechartsAreaChart>
    </ResponsiveContainer>
  );
}
```

## Pie Chart

```typescript
// components/charts/pie-chart.tsx
'use client';

import {
  PieChart as RechartsPieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';

const COLORS = ['#8884d8', '#82ca9d', '#ffc658', '#ff8042', '#0088fe'];

interface PieChartProps {
  data: Array<{
    name: string;
    value: number;
  }>;
  height?: number;
  innerRadius?: number;
  outerRadius?: number;
}

export function PieChart({
  data,
  height = 350,
  innerRadius = 0,
  outerRadius = 100,
}: PieChartProps) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <RechartsPieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          innerRadius={innerRadius}
          outerRadius={outerRadius}
          paddingAngle={2}
          dataKey="value"
          label={({ name, percent }) =>
            `${name} ${(percent * 100).toFixed(0)}%`
          }
          labelLine={false}
        >
          {data.map((_, index) => (
            <Cell
              key={`cell-${index}`}
              fill={COLORS[index % COLORS.length]}
            />
          ))}
        </Pie>
        <Tooltip content={<ChartTooltip />} />
        <Legend />
      </RechartsPieChart>
    </ResponsiveContainer>
  );
}

// Donut chart variant
<PieChart data={categoryData} innerRadius={60} outerRadius={100} />
```

## Stat Cards with Sparkline

```typescript
// components/charts/stat-card.tsx
'use client';

import { LineChart, Line, ResponsiveContainer } from 'recharts';
import { cn } from '@/lib/utils';
import { TrendingUp, TrendingDown } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string | number;
  change?: number;
  sparklineData?: Array<{ value: number }>;
  className?: string;
}

export function StatCard({
  title,
  value,
  change,
  sparklineData,
  className,
}: StatCardProps) {
  const isPositive = change && change > 0;
  const isNegative = change && change < 0;

  return (
    <div
      className={cn(
        'rounded-lg border bg-card p-6 shadow-sm',
        className,
      )}
    >
      <div className="flex items-center justify-between">
        <p className="text-sm font-medium text-muted-foreground">{title}</p>
        {change !== undefined && (
          <div
            className={cn(
              'flex items-center text-sm',
              isPositive && 'text-green-600',
              isNegative && 'text-red-600',
            )}
          >
            {isPositive ? (
              <TrendingUp className="mr-1 h-4 w-4" />
            ) : (
              <TrendingDown className="mr-1 h-4 w-4" />
            )}
            {Math.abs(change)}%
          </div>
        )}
      </div>
      <div className="mt-2 flex items-end justify-between">
        <p className="text-2xl font-bold">{value}</p>
        {sparklineData && (
          <div className="h-10 w-24">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={sparklineData}>
                <Line
                  type="monotone"
                  dataKey="value"
                  stroke={isPositive ? '#22c55e' : '#ef4444'}
                  strokeWidth={2}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        )}
      </div>
    </div>
  );
}

// Usage
<div className="grid grid-cols-1 md:grid-cols-4 gap-4">
  <StatCard
    title="Total Revenue"
    value="$45,231.89"
    change={12.5}
    sparklineData={revenueData}
  />
  <StatCard
    title="Total Orders"
    value="2,345"
    change={-3.2}
    sparklineData={ordersData}
  />
</div>
```

## Dashboard Grid

```typescript
// components/charts/dashboard-grid.tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LineChart } from './line-chart';
import { BarChart } from './bar-chart';
import { PieChart } from './pie-chart';

export function DashboardCharts() {
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
      {/* Full width chart */}
      <Card className="col-span-full lg:col-span-4">
        <CardHeader>
          <CardTitle>Revenue Overview</CardTitle>
        </CardHeader>
        <CardContent>
          <LineChart
            data={revenueData}
            xKey="date"
            lines={[
              { dataKey: 'revenue', name: 'Revenue', color: '#8884d8' },
            ]}
          />
        </CardContent>
      </Card>

      {/* Side chart */}
      <Card className="col-span-full lg:col-span-3">
        <CardHeader>
          <CardTitle>Sales by Category</CardTitle>
        </CardHeader>
        <CardContent>
          <PieChart data={categoryData} />
        </CardContent>
      </Card>

      {/* Half width charts */}
      <Card className="col-span-full md:col-span-1 lg:col-span-4">
        <CardHeader>
          <CardTitle>Monthly Sales</CardTitle>
        </CardHeader>
        <CardContent>
          <BarChart
            data={monthlySales}
            xKey="month"
            bars={[
              { dataKey: 'sales', name: 'Sales', color: '#82ca9d' },
            ]}
          />
        </CardContent>
      </Card>
    </div>
  );
}
```

## Real-time Chart

```typescript
// components/charts/realtime-chart.tsx
'use client';

import { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer } from 'recharts';

export function RealtimeChart() {
  const [data, setData] = useState<Array<{ time: string; value: number }>>([]);

  useEffect(() => {
    const interval = setInterval(() => {
      setData((prev) => {
        const newData = [...prev, {
          time: new Date().toLocaleTimeString(),
          value: Math.random() * 100,
        }];
        // Keep last 20 points
        return newData.slice(-20);
      });
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <ResponsiveContainer width="100%" height={200}>
      <LineChart data={data}>
        <XAxis dataKey="time" tick={false} />
        <YAxis domain={[0, 100]} />
        <Line
          type="monotone"
          dataKey="value"
          stroke="#8884d8"
          isAnimationActive={false}
          dot={false}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

## Best Practices

```yaml
chart_guidelines:
  - Use ResponsiveContainer for responsive charts
  - Customize tooltips for better UX
  - Use consistent color palette
  - Add loading states for async data
  - Provide fallback for empty data

accessibility:
  - Include descriptive titles
  - Add data tables as alternatives
  - Use sufficient color contrast
  - Provide keyboard navigation

performance:
  - Limit data points (aggregate if needed)
  - Use isAnimationActive={false} for realtime
  - Memoize data transformations
  - Consider lazy loading for multiple charts

common_charts:
  - Line: trends over time
  - Bar: comparisons
  - Area: volumes
  - Pie/Donut: distributions
  - Sparkline: compact trends
```
