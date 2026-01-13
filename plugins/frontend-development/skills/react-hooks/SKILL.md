---
name: react-hooks
description: Production-ready custom React hooks for common patterns. Includes useLocalStorage, useDebounce, useMediaQuery, useClickOutside, useIntersectionObserver, useCopyToClipboard, useAsync, usePrevious, useWindowSize, useKeyPress, and more. Use when implementing reusable stateful logic.
---

# React Hooks Library

Production-ready custom React hooks for common UI patterns and stateful logic. All hooks are TypeScript-first, SSR-compatible, and follow React best practices.

## When to Use This Skill

- Implementing reusable stateful logic
- Handling browser APIs (localStorage, clipboard, etc.)
- Managing async operations
- Detecting user interactions (clicks, keys, scroll)
- Responsive design with media queries
- Performance optimization (debounce, throttle)

## Core Hooks

---

### 1. useLocalStorage

Persist state to localStorage with SSR support.

```typescript
// hooks/use-local-storage.ts
import { useState, useEffect, useCallback } from "react";

type SetValue<T> = T | ((prevValue: T) => T);

export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: SetValue<T>) => void, () => void] {
  // State to store our value
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === "undefined") {
      return initialValue;
    }
    try {
      const item = window.localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialValue;
    } catch (error) {
      console.warn(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  // Return a wrapped version of useState's setter function
  const setValue = useCallback(
    (value: SetValue<T>) => {
      try {
        const valueToStore = value instanceof Function ? value(storedValue) : value;
        setStoredValue(valueToStore);
        if (typeof window !== "undefined") {
          window.localStorage.setItem(key, JSON.stringify(valueToStore));
          // Dispatch storage event for cross-tab sync
          window.dispatchEvent(new StorageEvent("storage", { key, newValue: JSON.stringify(valueToStore) }));
        }
      } catch (error) {
        console.warn(`Error setting localStorage key "${key}":`, error);
      }
    },
    [key, storedValue]
  );

  // Remove from storage
  const removeValue = useCallback(() => {
    try {
      setStoredValue(initialValue);
      if (typeof window !== "undefined") {
        window.localStorage.removeItem(key);
      }
    } catch (error) {
      console.warn(`Error removing localStorage key "${key}":`, error);
    }
  }, [key, initialValue]);

  // Listen for changes in other tabs/windows
  useEffect(() => {
    const handleStorageChange = (event: StorageEvent) => {
      if (event.key === key && event.newValue !== null) {
        try {
          setStoredValue(JSON.parse(event.newValue));
        } catch {
          setStoredValue(event.newValue as unknown as T);
        }
      }
    };

    window.addEventListener("storage", handleStorageChange);
    return () => window.removeEventListener("storage", handleStorageChange);
  }, [key]);

  return [storedValue, setValue, removeValue];
}
```

**Usage:**
```tsx
function Settings() {
  const [theme, setTheme, removeTheme] = useLocalStorage("theme", "light");

  return (
    <button onClick={() => setTheme(t => t === "light" ? "dark" : "light")}>
      Current: {theme}
    </button>
  );
}
```

---

### 2. useDebounce

Debounce a value with configurable delay.

```typescript
// hooks/use-debounce.ts
import { useState, useEffect } from "react";

export function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}

// Callback version
export function useDebouncedCallback<T extends (...args: any[]) => any>(
  callback: T,
  delay: number = 500
): (...args: Parameters<T>) => void {
  const [timeoutId, setTimeoutId] = useState<NodeJS.Timeout | null>(null);

  useEffect(() => {
    return () => {
      if (timeoutId) clearTimeout(timeoutId);
    };
  }, [timeoutId]);

  return (...args: Parameters<T>) => {
    if (timeoutId) clearTimeout(timeoutId);
    const id = setTimeout(() => callback(...args), delay);
    setTimeoutId(id);
  };
}
```

**Usage:**
```tsx
function SearchInput() {
  const [query, setQuery] = useState("");
  const debouncedQuery = useDebounce(query, 300);

  useEffect(() => {
    if (debouncedQuery) {
      // Perform search
      searchAPI(debouncedQuery);
    }
  }, [debouncedQuery]);

  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

---

### 3. useThrottle

Throttle a value or callback.

```typescript
// hooks/use-throttle.ts
import { useState, useEffect, useRef, useCallback } from "react";

export function useThrottle<T>(value: T, limit: number = 500): T {
  const [throttledValue, setThrottledValue] = useState<T>(value);
  const lastRan = useRef(Date.now());

  useEffect(() => {
    const handler = setTimeout(() => {
      if (Date.now() - lastRan.current >= limit) {
        setThrottledValue(value);
        lastRan.current = Date.now();
      }
    }, limit - (Date.now() - lastRan.current));

    return () => clearTimeout(handler);
  }, [value, limit]);

  return throttledValue;
}

export function useThrottledCallback<T extends (...args: any[]) => any>(
  callback: T,
  limit: number = 500
): (...args: Parameters<T>) => void {
  const lastRan = useRef(Date.now());
  const timeoutId = useRef<NodeJS.Timeout | null>(null);

  return useCallback(
    (...args: Parameters<T>) => {
      if (Date.now() - lastRan.current >= limit) {
        callback(...args);
        lastRan.current = Date.now();
      } else {
        if (timeoutId.current) clearTimeout(timeoutId.current);
        timeoutId.current = setTimeout(() => {
          callback(...args);
          lastRan.current = Date.now();
        }, limit - (Date.now() - lastRan.current));
      }
    },
    [callback, limit]
  );
}
```

---

### 4. useMediaQuery

Responsive design with media query matching.

```typescript
// hooks/use-media-query.ts
import { useState, useEffect } from "react";

export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState<boolean>(() => {
    if (typeof window === "undefined") return false;
    return window.matchMedia(query).matches;
  });

  useEffect(() => {
    if (typeof window === "undefined") return;

    const mediaQuery = window.matchMedia(query);
    setMatches(mediaQuery.matches);

    const handler = (event: MediaQueryListEvent) => {
      setMatches(event.matches);
    };

    // Modern browsers
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener("change", handler);
      return () => mediaQuery.removeEventListener("change", handler);
    }
    // Legacy browsers
    mediaQuery.addListener(handler);
    return () => mediaQuery.removeListener(handler);
  }, [query]);

  return matches;
}

// Preset breakpoints
export function useBreakpoint() {
  const isMobile = useMediaQuery("(max-width: 639px)");
  const isTablet = useMediaQuery("(min-width: 640px) and (max-width: 1023px)");
  const isDesktop = useMediaQuery("(min-width: 1024px)");
  const isLargeDesktop = useMediaQuery("(min-width: 1280px)");

  return {
    isMobile,
    isTablet,
    isDesktop,
    isLargeDesktop,
    // Tailwind breakpoint names
    sm: useMediaQuery("(min-width: 640px)"),
    md: useMediaQuery("(min-width: 768px)"),
    lg: useMediaQuery("(min-width: 1024px)"),
    xl: useMediaQuery("(min-width: 1280px)"),
    "2xl": useMediaQuery("(min-width: 1536px)"),
  };
}
```

**Usage:**
```tsx
function ResponsiveNav() {
  const { isMobile, isDesktop } = useBreakpoint();

  if (isMobile) return <MobileNav />;
  if (isDesktop) return <DesktopNav />;
  return <TabletNav />;
}

function DarkModeAware() {
  const prefersDark = useMediaQuery("(prefers-color-scheme: dark)");
  return <div className={prefersDark ? "dark" : "light"}>...</div>;
}
```

---

### 5. useClickOutside

Detect clicks outside an element.

```typescript
// hooks/use-click-outside.ts
import { useEffect, useRef, RefObject } from "react";

export function useClickOutside<T extends HTMLElement = HTMLElement>(
  handler: (event: MouseEvent | TouchEvent) => void,
  mouseEvent: "mousedown" | "mouseup" = "mousedown"
): RefObject<T> {
  const ref = useRef<T>(null);

  useEffect(() => {
    const listener = (event: MouseEvent | TouchEvent) => {
      const el = ref.current;
      if (!el || el.contains(event.target as Node)) {
        return;
      }
      handler(event);
    };

    document.addEventListener(mouseEvent, listener);
    document.addEventListener("touchstart", listener);

    return () => {
      document.removeEventListener(mouseEvent, listener);
      document.removeEventListener("touchstart", listener);
    };
  }, [handler, mouseEvent]);

  return ref;
}

// Multiple refs version
export function useClickOutsideMultiple<T extends HTMLElement = HTMLElement>(
  refs: RefObject<T>[],
  handler: (event: MouseEvent | TouchEvent) => void
): void {
  useEffect(() => {
    const listener = (event: MouseEvent | TouchEvent) => {
      const target = event.target as Node;
      const isOutside = refs.every((ref) => !ref.current?.contains(target));
      if (isOutside) handler(event);
    };

    document.addEventListener("mousedown", listener);
    document.addEventListener("touchstart", listener);

    return () => {
      document.removeEventListener("mousedown", listener);
      document.removeEventListener("touchstart", listener);
    };
  }, [refs, handler]);
}
```

**Usage:**
```tsx
function Dropdown() {
  const [isOpen, setIsOpen] = useState(false);
  const ref = useClickOutside<HTMLDivElement>(() => setIsOpen(false));

  return (
    <div ref={ref}>
      <button onClick={() => setIsOpen(true)}>Open</button>
      {isOpen && <div className="dropdown-menu">...</div>}
    </div>
  );
}
```

---

### 6. useIntersectionObserver

Detect when an element enters the viewport.

```typescript
// hooks/use-intersection-observer.ts
import { useState, useEffect, useRef, RefObject } from "react";

interface UseIntersectionObserverOptions extends IntersectionObserverInit {
  freezeOnceVisible?: boolean;
}

export function useIntersectionObserver<T extends HTMLElement = HTMLElement>(
  options: UseIntersectionObserverOptions = {}
): [RefObject<T>, IntersectionObserverEntry | undefined] {
  const { threshold = 0, root = null, rootMargin = "0%", freezeOnceVisible = false } = options;

  const ref = useRef<T>(null);
  const [entry, setEntry] = useState<IntersectionObserverEntry>();

  const frozen = entry?.isIntersecting && freezeOnceVisible;

  useEffect(() => {
    const node = ref.current;
    if (!node || frozen || typeof IntersectionObserver !== "function") return;

    const observer = new IntersectionObserver(
      ([entry]) => setEntry(entry),
      { threshold, root, rootMargin }
    );

    observer.observe(node);
    return () => observer.disconnect();
  }, [threshold, root, rootMargin, frozen]);

  return [ref, entry];
}

// Simplified boolean version
export function useOnScreen<T extends HTMLElement = HTMLElement>(
  options: IntersectionObserverInit = {}
): [RefObject<T>, boolean] {
  const [ref, entry] = useIntersectionObserver<T>(options);
  return [ref, entry?.isIntersecting ?? false];
}
```

**Usage:**
```tsx
function LazyImage({ src, alt }: { src: string; alt: string }) {
  const [ref, isVisible] = useOnScreen<HTMLDivElement>({ rootMargin: "100px" });

  return (
    <div ref={ref}>
      {isVisible ? <img src={src} alt={alt} /> : <div className="placeholder" />}
    </div>
  );
}

function AnimateOnScroll({ children }: { children: React.ReactNode }) {
  const [ref, entry] = useIntersectionObserver<HTMLDivElement>({
    threshold: 0.5,
    freezeOnceVisible: true
  });

  return (
    <div
      ref={ref}
      className={entry?.isIntersecting ? "animate-fade-in" : "opacity-0"}
    >
      {children}
    </div>
  );
}
```

---

### 7. useCopyToClipboard

Copy text to clipboard with feedback.

```typescript
// hooks/use-copy-to-clipboard.ts
import { useState, useCallback } from "react";

interface CopyState {
  value: string | null;
  success: boolean | null;
  error: Error | null;
}

export function useCopyToClipboard(): [
  CopyState,
  (text: string) => Promise<boolean>
] {
  const [state, setState] = useState<CopyState>({
    value: null,
    success: null,
    error: null,
  });

  const copy = useCallback(async (text: string): Promise<boolean> => {
    if (!navigator?.clipboard) {
      const error = new Error("Clipboard API not available");
      setState({ value: text, success: false, error });
      return false;
    }

    try {
      await navigator.clipboard.writeText(text);
      setState({ value: text, success: true, error: null });
      return true;
    } catch (error) {
      setState({ value: text, success: false, error: error as Error });
      return false;
    }
  }, []);

  return [state, copy];
}

// With auto-reset
export function useCopyToClipboardWithReset(
  resetDelay: number = 2000
): [boolean, (text: string) => Promise<void>] {
  const [copied, setCopied] = useState(false);

  const copy = useCallback(
    async (text: string) => {
      try {
        await navigator.clipboard.writeText(text);
        setCopied(true);
        setTimeout(() => setCopied(false), resetDelay);
      } catch {
        setCopied(false);
      }
    },
    [resetDelay]
  );

  return [copied, copy];
}
```

**Usage:**
```tsx
function CopyButton({ text }: { text: string }) {
  const [copied, copy] = useCopyToClipboardWithReset();

  return (
    <button onClick={() => copy(text)}>
      {copied ? "Copied!" : "Copy"}
    </button>
  );
}
```

---

### 8. useAsync

Handle async operations with loading and error states.

```typescript
// hooks/use-async.ts
import { useState, useCallback, useEffect, useRef } from "react";

interface AsyncState<T> {
  data: T | null;
  error: Error | null;
  isLoading: boolean;
  isSuccess: boolean;
  isError: boolean;
}

interface UseAsyncReturn<T, Args extends any[]> extends AsyncState<T> {
  execute: (...args: Args) => Promise<T | null>;
  reset: () => void;
}

export function useAsync<T, Args extends any[] = []>(
  asyncFunction: (...args: Args) => Promise<T>,
  immediate = false
): UseAsyncReturn<T, Args> {
  const [state, setState] = useState<AsyncState<T>>({
    data: null,
    error: null,
    isLoading: false,
    isSuccess: false,
    isError: false,
  });

  const isMounted = useRef(true);

  useEffect(() => {
    isMounted.current = true;
    return () => {
      isMounted.current = false;
    };
  }, []);

  const execute = useCallback(
    async (...args: Args): Promise<T | null> => {
      setState({
        data: null,
        error: null,
        isLoading: true,
        isSuccess: false,
        isError: false,
      });

      try {
        const data = await asyncFunction(...args);
        if (isMounted.current) {
          setState({
            data,
            error: null,
            isLoading: false,
            isSuccess: true,
            isError: false,
          });
        }
        return data;
      } catch (error) {
        if (isMounted.current) {
          setState({
            data: null,
            error: error as Error,
            isLoading: false,
            isSuccess: false,
            isError: true,
          });
        }
        return null;
      }
    },
    [asyncFunction]
  );

  const reset = useCallback(() => {
    setState({
      data: null,
      error: null,
      isLoading: false,
      isSuccess: false,
      isError: false,
    });
  }, []);

  useEffect(() => {
    if (immediate) {
      execute(...([] as unknown as Args));
    }
  }, [immediate, execute]);

  return { ...state, execute, reset };
}
```

**Usage:**
```tsx
function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, error, execute } = useAsync(
    () => fetchUser(userId),
    true // immediate execution
  );

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} onRetry={execute} />;
  if (!data) return null;

  return <Profile user={data} />;
}
```

---

### 9. usePrevious

Access the previous value of a state or prop.

```typescript
// hooks/use-previous.ts
import { useRef, useEffect } from "react";

export function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

// With initial value
export function usePreviousWithInitial<T>(value: T, initialValue: T): T {
  const ref = useRef<T>(initialValue);

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}
```

**Usage:**
```tsx
function Counter() {
  const [count, setCount] = useState(0);
  const prevCount = usePrevious(count);

  return (
    <div>
      <p>Current: {count}, Previous: {prevCount}</p>
      <button onClick={() => setCount(c => c + 1)}>Increment</button>
    </div>
  );
}
```

---

### 10. useWindowSize

Track window dimensions.

```typescript
// hooks/use-window-size.ts
import { useState, useEffect } from "react";

interface WindowSize {
  width: number;
  height: number;
}

export function useWindowSize(): WindowSize {
  const [windowSize, setWindowSize] = useState<WindowSize>(() => {
    if (typeof window === "undefined") {
      return { width: 0, height: 0 };
    }
    return {
      width: window.innerWidth,
      height: window.innerHeight,
    };
  });

  useEffect(() => {
    if (typeof window === "undefined") return;

    const handleResize = () => {
      setWindowSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };

    window.addEventListener("resize", handleResize);
    handleResize();

    return () => window.removeEventListener("resize", handleResize);
  }, []);

  return windowSize;
}

// Debounced version for performance
export function useWindowSizeDebounced(delay: number = 250): WindowSize {
  const [windowSize, setWindowSize] = useState<WindowSize>(() => ({
    width: typeof window !== "undefined" ? window.innerWidth : 0,
    height: typeof window !== "undefined" ? window.innerHeight : 0,
  }));

  useEffect(() => {
    if (typeof window === "undefined") return;

    let timeoutId: NodeJS.Timeout;

    const handleResize = () => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => {
        setWindowSize({
          width: window.innerWidth,
          height: window.innerHeight,
        });
      }, delay);
    };

    window.addEventListener("resize", handleResize);
    return () => {
      window.removeEventListener("resize", handleResize);
      clearTimeout(timeoutId);
    };
  }, [delay]);

  return windowSize;
}
```

---

### 11. useKeyPress

Detect keyboard key presses.

```typescript
// hooks/use-key-press.ts
import { useState, useEffect, useCallback } from "react";

export function useKeyPress(targetKey: string): boolean {
  const [keyPressed, setKeyPressed] = useState(false);

  useEffect(() => {
    const downHandler = (event: KeyboardEvent) => {
      if (event.key === targetKey) {
        setKeyPressed(true);
      }
    };

    const upHandler = (event: KeyboardEvent) => {
      if (event.key === targetKey) {
        setKeyPressed(false);
      }
    };

    window.addEventListener("keydown", downHandler);
    window.addEventListener("keyup", upHandler);

    return () => {
      window.removeEventListener("keydown", downHandler);
      window.removeEventListener("keyup", upHandler);
    };
  }, [targetKey]);

  return keyPressed;
}

// Keyboard shortcut hook
interface ShortcutOptions {
  ctrl?: boolean;
  shift?: boolean;
  alt?: boolean;
  meta?: boolean;
}

export function useKeyboardShortcut(
  key: string,
  callback: () => void,
  options: ShortcutOptions = {}
): void {
  const { ctrl = false, shift = false, alt = false, meta = false } = options;

  useEffect(() => {
    const handler = (event: KeyboardEvent) => {
      if (
        event.key.toLowerCase() === key.toLowerCase() &&
        event.ctrlKey === ctrl &&
        event.shiftKey === shift &&
        event.altKey === alt &&
        event.metaKey === meta
      ) {
        event.preventDefault();
        callback();
      }
    };

    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [key, callback, ctrl, shift, alt, meta]);
}

// Multiple keys
export function useKeyCombo(keys: string[], callback: () => void): void {
  const pressedKeys = useRef(new Set<string>());

  useEffect(() => {
    const downHandler = (event: KeyboardEvent) => {
      pressedKeys.current.add(event.key.toLowerCase());

      const allPressed = keys.every((k) =>
        pressedKeys.current.has(k.toLowerCase())
      );

      if (allPressed) {
        event.preventDefault();
        callback();
      }
    };

    const upHandler = (event: KeyboardEvent) => {
      pressedKeys.current.delete(event.key.toLowerCase());
    };

    window.addEventListener("keydown", downHandler);
    window.addEventListener("keyup", upHandler);

    return () => {
      window.removeEventListener("keydown", downHandler);
      window.removeEventListener("keyup", upHandler);
    };
  }, [keys, callback]);
}
```

**Usage:**
```tsx
function App() {
  const enterPressed = useKeyPress("Enter");

  // Ctrl+S to save
  useKeyboardShortcut("s", () => saveDocument(), { ctrl: true });

  // Escape to close modal
  useKeyboardShortcut("Escape", () => setModalOpen(false));

  return <div>{enterPressed && "Enter is pressed!"}</div>;
}
```

---

### 12. useHover

Detect hover state.

```typescript
// hooks/use-hover.ts
import { useState, useRef, useEffect, RefObject } from "react";

export function useHover<T extends HTMLElement = HTMLElement>(): [
  RefObject<T>,
  boolean
] {
  const [isHovered, setIsHovered] = useState(false);
  const ref = useRef<T>(null);

  useEffect(() => {
    const node = ref.current;
    if (!node) return;

    const handleMouseEnter = () => setIsHovered(true);
    const handleMouseLeave = () => setIsHovered(false);

    node.addEventListener("mouseenter", handleMouseEnter);
    node.addEventListener("mouseleave", handleMouseLeave);

    return () => {
      node.removeEventListener("mouseenter", handleMouseEnter);
      node.removeEventListener("mouseleave", handleMouseLeave);
    };
  }, []);

  return [ref, isHovered];
}
```

---

### 13. useFocus

Track focus state of an element.

```typescript
// hooks/use-focus.ts
import { useState, useRef, useEffect, useCallback, RefObject } from "react";

export function useFocus<T extends HTMLElement = HTMLElement>(): [
  RefObject<T>,
  boolean,
  { focus: () => void; blur: () => void }
] {
  const [isFocused, setIsFocused] = useState(false);
  const ref = useRef<T>(null);

  useEffect(() => {
    const node = ref.current;
    if (!node) return;

    const handleFocus = () => setIsFocused(true);
    const handleBlur = () => setIsFocused(false);

    node.addEventListener("focus", handleFocus);
    node.addEventListener("blur", handleBlur);

    return () => {
      node.removeEventListener("focus", handleFocus);
      node.removeEventListener("blur", handleBlur);
    };
  }, []);

  const focus = useCallback(() => ref.current?.focus(), []);
  const blur = useCallback(() => ref.current?.blur(), []);

  return [ref, isFocused, { focus, blur }];
}
```

---

### 14. useToggle

Toggle boolean state.

```typescript
// hooks/use-toggle.ts
import { useState, useCallback } from "react";

export function useToggle(
  initialValue: boolean = false
): [boolean, () => void, (value: boolean) => void] {
  const [value, setValue] = useState(initialValue);

  const toggle = useCallback(() => setValue((v) => !v), []);
  const set = useCallback((newValue: boolean) => setValue(newValue), []);

  return [value, toggle, set];
}

// With on/off helpers
export function useBoolean(initialValue: boolean = false) {
  const [value, setValue] = useState(initialValue);

  const setTrue = useCallback(() => setValue(true), []);
  const setFalse = useCallback(() => setValue(false), []);
  const toggle = useCallback(() => setValue((v) => !v), []);

  return { value, setValue, setTrue, setFalse, toggle };
}
```

---

### 15. useInterval & useTimeout

Declarative setInterval and setTimeout.

```typescript
// hooks/use-interval.ts
import { useEffect, useRef } from "react";

export function useInterval(callback: () => void, delay: number | null): void {
  const savedCallback = useRef(callback);

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    if (delay === null) return;

    const tick = () => savedCallback.current();
    const id = setInterval(tick, delay);

    return () => clearInterval(id);
  }, [delay]);
}

// hooks/use-timeout.ts
export function useTimeout(callback: () => void, delay: number | null): void {
  const savedCallback = useRef(callback);

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    if (delay === null) return;

    const id = setTimeout(() => savedCallback.current(), delay);
    return () => clearTimeout(id);
  }, [delay]);
}

// Controllable timeout
export function useTimeoutFn(
  fn: () => void,
  ms: number = 0
): [boolean, () => void, () => void] {
  const [isReady, setIsReady] = useState(false);
  const timeoutRef = useRef<NodeJS.Timeout>();

  const clear = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
  }, []);

  const set = useCallback(() => {
    setIsReady(false);
    clear();
    timeoutRef.current = setTimeout(() => {
      setIsReady(true);
      fn();
    }, ms);
  }, [ms, fn, clear]);

  useEffect(() => clear, [clear]);

  return [isReady, set, clear];
}
```

---

### 16. useEventListener

Attach event listeners declaratively.

```typescript
// hooks/use-event-listener.ts
import { useEffect, useRef, RefObject } from "react";

export function useEventListener<K extends keyof WindowEventMap>(
  eventName: K,
  handler: (event: WindowEventMap[K]) => void,
  element?: undefined,
  options?: boolean | AddEventListenerOptions
): void;

export function useEventListener<
  K extends keyof HTMLElementEventMap,
  T extends HTMLElement = HTMLDivElement
>(
  eventName: K,
  handler: (event: HTMLElementEventMap[K]) => void,
  element: RefObject<T>,
  options?: boolean | AddEventListenerOptions
): void;

export function useEventListener<K extends keyof DocumentEventMap>(
  eventName: K,
  handler: (event: DocumentEventMap[K]) => void,
  element: RefObject<Document>,
  options?: boolean | AddEventListenerOptions
): void;

export function useEventListener<
  KW extends keyof WindowEventMap,
  KH extends keyof HTMLElementEventMap,
  T extends HTMLElement | void = void
>(
  eventName: KW | KH,
  handler: (event: WindowEventMap[KW] | HTMLElementEventMap[KH] | Event) => void,
  element?: RefObject<T>,
  options?: boolean | AddEventListenerOptions
) {
  const savedHandler = useRef(handler);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    const targetElement: T | Window = element?.current ?? window;
    if (!(targetElement && targetElement.addEventListener)) return;

    const listener: typeof handler = (event) => savedHandler.current(event);
    targetElement.addEventListener(eventName, listener, options);

    return () => {
      targetElement.removeEventListener(eventName, listener, options);
    };
  }, [eventName, element, options]);
}
```

---

### 17. useScrollPosition

Track scroll position.

```typescript
// hooks/use-scroll-position.ts
import { useState, useEffect } from "react";

interface ScrollPosition {
  x: number;
  y: number;
}

export function useScrollPosition(): ScrollPosition {
  const [scrollPosition, setScrollPosition] = useState<ScrollPosition>({
    x: 0,
    y: 0,
  });

  useEffect(() => {
    const handleScroll = () => {
      setScrollPosition({
        x: window.scrollX,
        y: window.scrollY,
      });
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    handleScroll();

    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return scrollPosition;
}

// With scroll direction
export function useScrollDirection() {
  const [scrollDirection, setScrollDirection] = useState<"up" | "down" | null>(null);
  const [lastScrollY, setLastScrollY] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY;

      if (currentScrollY > lastScrollY) {
        setScrollDirection("down");
      } else if (currentScrollY < lastScrollY) {
        setScrollDirection("up");
      }

      setLastScrollY(currentScrollY);
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, [lastScrollY]);

  return scrollDirection;
}
```

---

### 18. useLockBodyScroll

Prevent body scrolling (useful for modals).

```typescript
// hooks/use-lock-body-scroll.ts
import { useEffect } from "react";

export function useLockBodyScroll(lock: boolean = true): void {
  useEffect(() => {
    if (!lock) return;

    const originalStyle = window.getComputedStyle(document.body).overflow;
    document.body.style.overflow = "hidden";

    return () => {
      document.body.style.overflow = originalStyle;
    };
  }, [lock]);
}
```

---

## Best Practices

### Do's
- Always clean up effects (event listeners, timers)
- Use refs for values that shouldn't trigger re-renders
- Handle SSR with typeof window checks
- Memoize callbacks with useCallback
- Use TypeScript generics for flexibility

### Don'ts
- Don't forget dependency arrays
- Don't mutate refs in render
- Don't create hooks conditionally
- Don't ignore cleanup functions
- Don't use hooks in loops

## Testing Hooks

```typescript
// __tests__/use-toggle.test.ts
import { renderHook, act } from "@testing-library/react";
import { useToggle } from "../hooks/use-toggle";

describe("useToggle", () => {
  it("should toggle value", () => {
    const { result } = renderHook(() => useToggle(false));

    expect(result.current[0]).toBe(false);

    act(() => {
      result.current[1](); // toggle
    });

    expect(result.current[0]).toBe(true);
  });
});
```
