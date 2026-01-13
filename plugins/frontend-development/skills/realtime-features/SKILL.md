---
name: realtime-features
description: Build real-time applications with WebSocket, Server-Sent Events (SSE), and polling. Includes chat, notifications, live updates, collaborative editing, presence indicators, and optimistic UI patterns. Use when implementing live data, real-time collaboration, or instant notifications.
---

# Real-Time Features

Comprehensive patterns for building real-time applications with WebSocket, Server-Sent Events (SSE), and long-polling. Covers chat systems, live notifications, collaborative features, and presence indicators.

## When to Use This Skill

- Building chat applications
- Implementing live notifications
- Creating collaborative features (like Google Docs)
- Adding presence indicators (online/offline status)
- Building real-time dashboards
- Implementing live updates without page refresh

## Technology Comparison

| Feature | WebSocket | SSE | Polling |
|---------|-----------|-----|---------|
| **Direction** | Bi-directional | Server → Client | Client → Server |
| **Connection** | Persistent | Persistent | Repeated |
| **Complexity** | High | Low | Low |
| **Browser Support** | All modern | All modern | All |
| **Use Case** | Chat, games | Notifications, feeds | Simple updates |
| **Reconnection** | Manual | Automatic | N/A |

---

## WebSocket Patterns

### 1. WebSocket Hook

```typescript
// hooks/use-websocket.ts
import { useState, useEffect, useRef, useCallback } from "react";

type WebSocketStatus = "connecting" | "connected" | "disconnected" | "error";

interface UseWebSocketOptions {
  onOpen?: (event: Event) => void;
  onClose?: (event: CloseEvent) => void;
  onError?: (event: Event) => void;
  onMessage?: (event: MessageEvent) => void;
  reconnectAttempts?: number;
  reconnectInterval?: number;
  heartbeatInterval?: number;
}

interface UseWebSocketReturn<T> {
  status: WebSocketStatus;
  lastMessage: T | null;
  sendMessage: (message: string | object) => void;
  connect: () => void;
  disconnect: () => void;
}

export function useWebSocket<T = any>(
  url: string,
  options: UseWebSocketOptions = {}
): UseWebSocketReturn<T> {
  const {
    onOpen,
    onClose,
    onError,
    onMessage,
    reconnectAttempts = 5,
    reconnectInterval = 3000,
    heartbeatInterval = 30000,
  } = options;

  const [status, setStatus] = useState<WebSocketStatus>("disconnected");
  const [lastMessage, setLastMessage] = useState<T | null>(null);

  const wsRef = useRef<WebSocket | null>(null);
  const reconnectCountRef = useRef(0);
  const heartbeatRef = useRef<NodeJS.Timeout>();
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();

  const startHeartbeat = useCallback(() => {
    heartbeatRef.current = setInterval(() => {
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        wsRef.current.send(JSON.stringify({ type: "ping" }));
      }
    }, heartbeatInterval);
  }, [heartbeatInterval]);

  const stopHeartbeat = useCallback(() => {
    if (heartbeatRef.current) {
      clearInterval(heartbeatRef.current);
    }
  }, []);

  const connect = useCallback(() => {
    if (wsRef.current?.readyState === WebSocket.OPEN) return;

    setStatus("connecting");
    const ws = new WebSocket(url);
    wsRef.current = ws;

    ws.onopen = (event) => {
      setStatus("connected");
      reconnectCountRef.current = 0;
      startHeartbeat();
      onOpen?.(event);
    };

    ws.onclose = (event) => {
      setStatus("disconnected");
      stopHeartbeat();
      onClose?.(event);

      // Auto reconnect
      if (reconnectCountRef.current < reconnectAttempts) {
        reconnectCountRef.current++;
        reconnectTimeoutRef.current = setTimeout(() => {
          console.log(`Reconnecting... Attempt ${reconnectCountRef.current}`);
          connect();
        }, reconnectInterval);
      }
    };

    ws.onerror = (event) => {
      setStatus("error");
      onError?.(event);
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        if (data.type !== "pong") {
          setLastMessage(data);
        }
        onMessage?.(event);
      } catch {
        setLastMessage(event.data);
        onMessage?.(event);
      }
    };
  }, [url, onOpen, onClose, onError, onMessage, reconnectAttempts, reconnectInterval, startHeartbeat, stopHeartbeat]);

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
    }
    reconnectCountRef.current = reconnectAttempts; // Prevent reconnection
    stopHeartbeat();
    wsRef.current?.close();
  }, [reconnectAttempts, stopHeartbeat]);

  const sendMessage = useCallback((message: string | object) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      const msg = typeof message === "string" ? message : JSON.stringify(message);
      wsRef.current.send(msg);
    } else {
      console.warn("WebSocket is not connected");
    }
  }, []);

  useEffect(() => {
    connect();
    return () => {
      disconnect();
    };
  }, [connect, disconnect]);

  return { status, lastMessage, sendMessage, connect, disconnect };
}
```

### 2. Chat Application

```typescript
// components/chat/chat-room.tsx
"use client";

import { useState, useRef, useEffect } from "react";
import { useWebSocket } from "@/hooks/use-websocket";

interface Message {
  id: string;
  userId: string;
  username: string;
  content: string;
  timestamp: Date;
  type: "message" | "system";
}

interface ChatRoomProps {
  roomId: string;
  currentUser: { id: string; username: string };
}

export function ChatRoom({ roomId, currentUser }: ChatRoomProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputValue, setInputValue] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const { status, lastMessage, sendMessage } = useWebSocket<Message>(
    `wss://api.example.com/chat/${roomId}`,
    {
      onOpen: () => {
        // Join room
        sendMessage({ type: "join", roomId, user: currentUser });
      },
    }
  );

  // Handle incoming messages
  useEffect(() => {
    if (lastMessage) {
      setMessages((prev) => [...prev, lastMessage]);
    }
  }, [lastMessage]);

  // Auto-scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputValue.trim()) return;

    const message = {
      type: "message",
      content: inputValue,
      userId: currentUser.id,
      username: currentUser.username,
      timestamp: new Date().toISOString(),
    };

    sendMessage(message);
    setInputValue("");
  };

  return (
    <div className="flex h-[600px] flex-col rounded-lg border bg-white shadow-lg">
      {/* Header */}
      <div className="flex items-center justify-between border-b px-4 py-3">
        <h2 className="font-semibold">Chat Room</h2>
        <div className="flex items-center gap-2">
          <span
            className={`h-2 w-2 rounded-full ${
              status === "connected" ? "bg-green-500" : "bg-red-500"
            }`}
          />
          <span className="text-sm text-gray-500">
            {status === "connected" ? "Connected" : "Disconnected"}
          </span>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((msg) => (
          <MessageBubble
            key={msg.id}
            message={msg}
            isOwn={msg.userId === currentUser.id}
          />
        ))}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <form onSubmit={handleSend} className="border-t p-4">
        <div className="flex gap-2">
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="Type a message..."
            className="flex-1 rounded-lg border px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={status !== "connected"}
          />
          <button
            type="submit"
            disabled={status !== "connected" || !inputValue.trim()}
            className="rounded-lg bg-blue-500 px-6 py-2 text-white hover:bg-blue-600 disabled:opacity-50"
          >
            Send
          </button>
        </div>
      </form>
    </div>
  );
}

function MessageBubble({ message, isOwn }: { message: Message; isOwn: boolean }) {
  if (message.type === "system") {
    return (
      <div className="text-center text-sm text-gray-500">{message.content}</div>
    );
  }

  return (
    <div className={`flex ${isOwn ? "justify-end" : "justify-start"}`}>
      <div
        className={`max-w-[70%] rounded-lg px-4 py-2 ${
          isOwn
            ? "bg-blue-500 text-white"
            : "bg-gray-100 text-gray-900"
        }`}
      >
        {!isOwn && (
          <div className="mb-1 text-xs font-medium text-gray-500">
            {message.username}
          </div>
        )}
        <div>{message.content}</div>
        <div
          className={`mt-1 text-xs ${
            isOwn ? "text-blue-100" : "text-gray-400"
          }`}
        >
          {new Date(message.timestamp).toLocaleTimeString()}
        </div>
      </div>
    </div>
  );
}
```

### 3. Presence Indicators

```typescript
// hooks/use-presence.ts
import { useState, useEffect, useCallback } from "react";
import { useWebSocket } from "./use-websocket";

interface User {
  id: string;
  username: string;
  avatar?: string;
  status: "online" | "away" | "offline";
  lastSeen?: Date;
}

export function usePresence(roomId: string, currentUser: User) {
  const [onlineUsers, setOnlineUsers] = useState<User[]>([]);

  const { sendMessage, lastMessage, status } = useWebSocket(
    `wss://api.example.com/presence/${roomId}`,
    {
      onOpen: () => {
        // Announce presence
        sendMessage({
          type: "presence",
          action: "join",
          user: currentUser,
        });
      },
    }
  );

  useEffect(() => {
    if (lastMessage?.type === "presence") {
      if (lastMessage.action === "sync") {
        setOnlineUsers(lastMessage.users);
      } else if (lastMessage.action === "join") {
        setOnlineUsers((prev) => [...prev, lastMessage.user]);
      } else if (lastMessage.action === "leave") {
        setOnlineUsers((prev) =>
          prev.filter((u) => u.id !== lastMessage.user.id)
        );
      } else if (lastMessage.action === "update") {
        setOnlineUsers((prev) =>
          prev.map((u) =>
            u.id === lastMessage.user.id ? { ...u, ...lastMessage.user } : u
          )
        );
      }
    }
  }, [lastMessage]);

  // Update status
  const updateStatus = useCallback(
    (newStatus: User["status"]) => {
      sendMessage({
        type: "presence",
        action: "update",
        user: { ...currentUser, status: newStatus },
      });
    },
    [sendMessage, currentUser]
  );

  // Handle visibility change for auto-away
  useEffect(() => {
    const handleVisibilityChange = () => {
      updateStatus(document.hidden ? "away" : "online");
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () => {
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [updateStatus]);

  return { onlineUsers, updateStatus, isConnected: status === "connected" };
}

// components/presence/online-users.tsx
export function OnlineUsers({ users }: { users: User[] }) {
  return (
    <div className="rounded-lg border bg-white p-4">
      <h3 className="mb-3 font-medium">Online ({users.length})</h3>
      <div className="space-y-2">
        {users.map((user) => (
          <div key={user.id} className="flex items-center gap-3">
            <div className="relative">
              <div className="h-8 w-8 rounded-full bg-gray-200">
                {user.avatar && (
                  <img
                    src={user.avatar}
                    alt={user.username}
                    className="h-full w-full rounded-full object-cover"
                  />
                )}
              </div>
              <span
                className={`absolute bottom-0 right-0 h-3 w-3 rounded-full border-2 border-white ${
                  user.status === "online"
                    ? "bg-green-500"
                    : user.status === "away"
                    ? "bg-yellow-500"
                    : "bg-gray-400"
                }`}
              />
            </div>
            <span className="text-sm">{user.username}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## Server-Sent Events (SSE)

### 1. SSE Hook

```typescript
// hooks/use-sse.ts
import { useState, useEffect, useRef, useCallback } from "react";

interface UseSSEOptions<T> {
  onMessage?: (data: T) => void;
  onError?: (error: Event) => void;
  onOpen?: () => void;
  withCredentials?: boolean;
  eventTypes?: string[];
}

export function useSSE<T = any>(
  url: string,
  options: UseSSEOptions<T> = {}
) {
  const { onMessage, onError, onOpen, withCredentials = false, eventTypes = ["message"] } = options;

  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Event | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  const eventSourceRef = useRef<EventSource | null>(null);

  const connect = useCallback(() => {
    const eventSource = new EventSource(url, { withCredentials });
    eventSourceRef.current = eventSource;

    eventSource.onopen = () => {
      setIsConnected(true);
      setError(null);
      onOpen?.();
    };

    eventSource.onerror = (event) => {
      setIsConnected(false);
      setError(event);
      onError?.(event);
    };

    // Register handlers for each event type
    eventTypes.forEach((eventType) => {
      eventSource.addEventListener(eventType, (event: MessageEvent) => {
        try {
          const parsedData = JSON.parse(event.data);
          setData(parsedData);
          onMessage?.(parsedData);
        } catch {
          setData(event.data);
          onMessage?.(event.data);
        }
      });
    });

    return eventSource;
  }, [url, withCredentials, eventTypes, onMessage, onError, onOpen]);

  const disconnect = useCallback(() => {
    eventSourceRef.current?.close();
    setIsConnected(false);
  }, []);

  useEffect(() => {
    const eventSource = connect();
    return () => eventSource.close();
  }, [connect]);

  return { data, error, isConnected, disconnect, reconnect: connect };
}
```

### 2. Live Notifications

```typescript
// components/notifications/live-notifications.tsx
"use client";

import { useState, useEffect } from "react";
import { useSSE } from "@/hooks/use-sse";
import { Bell, X } from "lucide-react";

interface Notification {
  id: string;
  type: "info" | "success" | "warning" | "error";
  title: string;
  message: string;
  timestamp: Date;
  read: boolean;
}

export function LiveNotifications() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [isOpen, setIsOpen] = useState(false);

  const { data: newNotification, isConnected } = useSSE<Notification>(
    "/api/notifications/stream",
    {
      eventTypes: ["notification"],
    }
  );

  // Add new notifications
  useEffect(() => {
    if (newNotification) {
      setNotifications((prev) => [newNotification, ...prev].slice(0, 50));
    }
  }, [newNotification]);

  const unreadCount = notifications.filter((n) => !n.read).length;

  const markAsRead = (id: string) => {
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true } : n))
    );
  };

  const markAllAsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
  };

  const removeNotification = (id: string) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id));
  };

  return (
    <div className="relative">
      {/* Bell Icon */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative rounded-full p-2 hover:bg-gray-100"
      >
        <Bell className="h-6 w-6" />
        {unreadCount > 0 && (
          <span className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs text-white">
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        )}
        {/* Connection indicator */}
        <span
          className={`absolute bottom-0 right-0 h-2 w-2 rounded-full ${
            isConnected ? "bg-green-500" : "bg-red-500"
          }`}
        />
      </button>

      {/* Dropdown */}
      {isOpen && (
        <div className="absolute right-0 top-full z-50 mt-2 w-80 rounded-lg border bg-white shadow-lg">
          <div className="flex items-center justify-between border-b p-4">
            <h3 className="font-semibold">Notifications</h3>
            {unreadCount > 0 && (
              <button
                onClick={markAllAsRead}
                className="text-sm text-blue-500 hover:underline"
              >
                Mark all as read
              </button>
            )}
          </div>

          <div className="max-h-96 overflow-y-auto">
            {notifications.length === 0 ? (
              <div className="p-4 text-center text-gray-500">
                No notifications
              </div>
            ) : (
              notifications.map((notification) => (
                <NotificationItem
                  key={notification.id}
                  notification={notification}
                  onRead={() => markAsRead(notification.id)}
                  onRemove={() => removeNotification(notification.id)}
                />
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function NotificationItem({
  notification,
  onRead,
  onRemove,
}: {
  notification: Notification;
  onRead: () => void;
  onRemove: () => void;
}) {
  const typeColors = {
    info: "bg-blue-100 text-blue-800",
    success: "bg-green-100 text-green-800",
    warning: "bg-yellow-100 text-yellow-800",
    error: "bg-red-100 text-red-800",
  };

  return (
    <div
      className={`border-b p-4 ${!notification.read ? "bg-blue-50" : ""}`}
      onClick={onRead}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <span
              className={`rounded px-2 py-0.5 text-xs font-medium ${
                typeColors[notification.type]
              }`}
            >
              {notification.type}
            </span>
            <span className="text-xs text-gray-400">
              {new Date(notification.timestamp).toLocaleTimeString()}
            </span>
          </div>
          <h4 className="mt-1 font-medium">{notification.title}</h4>
          <p className="text-sm text-gray-600">{notification.message}</p>
        </div>
        <button
          onClick={(e) => {
            e.stopPropagation();
            onRemove();
          }}
          className="text-gray-400 hover:text-gray-600"
        >
          <X className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}
```

### 3. SSE API Route (Next.js)

```typescript
// app/api/notifications/stream/route.ts
export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const encoder = new TextEncoder();

  const stream = new ReadableStream({
    async start(controller) {
      // Send initial connection message
      controller.enqueue(
        encoder.encode(`event: notification\ndata: ${JSON.stringify({
          id: crypto.randomUUID(),
          type: "info",
          title: "Connected",
          message: "You are now receiving live notifications",
          timestamp: new Date(),
          read: false,
        })}\n\n`)
      );

      // Simulate periodic notifications
      const interval = setInterval(() => {
        const notification = {
          id: crypto.randomUUID(),
          type: ["info", "success", "warning", "error"][Math.floor(Math.random() * 4)],
          title: "New Update",
          message: `Something happened at ${new Date().toLocaleTimeString()}`,
          timestamp: new Date(),
          read: false,
        };

        controller.enqueue(
          encoder.encode(`event: notification\ndata: ${JSON.stringify(notification)}\n\n`)
        );
      }, 10000);

      // Cleanup on disconnect
      request.signal.addEventListener("abort", () => {
        clearInterval(interval);
        controller.close();
      });
    },
  });

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    },
  });
}
```

---

## Optimistic UI Updates

### 1. Optimistic Update Hook

```typescript
// hooks/use-optimistic-mutation.ts
import { useState, useCallback } from "react";

interface OptimisticMutationOptions<T, R> {
  mutationFn: (data: T) => Promise<R>;
  onSuccess?: (result: R) => void;
  onError?: (error: Error, variables: T, rollback: () => void) => void;
  onSettled?: () => void;
}

export function useOptimisticMutation<T, R>({
  mutationFn,
  onSuccess,
  onError,
  onSettled,
}: OptimisticMutationOptions<T, R>) {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const mutate = useCallback(
    async (
      data: T,
      optimisticUpdate: () => void,
      rollback: () => void
    ) => {
      setIsLoading(true);
      setError(null);

      // Apply optimistic update immediately
      optimisticUpdate();

      try {
        const result = await mutationFn(data);
        onSuccess?.(result);
        return result;
      } catch (err) {
        const error = err instanceof Error ? err : new Error("Unknown error");
        setError(error);
        rollback();
        onError?.(error, data, rollback);
        throw error;
      } finally {
        setIsLoading(false);
        onSettled?.();
      }
    },
    [mutationFn, onSuccess, onError, onSettled]
  );

  return { mutate, isLoading, error };
}
```

### 2. Optimistic Todo List

```typescript
// components/todos/optimistic-todo-list.tsx
"use client";

import { useState } from "react";
import { useOptimisticMutation } from "@/hooks/use-optimistic-mutation";

interface Todo {
  id: string;
  text: string;
  completed: boolean;
  pending?: boolean;
}

export function OptimisticTodoList() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [inputValue, setInputValue] = useState("");

  const { mutate: addTodo, isLoading } = useOptimisticMutation({
    mutationFn: async (todo: Todo) => {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1000));
      // Simulate random failure for demo
      if (Math.random() > 0.8) {
        throw new Error("Failed to add todo");
      }
      return { ...todo, pending: false };
    },
    onSuccess: (result) => {
      setTodos((prev) =>
        prev.map((t) => (t.id === result.id ? result : t))
      );
    },
  });

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputValue.trim()) return;

    const newTodo: Todo = {
      id: crypto.randomUUID(),
      text: inputValue,
      completed: false,
      pending: true,
    };

    setInputValue("");

    await addTodo(
      newTodo,
      // Optimistic update
      () => setTodos((prev) => [...prev, newTodo]),
      // Rollback
      () => setTodos((prev) => prev.filter((t) => t.id !== newTodo.id))
    );
  };

  const { mutate: toggleTodo } = useOptimisticMutation({
    mutationFn: async (id: string) => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      return id;
    },
  });

  const handleToggle = async (id: string) => {
    const todo = todos.find((t) => t.id === id);
    if (!todo) return;

    await toggleTodo(
      id,
      () =>
        setTodos((prev) =>
          prev.map((t) =>
            t.id === id ? { ...t, completed: !t.completed } : t
          )
        ),
      () =>
        setTodos((prev) =>
          prev.map((t) =>
            t.id === id ? { ...t, completed: todo.completed } : t
          )
        )
    );
  };

  const { mutate: deleteTodo } = useOptimisticMutation({
    mutationFn: async (id: string) => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      return id;
    },
  });

  const handleDelete = async (id: string) => {
    const todoToDelete = todos.find((t) => t.id === id);
    const todoIndex = todos.findIndex((t) => t.id === id);

    await deleteTodo(
      id,
      () => setTodos((prev) => prev.filter((t) => t.id !== id)),
      () => {
        if (todoToDelete) {
          setTodos((prev) => {
            const newTodos = [...prev];
            newTodos.splice(todoIndex, 0, todoToDelete);
            return newTodos;
          });
        }
      }
    );
  };

  return (
    <div className="mx-auto max-w-md">
      <form onSubmit={handleAdd} className="mb-4 flex gap-2">
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          placeholder="Add a todo..."
          className="flex-1 rounded border px-3 py-2"
        />
        <button
          type="submit"
          disabled={isLoading}
          className="rounded bg-blue-500 px-4 py-2 text-white hover:bg-blue-600 disabled:opacity-50"
        >
          Add
        </button>
      </form>

      <ul className="space-y-2">
        {todos.map((todo) => (
          <li
            key={todo.id}
            className={`flex items-center gap-3 rounded border p-3 ${
              todo.pending ? "opacity-50" : ""
            }`}
          >
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => handleToggle(todo.id)}
              disabled={todo.pending}
              className="h-5 w-5"
            />
            <span
              className={`flex-1 ${
                todo.completed ? "text-gray-400 line-through" : ""
              }`}
            >
              {todo.text}
            </span>
            {todo.pending && (
              <span className="text-xs text-gray-400">Saving...</span>
            )}
            <button
              onClick={() => handleDelete(todo.id)}
              disabled={todo.pending}
              className="text-red-500 hover:text-red-700 disabled:opacity-50"
            >
              Delete
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

---

## Polling Pattern

### 1. Polling Hook

```typescript
// hooks/use-polling.ts
import { useState, useEffect, useRef, useCallback } from "react";

interface UsePollingOptions<T> {
  interval: number;
  enabled?: boolean;
  onSuccess?: (data: T) => void;
  onError?: (error: Error) => void;
  refetchOnWindowFocus?: boolean;
}

export function usePolling<T>(
  fetchFn: () => Promise<T>,
  options: UsePollingOptions<T>
) {
  const {
    interval,
    enabled = true,
    onSuccess,
    onError,
    refetchOnWindowFocus = true,
  } = options;

  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const savedCallback = useRef(fetchFn);

  useEffect(() => {
    savedCallback.current = fetchFn;
  }, [fetchFn]);

  const fetchData = useCallback(async () => {
    try {
      setError(null);
      const result = await savedCallback.current();
      setData(result);
      onSuccess?.(result);
    } catch (err) {
      const error = err instanceof Error ? err : new Error("Unknown error");
      setError(error);
      onError?.(error);
    } finally {
      setIsLoading(false);
    }
  }, [onSuccess, onError]);

  // Initial fetch and polling
  useEffect(() => {
    if (!enabled) return;

    fetchData();
    const intervalId = setInterval(fetchData, interval);

    return () => clearInterval(intervalId);
  }, [enabled, interval, fetchData]);

  // Refetch on window focus
  useEffect(() => {
    if (!refetchOnWindowFocus || !enabled) return;

    const handleFocus = () => fetchData();
    window.addEventListener("focus", handleFocus);

    return () => window.removeEventListener("focus", handleFocus);
  }, [refetchOnWindowFocus, enabled, fetchData]);

  return { data, error, isLoading, refetch: fetchData };
}
```

### 2. Smart Polling (Adaptive)

```typescript
// hooks/use-adaptive-polling.ts
import { useState, useEffect, useRef, useCallback } from "react";

interface UseAdaptivePollingOptions<T> {
  minInterval: number;
  maxInterval: number;
  backoffMultiplier?: number;
  enabled?: boolean;
  shouldBackoff?: (data: T | null, prevData: T | null) => boolean;
}

export function useAdaptivePolling<T>(
  fetchFn: () => Promise<T>,
  options: UseAdaptivePollingOptions<T>
) {
  const {
    minInterval,
    maxInterval,
    backoffMultiplier = 1.5,
    enabled = true,
    shouldBackoff = (data, prevData) => JSON.stringify(data) === JSON.stringify(prevData),
  } = options;

  const [data, setData] = useState<T | null>(null);
  const [interval, setIntervalTime] = useState(minInterval);
  const prevDataRef = useRef<T | null>(null);

  const fetchData = useCallback(async () => {
    const result = await fetchFn();

    // Check if we should back off
    if (shouldBackoff(result, prevDataRef.current)) {
      setIntervalTime((prev) => Math.min(prev * backoffMultiplier, maxInterval));
    } else {
      setIntervalTime(minInterval);
    }

    prevDataRef.current = result;
    setData(result);
  }, [fetchFn, shouldBackoff, backoffMultiplier, minInterval, maxInterval]);

  useEffect(() => {
    if (!enabled) return;

    fetchData();
    const intervalId = setInterval(fetchData, interval);

    return () => clearInterval(intervalId);
  }, [enabled, interval, fetchData]);

  return { data, currentInterval: interval };
}
```

---

## Collaborative Editing

### 1. Cursor Positions

```typescript
// hooks/use-cursors.ts
import { useState, useEffect, useCallback } from "react";
import { useWebSocket } from "./use-websocket";

interface Cursor {
  id: string;
  userId: string;
  username: string;
  color: string;
  x: number;
  y: number;
}

export function useCursors(documentId: string, currentUser: { id: string; username: string }) {
  const [cursors, setCursors] = useState<Map<string, Cursor>>(new Map());

  const { sendMessage, lastMessage, status } = useWebSocket(
    `wss://api.example.com/cursors/${documentId}`
  );

  // Handle incoming cursor updates
  useEffect(() => {
    if (lastMessage?.type === "cursor") {
      if (lastMessage.action === "move") {
        setCursors((prev) => {
          const next = new Map(prev);
          next.set(lastMessage.cursor.userId, lastMessage.cursor);
          return next;
        });
      } else if (lastMessage.action === "leave") {
        setCursors((prev) => {
          const next = new Map(prev);
          next.delete(lastMessage.userId);
          return next;
        });
      }
    }
  }, [lastMessage]);

  // Send cursor position
  const updateCursor = useCallback(
    (x: number, y: number) => {
      sendMessage({
        type: "cursor",
        action: "move",
        cursor: {
          userId: currentUser.id,
          username: currentUser.username,
          x,
          y,
        },
      });
    },
    [sendMessage, currentUser]
  );

  return {
    cursors: Array.from(cursors.values()).filter((c) => c.userId !== currentUser.id),
    updateCursor,
    isConnected: status === "connected",
  };
}

// components/collaboration/remote-cursors.tsx
export function RemoteCursors({ cursors }: { cursors: Cursor[] }) {
  return (
    <>
      {cursors.map((cursor) => (
        <div
          key={cursor.userId}
          className="pointer-events-none fixed z-50 transition-transform duration-75"
          style={{
            transform: `translate(${cursor.x}px, ${cursor.y}px)`,
          }}
        >
          {/* Cursor pointer */}
          <svg
            className="h-5 w-5"
            viewBox="0 0 24 24"
            fill={cursor.color}
          >
            <path d="M5.65376 12.4561L4.88965 5.52588C4.75081 4.31568 5.74895 3.31753 6.95916 3.45637L20.0 5L13.0696 11.9304C12.2185 12.7815 10.8879 13.0059 9.80337 12.4561L5.65376 12.4561Z" />
          </svg>
          {/* Username label */}
          <div
            className="ml-5 rounded px-2 py-1 text-xs text-white whitespace-nowrap"
            style={{ backgroundColor: cursor.color }}
          >
            {cursor.username}
          </div>
        </div>
      ))}
    </>
  );
}
```

---

## Best Practices

### Do's
- Implement reconnection logic with exponential backoff
- Use heartbeat/ping-pong for connection health
- Debounce frequent updates (cursor positions)
- Show connection status to users
- Handle offline gracefully
- Use optimistic updates for better UX
- Clean up connections on unmount

### Don'ts
- Don't send sensitive data without encryption (use WSS)
- Don't poll too frequently (respect rate limits)
- Don't ignore connection errors
- Don't forget to handle reconnection edge cases
- Don't block the UI while waiting for real-time updates
- Don't store sensitive data in WebSocket state

## Security Considerations

- Always use WSS (WebSocket Secure) in production
- Validate all incoming messages on the server
- Implement authentication for WebSocket connections
- Rate limit messages to prevent abuse
- Sanitize user-generated content before display
- Handle connection timeouts appropriately
