---
name: admin-layouts
description: Admin panel layout patterns, sidebar navigation, header components. Use when building admin interfaces.
---

# Admin Layouts

어드민 패널 레이아웃 패턴입니다.

## Basic Admin Layout

```typescript
// app/(admin)/layout.tsx
import { Sidebar } from '@/components/admin/sidebar';
import { Header } from '@/components/admin/header';

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Header />
        <main className="flex-1 overflow-auto bg-muted/30 p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
```

## Sidebar Component

```typescript
// components/admin/sidebar.tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  Package,
  ShoppingCart,
  Settings,
  BarChart,
  FileText,
  ChevronDown,
} from 'lucide-react';
import { useState } from 'react';

const navigation = [
  {
    name: 'Dashboard',
    href: '/admin',
    icon: LayoutDashboard,
  },
  {
    name: 'Users',
    href: '/admin/users',
    icon: Users,
  },
  {
    name: 'Products',
    icon: Package,
    children: [
      { name: 'All Products', href: '/admin/products' },
      { name: 'Categories', href: '/admin/products/categories' },
      { name: 'Inventory', href: '/admin/products/inventory' },
    ],
  },
  {
    name: 'Orders',
    href: '/admin/orders',
    icon: ShoppingCart,
  },
  {
    name: 'Analytics',
    href: '/admin/analytics',
    icon: BarChart,
  },
  {
    name: 'Reports',
    href: '/admin/reports',
    icon: FileText,
  },
  {
    name: 'Settings',
    href: '/admin/settings',
    icon: Settings,
  },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="hidden lg:flex lg:w-64 lg:flex-col lg:fixed lg:inset-y-0 border-r bg-background">
      {/* Logo */}
      <div className="flex h-16 items-center gap-2 px-6 border-b">
        <div className="h-8 w-8 rounded-lg bg-primary" />
        <span className="font-semibold text-lg">Admin</span>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-4">
        <ul className="space-y-1 px-3">
          {navigation.map((item) => (
            <NavItem key={item.name} item={item} pathname={pathname} />
          ))}
        </ul>
      </nav>

      {/* User section */}
      <div className="border-t p-4">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-full bg-muted" />
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">John Doe</p>
            <p className="text-xs text-muted-foreground truncate">
              admin@example.com
            </p>
          </div>
        </div>
      </div>
    </aside>
  );
}

function NavItem({
  item,
  pathname,
}: {
  item: (typeof navigation)[0];
  pathname: string;
}) {
  const [isOpen, setIsOpen] = useState(false);
  const hasChildren = item.children?.length;
  const isActive = item.href
    ? pathname === item.href
    : item.children?.some((child) => pathname === child.href);

  if (hasChildren) {
    return (
      <li>
        <button
          onClick={() => setIsOpen(!isOpen)}
          className={cn(
            'flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors',
            isActive
              ? 'bg-primary/10 text-primary'
              : 'text-muted-foreground hover:bg-muted hover:text-foreground',
          )}
        >
          <item.icon className="h-5 w-5" />
          <span className="flex-1 text-left">{item.name}</span>
          <ChevronDown
            className={cn(
              'h-4 w-4 transition-transform',
              isOpen && 'rotate-180',
            )}
          />
        </button>
        {isOpen && (
          <ul className="mt-1 space-y-1 pl-10">
            {item.children.map((child) => (
              <li key={child.href}>
                <Link
                  href={child.href}
                  className={cn(
                    'block rounded-lg px-3 py-2 text-sm transition-colors',
                    pathname === child.href
                      ? 'bg-primary/10 text-primary'
                      : 'text-muted-foreground hover:bg-muted hover:text-foreground',
                  )}
                >
                  {child.name}
                </Link>
              </li>
            ))}
          </ul>
        )}
      </li>
    );
  }

  return (
    <li>
      <Link
        href={item.href!}
        className={cn(
          'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors',
          isActive
            ? 'bg-primary/10 text-primary'
            : 'text-muted-foreground hover:bg-muted hover:text-foreground',
        )}
      >
        <item.icon className="h-5 w-5" />
        {item.name}
      </Link>
    </li>
  );
}
```

## Header Component

```typescript
// components/admin/header.tsx
'use client';

import { Bell, Search, Menu } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useSidebar } from '@/hooks/use-sidebar';

export function Header() {
  const { toggle } = useSidebar();

  return (
    <header className="sticky top-0 z-40 border-b bg-background">
      <div className="flex h-16 items-center gap-4 px-6">
        {/* Mobile menu button */}
        <Button
          variant="ghost"
          size="icon"
          className="lg:hidden"
          onClick={toggle}
        >
          <Menu className="h-5 w-5" />
        </Button>

        {/* Search */}
        <div className="flex-1 max-w-md">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="Search..."
              className="pl-9"
            />
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Notifications */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="relative">
                <Bell className="h-5 w-5" />
                <span className="absolute top-1 right-1 h-2 w-2 rounded-full bg-red-500" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-80">
              <DropdownMenuLabel>Notifications</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <div className="max-h-[300px] overflow-y-auto">
                <DropdownMenuItem>
                  <div className="flex flex-col gap-1">
                    <p className="text-sm font-medium">New order received</p>
                    <p className="text-xs text-muted-foreground">2 minutes ago</p>
                  </div>
                </DropdownMenuItem>
              </div>
            </DropdownMenuContent>
          </DropdownMenu>

          {/* User menu */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon">
                <div className="h-8 w-8 rounded-full bg-muted" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuLabel>My Account</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem>Profile</DropdownMenuItem>
              <DropdownMenuItem>Settings</DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem className="text-red-600">
                Log out
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}
```

## Page Header

```typescript
// components/admin/page-header.tsx
import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';

interface PageHeaderProps {
  title: string;
  description?: string;
  action?: {
    label: string;
    href?: string;
    onClick?: () => void;
  };
}

export function PageHeader({ title, description, action }: PageHeaderProps) {
  return (
    <div className="flex items-center justify-between mb-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">{title}</h1>
        {description && (
          <p className="text-muted-foreground">{description}</p>
        )}
      </div>
      {action && (
        <Button onClick={action.onClick} asChild={!!action.href}>
          {action.href ? (
            <a href={action.href}>
              <Plus className="mr-2 h-4 w-4" />
              {action.label}
            </a>
          ) : (
            <>
              <Plus className="mr-2 h-4 w-4" />
              {action.label}
            </>
          )}
        </Button>
      )}
    </div>
  );
}

// Usage
<PageHeader
  title="Users"
  description="Manage your users and their permissions."
  action={{ label: 'Add User', href: '/admin/users/new' }}
/>
```

## Breadcrumb

```typescript
// components/admin/breadcrumb.tsx
import Link from 'next/link';
import { ChevronRight, Home } from 'lucide-react';

interface BreadcrumbItem {
  label: string;
  href?: string;
}

interface BreadcrumbProps {
  items: BreadcrumbItem[];
}

export function Breadcrumb({ items }: BreadcrumbProps) {
  return (
    <nav className="flex items-center gap-2 text-sm text-muted-foreground mb-4">
      <Link href="/admin" className="hover:text-foreground">
        <Home className="h-4 w-4" />
      </Link>
      {items.map((item, index) => (
        <div key={index} className="flex items-center gap-2">
          <ChevronRight className="h-4 w-4" />
          {item.href ? (
            <Link href={item.href} className="hover:text-foreground">
              {item.label}
            </Link>
          ) : (
            <span className="text-foreground">{item.label}</span>
          )}
        </div>
      ))}
    </nav>
  );
}

// Usage
<Breadcrumb
  items={[
    { label: 'Users', href: '/admin/users' },
    { label: 'Edit User' },
  ]}
/>
```

## Mobile Sidebar

```typescript
// components/admin/mobile-sidebar.tsx
'use client';

import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';
import { Button } from '@/components/ui/button';
import { Menu } from 'lucide-react';
import { Sidebar } from './sidebar';

export function MobileSidebar() {
  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon" className="lg:hidden">
          <Menu className="h-5 w-5" />
        </Button>
      </SheetTrigger>
      <SheetContent side="left" className="p-0 w-64">
        <Sidebar />
      </SheetContent>
    </Sheet>
  );
}
```

## Dashboard Page Layout

```typescript
// app/(admin)/dashboard/page.tsx
import { PageHeader } from '@/components/admin/page-header';
import { StatCard } from '@/components/charts/stat-card';
import { DashboardCharts } from '@/components/charts/dashboard-grid';
import { RecentOrders } from '@/components/admin/recent-orders';
import { getStats } from '@/lib/api/stats';

export default async function DashboardPage() {
  const stats = await getStats();

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        description="Overview of your business metrics"
      />

      {/* Stats grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Revenue"
          value={`$${stats.revenue.toLocaleString()}`}
          change={stats.revenueChange}
        />
        <StatCard
          title="Total Orders"
          value={stats.orders.toLocaleString()}
          change={stats.ordersChange}
        />
        <StatCard
          title="Active Users"
          value={stats.users.toLocaleString()}
          change={stats.usersChange}
        />
        <StatCard
          title="Conversion Rate"
          value={`${stats.conversionRate}%`}
          change={stats.conversionChange}
        />
      </div>

      {/* Charts */}
      <DashboardCharts />

      {/* Recent activity */}
      <div className="grid gap-4 md:grid-cols-2">
        <RecentOrders />
        <RecentActivity />
      </div>
    </div>
  );
}
```

## List Page Layout

```typescript
// app/(admin)/users/page.tsx
import { PageHeader } from '@/components/admin/page-header';
import { Breadcrumb } from '@/components/admin/breadcrumb';
import { DataTable } from '@/components/data-table/data-table';
import { userColumns } from '@/components/users/columns';
import { getUsers } from '@/lib/api/users';

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <div>
      <Breadcrumb items={[{ label: 'Users' }]} />
      <PageHeader
        title="Users"
        description="Manage user accounts and permissions."
        action={{ label: 'Add User', href: '/admin/users/new' }}
      />
      <DataTable columns={userColumns} data={users} />
    </div>
  );
}
```

## Best Practices

```yaml
layout_guidelines:
  - Use sticky header for navigation
  - Implement responsive sidebar (collapsible on mobile)
  - Add breadcrumbs for deep navigation
  - Include search functionality
  - Show user context in header

components:
  - PageHeader: title, description, action button
  - Breadcrumb: navigation context
  - StatCards: key metrics
  - DataTable: list views
  - Forms: create/edit pages

responsive:
  - Sidebar: hidden on mobile, sheet overlay
  - Grid: adjust columns by breakpoint
  - Tables: horizontal scroll on mobile
  - Actions: dropdown on small screens

accessibility:
  - Keyboard navigation for sidebar
  - Focus management for modals
  - ARIA labels for icons
  - Skip to main content link
```
