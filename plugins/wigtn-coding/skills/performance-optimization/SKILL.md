---
name: mobile-performance
description: Master React Native performance optimization - FlatList tuning, memory management, bundle size reduction, startup time, and Hermes engine configuration.
---

# Mobile Performance Optimization

Comprehensive guide to optimizing React Native app performance including lists, images, memory, startup time, and bundle size.

## When to Use This Skill

- Optimizing scrolling performance
- Reducing app startup time
- Managing memory usage
- Decreasing bundle size
- Profiling performance bottlenecks

## Core Concepts

### 1. Key Performance Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **Startup Time** | < 2s | Flipper, React DevTools |
| **FPS** | 60 | Perf Monitor |
| **Memory** | < 200MB | Xcode/Android Studio |
| **Bundle Size** | < 10MB | metro-bundle-analyzer |
| **TTI** | < 3s | Custom timing |

### 2. Performance Checklist

```
[ ] Hermes enabled
[ ] FlatList optimized
[ ] Images optimized
[ ] Animations on native driver
[ ] Memoization where needed
[ ] Bundle size analyzed
```

## Patterns

### Pattern 1: FlatList / FlashList Optimization

```typescript
// Use FlashList for better performance
import { FlashList } from '@shopify/flash-list';

interface Item {
  id: string;
  title: string;
  description: string;
  imageUrl: string;
}

// Optimized list component
export function OptimizedList({ data }: { data: Item[] }) {
  const renderItem = useCallback(({ item }: { item: Item }) => (
    <ListItem item={item} />
  ), []);

  const keyExtractor = useCallback((item: Item) => item.id, []);

  return (
    <FlashList
      data={data}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      estimatedItemSize={100} // Required for FlashList
      // Performance optimizations
      removeClippedSubviews={true}
      getItemType={(item) => item.type || 'default'}
    />
  );
}

// For regular FlatList
export function OptimizedFlatList({ data }: { data: Item[] }) {
  const renderItem = useCallback(({ item }: { item: Item }) => (
    <ListItem item={item} />
  ), []);

  const keyExtractor = useCallback((item: Item) => item.id, []);

  const getItemLayout = useCallback(
    (_: any, index: number) => ({
      length: ITEM_HEIGHT,
      offset: ITEM_HEIGHT * index,
      index,
    }),
    []
  );

  return (
    <FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      // Performance optimizations
      getItemLayout={getItemLayout} // If fixed height
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      updateCellsBatchingPeriod={50}
      windowSize={10}
      initialNumToRender={10}
      // Disable if not needed
      maintainVisibleContentPosition={undefined}
    />
  );
}

// Memoized list item
const ListItem = memo(function ListItem({ item }: { item: Item }) {
  return (
    <View className="p-4 border-b border-border">
      <Image
        source={{ uri: item.imageUrl }}
        className="w-20 h-20 rounded-lg"
        // expo-image is faster than Image
      />
      <Text className="font-semibold">{item.title}</Text>
      <Text className="text-muted-foreground">{item.description}</Text>
    </View>
  );
}, (prevProps, nextProps) => {
  // Custom comparison for better memo performance
  return prevProps.item.id === nextProps.item.id;
});
```

### Pattern 2: Image Optimization

```bash
npx expo install expo-image
```

```typescript
// Use expo-image for better performance
import { Image } from 'expo-image';

// Optimized image component
export function OptimizedImage({
  source,
  style,
  ...props
}: {
  source: string;
  style?: any;
}) {
  return (
    <Image
      source={source}
      style={style}
      // Performance options
      contentFit="cover"
      transition={200}
      cachePolicy="memory-disk" // Cache in memory and disk
      placeholder={blurhash} // Show placeholder while loading
      placeholderContentFit="cover"
      // Lazy loading
      priority="normal" // 'low' | 'normal' | 'high'
      {...props}
    />
  );
}

// Preload critical images
import { Image } from 'expo-image';

export async function preloadImages(urls: string[]) {
  await Image.prefetch(urls);
}

// In your app initialization
useEffect(() => {
  preloadImages([
    '/images/hero.jpg',
    '/images/logo.png',
  ]);
}, []);

// Progressive image loading
export function ProgressiveImage({
  thumbnailSource,
  source,
  style,
}: {
  thumbnailSource: string;
  source: string;
  style?: any;
}) {
  const [loaded, setLoaded] = useState(false);

  return (
    <View style={style}>
      {/* Thumbnail (blurred, small) */}
      <Image
        source={thumbnailSource}
        style={[StyleSheet.absoluteFill, { opacity: loaded ? 0 : 1 }]}
        blurRadius={10}
        cachePolicy="memory"
      />
      {/* Full image */}
      <Image
        source={source}
        style={StyleSheet.absoluteFill}
        onLoad={() => setLoaded(true)}
        cachePolicy="memory-disk"
      />
    </View>
  );
}
```

### Pattern 3: Memoization Patterns

```typescript
// Proper use of useMemo
function ExpensiveComponent({ items, filter }: { items: Item[]; filter: string }) {
  // Good: expensive computation
  const filteredItems = useMemo(() => {
    return items.filter((item) =>
      item.title.toLowerCase().includes(filter.toLowerCase())
    );
  }, [items, filter]);

  // Good: object reference stability
  const style = useMemo(() => ({
    container: { padding: 16 },
    title: { fontSize: 24 },
  }), []);

  return (
    <View style={style.container}>
      {filteredItems.map((item) => (
        <ItemCard key={item.id} item={item} />
      ))}
    </View>
  );
}

// Proper use of useCallback
function ParentComponent() {
  const [count, setCount] = useState(0);

  // Good: callback passed to memoized child
  const handlePress = useCallback(() => {
    setCount((c) => c + 1);
  }, []);

  // Good: callback with dependencies
  const handleSubmit = useCallback((data: FormData) => {
    api.submit(data);
  }, []);

  return (
    <>
      <MemoizedChild onPress={handlePress} />
      <Form onSubmit={handleSubmit} />
    </>
  );
}

// memo with custom comparison
const ItemCard = memo(
  function ItemCard({ item, onPress }: { item: Item; onPress: () => void }) {
    return (
      <Pressable onPress={onPress}>
        <Text>{item.title}</Text>
      </Pressable>
    );
  },
  (prevProps, nextProps) => {
    // Only re-render if these specific properties change
    return (
      prevProps.item.id === nextProps.item.id &&
      prevProps.item.title === nextProps.item.title
    );
  }
);

// When NOT to memoize
function SimpleComponent({ title }: { title: string }) {
  // Bad: primitive value doesn't need useMemo
  // const memoizedTitle = useMemo(() => title, [title]);

  // Bad: simple inline callback in non-memoized child
  // const handlePress = useCallback(() => console.log('pressed'), []);

  return (
    <Pressable onPress={() => console.log('pressed')}>
      <Text>{title}</Text>
    </Pressable>
  );
}
```

### Pattern 4: Animation Performance

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  runOnJS,
} from 'react-native-reanimated';

// Always use native driver animations
function AnimatedCard() {
  const scale = useSharedValue(1);
  const opacity = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }));

  const handlePressIn = () => {
    scale.value = withSpring(0.95);
  };

  const handlePressOut = () => {
    scale.value = withSpring(1);
  };

  return (
    <Pressable onPressIn={handlePressIn} onPressOut={handlePressOut}>
      <Animated.View style={animatedStyle} className="bg-card p-4 rounded-xl">
        <Text>Animated Card</Text>
      </Animated.View>
    </Pressable>
  );
}

// Avoid JS thread blocking in animations
function ScrollAnimatedHeader() {
  const scrollY = useSharedValue(0);

  const headerStyle = useAnimatedStyle(() => {
    // All calculations run on UI thread
    const opacity = interpolate(
      scrollY.value,
      [0, 100],
      [1, 0],
      Extrapolation.CLAMP
    );

    const translateY = interpolate(
      scrollY.value,
      [0, 100],
      [0, -50],
      Extrapolation.CLAMP
    );

    return {
      opacity,
      transform: [{ translateY }],
    };
  });

  const scrollHandler = useAnimatedScrollHandler({
    onScroll: (event) => {
      scrollY.value = event.contentOffset.y;
    },
  });

  return (
    <>
      <Animated.View style={headerStyle} className="absolute top-0 left-0 right-0">
        <Header />
      </Animated.View>
      <Animated.ScrollView onScroll={scrollHandler} scrollEventThrottle={16}>
        <Content />
      </Animated.ScrollView>
    </>
  );
}

// Avoid: Complex JS callbacks during animation
// Bad
const animatedStyle = useAnimatedStyle(() => {
  // This runs on UI thread but runOnJS switches to JS thread
  runOnJS(complexCalculation)(scrollY.value); // Avoid!
  return { opacity: scrollY.value };
});
```

### Pattern 5: Bundle Size Optimization

```javascript
// metro.config.js - Enable tree shaking
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Enable minification
config.transformer.minifierConfig = {
  keep_fnames: true,
  mangle: {
    keep_fnames: true,
  },
};

module.exports = config;

// Analyze bundle
// npx react-native-bundle-visualizer

// Dynamic imports for code splitting
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyComponent />
    </Suspense>
  );
}

// Import only what you need
// Bad
import _ from 'lodash';
_.debounce(fn, 300);

// Good
import debounce from 'lodash/debounce';
debounce(fn, 300);

// Or use smaller alternatives
import { debounce } from 'lodash-es'; // Tree-shakeable
// Or just write it yourself for simple cases

// Avoid large libraries
// Instead of moment.js (300KB), use:
import { format } from 'date-fns'; // Tree-shakeable

// Instead of lodash for simple operations
// Use native Array methods
const sorted = items.sort((a, b) => a.name.localeCompare(b.name));
const grouped = items.reduce((acc, item) => {
  const key = item.category;
  acc[key] = [...(acc[key] || []), item];
  return acc;
}, {});
```

### Pattern 6: Startup Time Optimization

```typescript
// app.json - Enable Hermes
{
  "expo": {
    "jsEngine": "hermes"
  }
}

// Defer non-critical initialization
import { InteractionManager } from 'react-native';

function App() {
  useEffect(() => {
    // Wait for initial render and animations
    InteractionManager.runAfterInteractions(() => {
      // Initialize analytics
      initAnalytics();
      // Preload data
      prefetchData();
      // Register background tasks
      registerBackgroundTasks();
    });
  }, []);

  return <MainApp />;
}

// Lazy load screens
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        // Lazy load tab screens
        lazy: true,
      }}
    >
      <Tabs.Screen name="index" />
      <Tabs.Screen name="explore" />
      <Tabs.Screen name="profile" />
    </Tabs>
  );
}

// Splash screen management
import * as SplashScreen from 'expo-splash-screen';

SplashScreen.preventAutoHideAsync();

function App() {
  const [appReady, setAppReady] = useState(false);

  useEffect(() => {
    async function prepare() {
      try {
        // Load fonts
        await Font.loadAsync(fonts);
        // Load critical data
        await loadInitialData();
        // Hydrate auth state
        await authStore.hydrate();
      } catch (e) {
        console.warn(e);
      } finally {
        setAppReady(true);
      }
    }

    prepare();
  }, []);

  const onLayoutRootView = useCallback(async () => {
    if (appReady) {
      await SplashScreen.hideAsync();
    }
  }, [appReady]);

  if (!appReady) {
    return null;
  }

  return (
    <View style={{ flex: 1 }} onLayout={onLayoutRootView}>
      <Navigation />
    </View>
  );
}
```

### Pattern 7: Memory Management

```typescript
// Clean up subscriptions and listeners
function useLocationTracking() {
  useEffect(() => {
    let subscription: Location.LocationSubscription | null = null;

    (async () => {
      subscription = await Location.watchPositionAsync(
        { accuracy: Location.Accuracy.High },
        (location) => {
          // Handle location
        }
      );
    })();

    // Cleanup on unmount
    return () => {
      subscription?.remove();
    };
  }, []);
}

// Avoid memory leaks with async operations
function useFetchData() {
  const [data, setData] = useState(null);

  useEffect(() => {
    let isMounted = true;

    async function fetchData() {
      const result = await api.getData();
      // Only update state if component is still mounted
      if (isMounted) {
        setData(result);
      }
    }

    fetchData();

    return () => {
      isMounted = false;
    };
  }, []);

  return data;
}

// Use AbortController for fetch
function useCancellableFetch(url: string) {
  const [data, setData] = useState(null);

  useEffect(() => {
    const controller = new AbortController();

    fetch(url, { signal: controller.signal })
      .then((res) => res.json())
      .then(setData)
      .catch((err) => {
        if (err.name !== 'AbortError') {
          console.error(err);
        }
      });

    return () => {
      controller.abort();
    };
  }, [url]);

  return data;
}

// Profile memory usage
import { useEffect } from 'react';

function useMemoryWarning() {
  useEffect(() => {
    if (__DEV__) {
      const interval = setInterval(() => {
        // Log memory usage in development
        if (global.performance?.memory) {
          console.log('Memory:', global.performance.memory);
        }
      }, 10000);

      return () => clearInterval(interval);
    }
  }, []);
}
```

## Profiling Tools

### Flipper

```bash
# Install Flipper
# https://fbflipper.com/

# Enable in app
# Already enabled by default in Expo Dev Client
```

### React DevTools

```bash
# In terminal while app is running
npx react-devtools

# Look for:
# - Unnecessary re-renders (highlight updates)
# - Component flame graph
# - Profiler recordings
```

### Performance Monitor

```typescript
// Enable in dev menu: "Perf Monitor"
// Or programmatically:
import { PerfMonitor } from 'react-native';

// In development
if (__DEV__) {
  PerfMonitor.show();
}
```

## Best Practices

### Do's

- **Enable Hermes** - 2x startup improvement
- **Use FlashList** - Better than FlatList
- **Memoize expensive operations** - useMemo, useCallback, memo
- **Use native driver** - For all animations
- **Profile regularly** - Catch regressions early

### Don'ts

- **Don't over-memoize** - Has its own cost
- **Don't block JS thread** - During animations
- **Don't use inline styles** - In lists
- **Don't ignore memory leaks** - Clean up subscriptions
- **Don't load everything at startup** - Lazy load

## Resources

- [React Native Performance](https://reactnative.dev/docs/performance)
- [FlashList](https://shopify.github.io/flash-list/)
- [Hermes Engine](https://hermesengine.dev/)
- [Flipper](https://fbflipper.com/)
