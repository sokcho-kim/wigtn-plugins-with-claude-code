---
name: responsive-design
description: Master responsive design for multiple device sizes - phones, tablets, foldables. Implement adaptive layouts, breakpoints, and scaling strategies for React Native.
---

# Responsive Design for Mobile

Comprehensive guide to building responsive React Native apps that work across phones, tablets, and foldables.

## When to Use This Skill

- Building apps for multiple device sizes
- Supporting tablets alongside phones
- Adapting layouts for landscape mode
- Implementing foldable device support
- Creating responsive components

## Core Concepts

### 1. Device Categories

| Category | Width | Examples |
|----------|-------|----------|
| **Small Phone** | < 375px | iPhone SE, older Android |
| **Regular Phone** | 375-428px | iPhone 14, Pixel 7 |
| **Large Phone** | > 428px | iPhone 14 Pro Max |
| **Tablet** | > 768px | iPad, Android tablets |
| **Foldable** | Variable | Galaxy Fold |

### 2. Scaling Strategies

```
Flexbox → For adaptive layouts (recommended)
Percentage → For relative sizing
scale() → For proportional dimensions
Breakpoints → For layout changes
```

## Patterns

### Pattern 1: Device Detection Hook

```typescript
// hooks/useDevice.ts
import { useState, useEffect } from 'react';
import { Dimensions, ScaledSize, useWindowDimensions } from 'react-native';

interface DeviceInfo {
  width: number;
  height: number;
  isSmallPhone: boolean;
  isPhone: boolean;
  isTablet: boolean;
  isLandscape: boolean;
  scale: number;
  fontScale: number;
}

export function useDevice(): DeviceInfo {
  const { width, height, scale, fontScale } = useWindowDimensions();

  const isLandscape = width > height;
  const isSmallPhone = width < 375;
  const isTablet = Math.min(width, height) >= 768;
  const isPhone = !isTablet;

  return {
    width,
    height,
    isSmallPhone,
    isPhone,
    isTablet,
    isLandscape,
    scale,
    fontScale,
  };
}

// Usage
function MyComponent() {
  const { isTablet, isLandscape } = useDevice();

  return (
    <View className={isTablet ? 'flex-row' : 'flex-col'}>
      {/* Layout adapts to device */}
    </View>
  );
}
```

### Pattern 2: Breakpoint System

```typescript
// lib/breakpoints.ts
import { Dimensions } from 'react-native';

const { width } = Dimensions.get('window');

export const breakpoints = {
  sm: 375,   // Small phones
  md: 428,   // Regular phones
  lg: 768,   // Tablets
  xl: 1024,  // Large tablets
} as const;

export function isBreakpoint(breakpoint: keyof typeof breakpoints): boolean {
  return width >= breakpoints[breakpoint];
}

// hooks/useBreakpoint.ts
import { useWindowDimensions } from 'react-native';
import { breakpoints } from '@/lib/breakpoints';

type Breakpoint = 'sm' | 'md' | 'lg' | 'xl';

export function useBreakpoint(): Breakpoint {
  const { width } = useWindowDimensions();

  if (width >= breakpoints.xl) return 'xl';
  if (width >= breakpoints.lg) return 'lg';
  if (width >= breakpoints.md) return 'md';
  return 'sm';
}

export function useBreakpointValue<T>(values: Partial<Record<Breakpoint, T>>): T | undefined {
  const breakpoint = useBreakpoint();

  // Return the value for the current breakpoint or the next smaller one
  const breakpointOrder: Breakpoint[] = ['sm', 'md', 'lg', 'xl'];
  const currentIndex = breakpointOrder.indexOf(breakpoint);

  for (let i = currentIndex; i >= 0; i--) {
    const bp = breakpointOrder[i];
    if (values[bp] !== undefined) {
      return values[bp];
    }
  }

  return undefined;
}

// Usage
function ResponsiveGrid({ children }: { children: React.ReactNode }) {
  const columns = useBreakpointValue({
    sm: 2,
    md: 3,
    lg: 4,
    xl: 6,
  }) ?? 2;

  return (
    <View className="flex-row flex-wrap">
      {React.Children.map(children, (child, index) => (
        <View style={{ width: `${100 / columns}%` }}>
          {child}
        </View>
      ))}
    </View>
  );
}
```

### Pattern 3: Adaptive Layouts

```tsx
// components/AdaptiveLayout.tsx
import { View } from 'react-native';
import { useDevice } from '@/hooks/useDevice';

interface AdaptiveLayoutProps {
  children: React.ReactNode;
  sidebar?: React.ReactNode;
}

export function AdaptiveLayout({ children, sidebar }: AdaptiveLayoutProps) {
  const { isTablet, isLandscape } = useDevice();
  const showSidebar = isTablet || isLandscape;

  if (showSidebar && sidebar) {
    return (
      <View className="flex-1 flex-row">
        <View className="w-80 border-r border-border">
          {sidebar}
        </View>
        <View className="flex-1">
          {children}
        </View>
      </View>
    );
  }

  return <View className="flex-1">{children}</View>;
}

// Master-Detail Pattern for tablets
export function MasterDetailLayout({
  master,
  detail,
  showDetail,
}: {
  master: React.ReactNode;
  detail: React.ReactNode;
  showDetail: boolean;
}) {
  const { isTablet } = useDevice();

  // Tablet: Side-by-side
  if (isTablet) {
    return (
      <View className="flex-1 flex-row">
        <View className="w-96 border-r border-border">
          {master}
        </View>
        <View className="flex-1">
          {showDetail ? detail : <EmptyState />}
        </View>
      </View>
    );
  }

  // Phone: Stack navigation
  return showDetail ? detail : master;
}

// Responsive Grid
export function ResponsiveGrid({ children }: { children: React.ReactNode }) {
  const { isTablet, isLandscape } = useDevice();

  const columns = isTablet ? 3 : isLandscape ? 3 : 2;

  return (
    <View className="flex-row flex-wrap p-2">
      {React.Children.map(children, (child) => (
        <View
          style={{ width: `${100 / columns}%` }}
          className="p-2"
        >
          {child}
        </View>
      ))}
    </View>
  );
}
```

### Pattern 4: Responsive Typography

```typescript
// lib/typography.ts
import { PixelRatio, Platform } from 'react-native';
import { moderateScale } from 'react-native-size-matters';

// Base font sizes (iPhone 14 Pro - 393px width)
const baseFontSizes = {
  xs: 12,
  sm: 14,
  base: 16,
  lg: 18,
  xl: 20,
  '2xl': 24,
  '3xl': 30,
  '4xl': 36,
} as const;

// Scale font sizes with moderate scaling
export const fontSize = Object.entries(baseFontSizes).reduce(
  (acc, [key, value]) => ({
    ...acc,
    [key]: moderateScale(value, 0.3),
  }),
  {} as Record<keyof typeof baseFontSizes, number>
);

// Respect user's accessibility settings
export function getAccessibleFontSize(size: number): number {
  const fontScale = PixelRatio.getFontScale();

  // Cap the maximum scale to prevent layout breaking
  const maxScale = 1.5;
  const effectiveScale = Math.min(fontScale, maxScale);

  return size * effectiveScale;
}

// Text component with responsive sizing
import { Text as RNText, TextProps } from 'react-native';

interface ResponsiveTextProps extends TextProps {
  size?: keyof typeof baseFontSizes;
}

export function Text({
  size = 'base',
  style,
  ...props
}: ResponsiveTextProps) {
  const scaledSize = fontSize[size];

  return (
    <RNText
      style={[{ fontSize: scaledSize }, style]}
      allowFontScaling
      maxFontSizeMultiplier={1.5}
      {...props}
    />
  );
}
```

### Pattern 5: Responsive Spacing

```typescript
// lib/spacing.ts
import { scale, moderateScale, verticalScale } from 'react-native-size-matters';

// Base spacing scale (multiple of 4)
const baseSpacing = {
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
  16: 64,
} as const;

// Horizontal spacing (width-based scaling)
export const spacing = Object.entries(baseSpacing).reduce(
  (acc, [key, value]) => ({
    ...acc,
    [key]: scale(value),
  }),
  {} as Record<keyof typeof baseSpacing, number>
);

// Vertical spacing (height-based scaling)
export const verticalSpacing = Object.entries(baseSpacing).reduce(
  (acc, [key, value]) => ({
    ...acc,
    [key]: verticalScale(value),
  }),
  {} as Record<keyof typeof baseSpacing, number>
);

// Moderate scaling (balanced)
export const moderateSpacing = Object.entries(baseSpacing).reduce(
  (acc, [key, value]) => ({
    ...acc,
    [key]: moderateScale(value, 0.5),
  }),
  {} as Record<keyof typeof baseSpacing, number>
);

// Usage
const styles = StyleSheet.create({
  container: {
    padding: spacing[4],
    marginVertical: verticalSpacing[2],
  },
  card: {
    padding: moderateSpacing[4],
    borderRadius: moderateScale(12),
  },
});
```

### Pattern 6: Responsive Images

```tsx
// components/ResponsiveImage.tsx
import { useWindowDimensions } from 'react-native';
import { Image } from 'expo-image';

interface ResponsiveImageProps {
  source: string;
  aspectRatio?: number;
  maxWidth?: number;
  className?: string;
}

export function ResponsiveImage({
  source,
  aspectRatio = 16 / 9,
  maxWidth,
  className,
}: ResponsiveImageProps) {
  const { width: screenWidth } = useWindowDimensions();

  const width = maxWidth ? Math.min(screenWidth, maxWidth) : screenWidth;
  const height = width / aspectRatio;

  return (
    <Image
      source={source}
      style={{ width, height }}
      className={className}
      contentFit="cover"
      transition={200}
    />
  );
}

// Responsive avatar sizes
export function Avatar({
  source,
  size = 'md',
}: {
  source: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
}) {
  const { isTablet } = useDevice();

  const sizes = {
    sm: isTablet ? 32 : 24,
    md: isTablet ? 48 : 40,
    lg: isTablet ? 64 : 56,
    xl: isTablet ? 96 : 80,
  };

  const dimension = sizes[size];

  return (
    <Image
      source={source}
      style={{
        width: dimension,
        height: dimension,
        borderRadius: dimension / 2,
      }}
      contentFit="cover"
    />
  );
}
```

### Pattern 7: Tablet-Specific Layouts

```tsx
// app/(tabs)/_layout.tsx - Adaptive tab bar
import { Tabs } from 'expo-router';
import { useDevice } from '@/hooks/useDevice';

export default function TabLayout() {
  const { isTablet } = useDevice();

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        // Side tab bar on tablets
        tabBarPosition: isTablet ? 'left' : 'bottom',
        tabBarStyle: isTablet
          ? {
              width: 80,
              borderRightWidth: 1,
              borderRightColor: '#E2E8F0',
            }
          : undefined,
        tabBarLabelStyle: {
          fontSize: isTablet ? 10 : 12,
        },
      }}
    >
      {/* ... */}
    </Tabs>
  );
}

// Tablet-optimized list
export function TabletOptimizedList({ data }: { data: Item[] }) {
  const { isTablet } = useDevice();

  if (isTablet) {
    // Grid layout for tablets
    return (
      <FlashList
        data={data}
        renderItem={({ item }) => <GridItem item={item} />}
        estimatedItemSize={200}
        numColumns={3}
      />
    );
  }

  // List layout for phones
  return (
    <FlashList
      data={data}
      renderItem={({ item }) => <ListItem item={item} />}
      estimatedItemSize={80}
    />
  );
}
```

### Pattern 8: Landscape Mode Support

```tsx
// hooks/useOrientation.ts
import { useState, useEffect } from 'react';
import { Dimensions } from 'react-native';
import * as ScreenOrientation from 'expo-screen-orientation';

type Orientation = 'portrait' | 'landscape';

export function useOrientation(): Orientation {
  const [orientation, setOrientation] = useState<Orientation>(() => {
    const { width, height } = Dimensions.get('window');
    return width > height ? 'landscape' : 'portrait';
  });

  useEffect(() => {
    const subscription = ScreenOrientation.addOrientationChangeListener(
      ({ orientationInfo }) => {
        if (
          orientationInfo.orientation === ScreenOrientation.Orientation.LANDSCAPE_LEFT ||
          orientationInfo.orientation === ScreenOrientation.Orientation.LANDSCAPE_RIGHT
        ) {
          setOrientation('landscape');
        } else {
          setOrientation('portrait');
        }
      }
    );

    return () => {
      ScreenOrientation.removeOrientationChangeListener(subscription);
    };
  }, []);

  return orientation;
}

// Lock orientation for specific screens
export async function lockToPortrait() {
  await ScreenOrientation.lockAsync(
    ScreenOrientation.OrientationLock.PORTRAIT_UP
  );
}

export async function lockToLandscape() {
  await ScreenOrientation.lockAsync(
    ScreenOrientation.OrientationLock.LANDSCAPE
  );
}

export async function unlockOrientation() {
  await ScreenOrientation.unlockAsync();
}

// Landscape-aware component
function VideoPlayer({ videoUrl }: { videoUrl: string }) {
  const orientation = useOrientation();
  const { width, height } = useWindowDimensions();

  useEffect(() => {
    // Allow landscape for video player
    unlockOrientation();

    return () => {
      // Lock back to portrait when leaving
      lockToPortrait();
    };
  }, []);

  return (
    <View
      style={{
        width: orientation === 'landscape' ? width : width,
        height: orientation === 'landscape' ? height : width * (9 / 16),
      }}
    >
      <Video source={{ uri: videoUrl }} style={{ flex: 1 }} />
    </View>
  );
}
```

## Best Practices

### Do's

- **Use Flexbox** for adaptive layouts
- **Test on multiple devices** - Phone, tablet, landscape
- **Support accessibility** - Large text, screen readers
- **Use useWindowDimensions** - Updates on rotation
- **Consider thumb zones** - Bottom nav on phones

### Don'ts

- **Don't hardcode dimensions** - Use relative/scaled values
- **Don't ignore tablets** - 20%+ of mobile users
- **Don't forget landscape** - Users will rotate
- **Don't break with large text** - Test 200% font scale
- **Don't assume screen size** - From SE to Pro Max

## Testing Checklist

- [ ] iPhone SE (375px) - Small phone
- [ ] iPhone 14 Pro (393px) - Regular phone
- [ ] iPhone 14 Pro Max (430px) - Large phone
- [ ] iPad (768px+) - Tablet portrait
- [ ] iPad landscape (1024px+) - Tablet landscape
- [ ] 200% font scale - Accessibility
- [ ] Landscape mode - Rotation

## Resources

- [React Native Dimensions](https://reactnative.dev/docs/dimensions)
- [react-native-size-matters](https://github.com/nirsky/react-native-size-matters)
- [Expo Screen Orientation](https://docs.expo.dev/versions/latest/sdk/screen-orientation/)
