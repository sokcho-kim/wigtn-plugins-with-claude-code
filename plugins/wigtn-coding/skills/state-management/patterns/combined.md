# Combined Client + Server State

Separate concerns: Zustand for client state, React Query for server state.

## Architecture

```
Client State (Zustand):
- UI state (sidebar open, modal, theme)
- User preferences
- Temporary form state

Server State (React Query):
- API data
- Caching
- Background refetching
```

## Client State Store

```typescript
// store/useUIStore.ts
import { create } from "zustand";

interface UIState {
  sidebarOpen: boolean;
  modal: string | null;
  theme: "light" | "dark";
  toggleSidebar: () => void;
  openModal: (modal: string) => void;
  closeModal: () => void;
  setTheme: (theme: "light" | "dark") => void;
}

export const useUIStore = create<UIState>((set) => ({
  sidebarOpen: true,
  modal: null,
  theme: "light",
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  openModal: (modal) => set({ modal }),
  closeModal: () => set({ modal: null }),
  setTheme: (theme) => set({ theme }),
}));
```

## Combined Usage

```typescript
// components/Dashboard.tsx
import { useUIStore } from "@/store/useUIStore";
import { useUsers, useStats } from "@/hooks/queries";

function Dashboard() {
  // Client state
  const { sidebarOpen, toggleSidebar } = useUIStore();

  // Server state
  const { data: users, isLoading: usersLoading } = useUsers({ active: true });
  const { data: stats, isLoading: statsLoading } = useStats();

  if (usersLoading || statsLoading) {
    return <DashboardSkeleton />;
  }

  return (
    <div className={sidebarOpen ? "with-sidebar" : ""}>
      <Sidebar open={sidebarOpen} onToggle={toggleSidebar} />
      <main>
        <StatsCards stats={stats} />
        <UserTable users={users} />
      </main>
    </div>
  );
}
```

## When to Use Each

| Scenario | Solution |
|----------|----------|
| API data that needs caching | React Query |
| UI toggles (sidebar, modal) | Zustand |
| User auth status | Zustand (synced from server) |
| Form data during editing | Local state or Zustand |
| List filters/pagination | URL state + React Query |
| Real-time data | React Query with refetchInterval |
