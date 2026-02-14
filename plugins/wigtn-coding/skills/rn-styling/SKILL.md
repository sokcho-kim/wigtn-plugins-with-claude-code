---
name: rn-styling
description: Master React Native styling with StyleSheet, react-native-size-matters for responsive scaling, and platform-specific patterns. Use when building adaptive UIs, handling different screen sizes, or implementing dark mode.
---

# React Native Styling & Responsive Design

Comprehensive guide to styling React Native apps with StyleSheet, responsive scaling, and platform-specific patterns.

## When to Use This Skill

- Building adaptive UIs for different screen sizes
- Setting up responsive scaling with size-matters
- Creating dark mode / theming systems
- Platform-specific styling (iOS vs Android)
- Animation and gesture styling

## Core Concepts

### 1. Styling Approach

| Approach | Pros | Cons | When to Use |
|----------|------|------|-------------|
| **StyleSheet.create** | Type-safe, performant, cached | Verbose | Default choice |
| **Inline styles** | Quick prototyping | No caching | Debugging only |
| **Styled Components** | Component-based | Bundle size | Design system |

### 2. Responsive Strategy

```
Fixed px → Bad (different on each device)
Percentage → Okay (relative to parent)
scale() / moderateScale() → Good (proportional to screen)
Flexbox → Best (adaptive layouts)
```

## Quick Start

### react-native-size-matters Setup

```bash
npm install react-native-size-matters
```

```typescript
// lib/scale.ts
import { Dimensions, PixelRatio } from 'react-native';
import {
  scale as s,
  verticalScale as vs,
  moderateScale as ms,
  moderateVerticalScale as mvs,
} from 'react-native-size-matters';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

// Base design: iPhone 14 Pro (393 x 852)
const BASE_WIDTH = 393;
const BASE_HEIGHT = 852;

// Scale functions
export const scale = (size: number) => s(size);
export const verticalScale = (size: number) => vs(size);
export const moderateScale = (size: number, factor = 0.5) => ms(size, factor);
export const moderateVerticalScale = (size: number, factor = 0.5) => mvs(size, factor);

// For font scaling (respects accessibility settings)
export const fontScale = (size: number) => {
  const scaledSize = moderateScale(size, 0.3);
  return PixelRatio.roundToNearestPixel(scaledSize);
};

// Percentage based
export const wp = (percentage: number) => (percentage * SCREEN_WIDTH) / 100;
export const hp = (percentage: number) => (percentage * SCREEN_HEIGHT) / 100;

// Device detection
export const isSmallDevice = SCREEN_WIDTH < 375;
export const isTablet = SCREEN_WIDTH >= 768;
```

## Patterns

### Pattern 1: Responsive StyleSheet

```typescript
// styles/common.ts
import { StyleSheet, Platform } from 'react-native';
import { scale, moderateScale, fontScale, verticalScale } from '@/lib/scale';

export const commonStyles = StyleSheet.create({
  // Containers
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  screenPadding: {
    paddingHorizontal: scale(16),
    paddingVertical: verticalScale(16),
  },
  section: {
    marginBottom: verticalScale(24),
  },

  // Cards
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: moderateScale(12),
    padding: scale(16),
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
      },
      android: {
        elevation: 4,
      },
    }),
  },

  // Typography
  heading1: {
    fontSize: fontScale(32),
    fontWeight: '700',
    lineHeight: fontScale(40),
    color: '#0F172A',
  },
  heading2: {
    fontSize: fontScale(24),
    fontWeight: '600',
    lineHeight: fontScale(32),
    color: '#0F172A',
  },
  heading3: {
    fontSize: fontScale(20),
    fontWeight: '600',
    lineHeight: fontScale(28),
    color: '#0F172A',
  },
  body: {
    fontSize: fontScale(16),
    fontWeight: '400',
    lineHeight: fontScale(24),
    color: '#334155',
  },
  bodySmall: {
    fontSize: fontScale(14),
    fontWeight: '400',
    lineHeight: fontScale(20),
    color: '#64748B',
  },
  caption: {
    fontSize: fontScale(12),
    fontWeight: '400',
    lineHeight: fontScale(16),
    color: '#94A3B8',
  },

  // Buttons
  button: {
    height: moderateScale(48),
    borderRadius: moderateScale(12),
    paddingHorizontal: scale(24),
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonPrimary: {
    backgroundColor: '#3B82F6',
  },
  buttonSecondary: {
    backgroundColor: '#F1F5F9',
  },
  buttonOutline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  buttonText: {
    fontSize: fontScale(16),
    fontWeight: '600',
  },

  // Inputs
  input: {
    height: moderateScale(48),
    borderRadius: moderateScale(12),
    paddingHorizontal: scale(16),
    fontSize: fontScale(16),
    backgroundColor: '#F1F5F9',
    color: '#0F172A',
  },

  // Layout
  row: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  spaceBetween: {
    justifyContent: 'space-between',
  },
  center: {
    justifyContent: 'center',
    alignItems: 'center',
  },
});
```

### Pattern 2: Component with Responsive Styles

```tsx
// components/Button.tsx
import { forwardRef, memo } from 'react';
import {
  Pressable,
  Text,
  ActivityIndicator,
  StyleSheet,
  ViewStyle,
  TextStyle,
  PressableProps,
} from 'react-native';
import { scale, moderateScale, fontScale } from '@/lib/scale';
import { colors } from '@/theme/colors';

type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'destructive';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends PressableProps {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  children: React.ReactNode;
}

export const Button = memo(forwardRef<any, ButtonProps>(
  function Button({
    variant = 'primary',
    size = 'md',
    loading = false,
    disabled,
    children,
    style,
    ...props
  }, ref) {
    const buttonStyle: ViewStyle[] = [
      styles.base,
      styles[`variant_${variant}`],
      styles[`size_${size}`],
      (disabled || loading) && styles.disabled,
      style as ViewStyle,
    ];

    const textStyle: TextStyle[] = [
      styles.text,
      styles[`text_${variant}`],
      styles[`textSize_${size}`],
    ];

    return (
      <Pressable
        ref={ref}
        disabled={disabled || loading}
        style={({ pressed }) => [
          ...buttonStyle,
          pressed && styles.pressed,
        ]}
        accessibilityRole="button"
        accessibilityState={{ disabled: disabled || loading }}
        {...props}
      >
        {loading ? (
          <ActivityIndicator
            color={variant === 'primary' || variant === 'destructive' ? '#FFFFFF' : '#0F172A'}
            size="small"
          />
        ) : typeof children === 'string' ? (
          <Text style={textStyle}>{children}</Text>
        ) : (
          children
        )}
      </Pressable>
    );
  }
));

const styles = StyleSheet.create({
  base: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: moderateScale(12),
  },

  // Variants
  variant_primary: {
    backgroundColor: colors.primary,
  },
  variant_secondary: {
    backgroundColor: colors.secondary,
  },
  variant_outline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: colors.border,
  },
  variant_ghost: {
    backgroundColor: 'transparent',
  },
  variant_destructive: {
    backgroundColor: colors.destructive,
  },

  // Sizes
  size_sm: {
    height: moderateScale(36),
    paddingHorizontal: scale(16),
  },
  size_md: {
    height: moderateScale(48),
    paddingHorizontal: scale(24),
  },
  size_lg: {
    height: moderateScale(56),
    paddingHorizontal: scale(32),
  },

  // Text
  text: {
    fontWeight: '600',
  },
  text_primary: {
    color: '#FFFFFF',
  },
  text_secondary: {
    color: '#0F172A',
  },
  text_outline: {
    color: '#0F172A',
  },
  text_ghost: {
    color: '#0F172A',
  },
  text_destructive: {
    color: '#FFFFFF',
  },
  textSize_sm: {
    fontSize: fontScale(14),
  },
  textSize_md: {
    fontSize: fontScale(16),
  },
  textSize_lg: {
    fontSize: fontScale(18),
  },

  // States
  disabled: {
    opacity: 0.5,
  },
  pressed: {
    opacity: 0.8,
  },
});
```

### Pattern 3: Theme System with Scale

```typescript
// theme/colors.ts
export const colors = {
  // Light theme
  light: {
    background: '#FFFFFF',
    foreground: '#0F172A',
    card: '#FFFFFF',
    cardForeground: '#0F172A',
    primary: '#3B82F6',
    primaryForeground: '#FFFFFF',
    secondary: '#F1F5F9',
    secondaryForeground: '#0F172A',
    muted: '#F1F5F9',
    mutedForeground: '#64748B',
    accent: '#F1F5F9',
    accentForeground: '#0F172A',
    destructive: '#EF4444',
    destructiveForeground: '#FFFFFF',
    border: '#E2E8F0',
    input: '#E2E8F0',
    ring: '#3B82F6',
  },
  // Dark theme
  dark: {
    background: '#0F172A',
    foreground: '#F8FAFC',
    card: '#1E293B',
    cardForeground: '#F8FAFC',
    primary: '#3B82F6',
    primaryForeground: '#FFFFFF',
    secondary: '#1E293B',
    secondaryForeground: '#F8FAFC',
    muted: '#1E293B',
    mutedForeground: '#94A3B8',
    accent: '#1E293B',
    accentForeground: '#F8FAFC',
    destructive: '#EF4444',
    destructiveForeground: '#FFFFFF',
    border: '#1E293B',
    input: '#1E293B',
    ring: '#3B82F6',
  },
} as const;

export type ColorScheme = keyof typeof colors;

// theme/spacing.ts
import { scale, moderateScale, verticalScale } from '@/lib/scale';

export const spacing = {
  xs: scale(4),
  sm: scale(8),
  md: scale(16),
  lg: scale(24),
  xl: scale(32),
  '2xl': scale(48),
  '3xl': scale(64),
} as const;

// theme/typography.ts
import { fontScale } from '@/lib/scale';

export const typography = {
  h1: {
    fontSize: fontScale(32),
    lineHeight: fontScale(40),
    fontWeight: '700' as const,
  },
  h2: {
    fontSize: fontScale(24),
    lineHeight: fontScale(32),
    fontWeight: '600' as const,
  },
  h3: {
    fontSize: fontScale(20),
    lineHeight: fontScale(28),
    fontWeight: '600' as const,
  },
  body: {
    fontSize: fontScale(16),
    lineHeight: fontScale(24),
    fontWeight: '400' as const,
  },
  bodySmall: {
    fontSize: fontScale(14),
    lineHeight: fontScale(20),
    fontWeight: '400' as const,
  },
  caption: {
    fontSize: fontScale(12),
    lineHeight: fontScale(16),
    fontWeight: '400' as const,
  },
} as const;

// theme/index.ts
import { colors, ColorScheme } from './colors';
import { spacing } from './spacing';
import { typography } from './typography';

export function createTheme(scheme: ColorScheme) {
  return {
    colors: colors[scheme],
    spacing,
    typography,
  };
}

export type Theme = ReturnType<typeof createTheme>;
```

### Pattern 4: Theme Provider

```tsx
// providers/ThemeProvider.tsx
import React, { createContext, useContext, useEffect, useState } from 'react';
import { useColorScheme, StatusBar } from 'react-native';
import { MMKV } from 'react-native-mmkv';
import { createTheme, Theme } from '@/theme';
import { colors, ColorScheme } from '@/theme/colors';

const storage = new MMKV();

type ThemeMode = 'light' | 'dark' | 'system';

interface ThemeContextType {
  theme: Theme;
  mode: ThemeMode;
  isDark: boolean;
  setMode: (mode: ThemeMode) => void;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const systemColorScheme = useColorScheme();
  const [mode, setModeState] = useState<ThemeMode>(() => {
    const stored = storage.getString('theme_mode');
    return (stored as ThemeMode) || 'system';
  });

  const resolvedScheme: ColorScheme =
    mode === 'system' ? (systemColorScheme || 'light') : mode;

  const theme = createTheme(resolvedScheme);
  const isDark = resolvedScheme === 'dark';

  const setMode = (newMode: ThemeMode) => {
    storage.set('theme_mode', newMode);
    setModeState(newMode);
  };

  const toggleTheme = () => {
    setMode(isDark ? 'light' : 'dark');
  };

  return (
    <ThemeContext.Provider value={{ theme, mode, isDark, setMode, toggleTheme }}>
      <StatusBar
        barStyle={isDark ? 'light-content' : 'dark-content'}
        backgroundColor={theme.colors.background}
      />
      {children}
    </ThemeContext.Provider>
  );
}

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
};

// Usage in component
function Card({ children }: { children: React.ReactNode }) {
  const { theme } = useTheme();

  return (
    <View style={[styles.card, { backgroundColor: theme.colors.card }]}>
      {children}
    </View>
  );
}
```

### Pattern 5: Platform-Specific Styles

```tsx
import { Platform, StyleSheet } from 'react-native';
import { scale, moderateScale } from '@/lib/scale';

const styles = StyleSheet.create({
  // Shadow - different on each platform
  shadow: Platform.select({
    ios: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 8,
    },
    android: {
      elevation: 4,
    },
    default: {},
  }),

  // Font weight - Android needs fontFamily
  boldText: Platform.select({
    ios: {
      fontWeight: '700',
    },
    android: {
      fontFamily: 'Roboto-Bold',
      fontWeight: '700',
    },
    default: {
      fontWeight: '700',
    },
  }),

  // StatusBar padding
  safeTop: {
    paddingTop: Platform.OS === 'android' ? scale(24) : 0,
  },
});

// Platform-specific component
import { SafeAreaView, View, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export function ScreenContainer({ children }: { children: React.ReactNode }) {
  const insets = useSafeAreaInsets();
  const { theme } = useTheme();

  return (
    <View
      style={[
        styles.container,
        {
          paddingTop: insets.top,
          paddingBottom: insets.bottom,
          backgroundColor: theme.colors.background,
        },
      ]}
    >
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
```

### Pattern 6: Animated Styles

```tsx
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
  Extrapolation,
} from 'react-native-reanimated';
import { Pressable, StyleSheet, View, Text } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import { moderateScale, scale } from '@/lib/scale';

// Pressable with scale animation
export function AnimatedButton({
  onPress,
  children,
  style,
}: {
  onPress: () => void;
  children: React.ReactNode;
  style?: any;
}) {
  const scaleValue = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scaleValue.value }],
  }));

  const gesture = Gesture.Tap()
    .onBegin(() => {
      scaleValue.value = withSpring(0.95);
    })
    .onFinalize(() => {
      scaleValue.value = withSpring(1);
    });

  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[animatedStyle, style]}>
        <Pressable onPress={onPress} style={styles.animatedButton}>
          {children}
        </Pressable>
      </Animated.View>
    </GestureDetector>
  );
}

// Card with parallax scroll effect
import { useAnimatedScrollHandler } from 'react-native-reanimated';

export function ParallaxHeader({
  imageSource,
  title,
}: {
  imageSource: any;
  title: string;
}) {
  const scrollY = useSharedValue(0);

  const imageStyle = useAnimatedStyle(() => {
    const scaleValue = interpolate(
      scrollY.value,
      [-100, 0],
      [1.5, 1],
      Extrapolation.CLAMP
    );
    const translateY = interpolate(
      scrollY.value,
      [0, 200],
      [0, -100],
      Extrapolation.CLAMP
    );

    return {
      transform: [{ scale: scaleValue }, { translateY }],
    };
  });

  const scrollHandler = useAnimatedScrollHandler({
    onScroll: (event) => {
      scrollY.value = event.contentOffset.y;
    },
  });

  return (
    <Animated.ScrollView onScroll={scrollHandler} scrollEventThrottle={16}>
      <Animated.Image
        source={imageSource}
        style={[styles.headerImage, imageStyle]}
      />
      <View style={styles.content}>
        <Text style={styles.title}>{title}</Text>
      </View>
    </Animated.ScrollView>
  );
}

const styles = StyleSheet.create({
  animatedButton: {
    backgroundColor: '#3B82F6',
    paddingHorizontal: scale(24),
    paddingVertical: scale(16),
    borderRadius: moderateScale(12),
    alignItems: 'center',
  },
  headerImage: {
    width: '100%',
    height: 300,
  },
  content: {
    padding: scale(16),
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
  },
});
```

### Pattern 7: Reusable Style Creator

```typescript
// lib/createStyles.ts
import { StyleSheet, ViewStyle, TextStyle, ImageStyle } from 'react-native';
import { Theme } from '@/theme';

type NamedStyles<T> = { [P in keyof T]: ViewStyle | TextStyle | ImageStyle };

export function createStyles<T extends NamedStyles<T>>(
  stylesFactory: (theme: Theme) => T
) {
  return (theme: Theme) => StyleSheet.create(stylesFactory(theme));
}

// Usage
// components/Card/Card.styles.ts
import { createStyles } from '@/lib/createStyles';
import { scale, moderateScale } from '@/lib/scale';

export const useCardStyles = createStyles((theme) => ({
  container: {
    backgroundColor: theme.colors.card,
    borderRadius: moderateScale(12),
    padding: scale(16),
    borderWidth: 1,
    borderColor: theme.colors.border,
  },
  title: {
    ...theme.typography.h3,
    color: theme.colors.cardForeground,
    marginBottom: scale(8),
  },
  description: {
    ...theme.typography.body,
    color: theme.colors.mutedForeground,
  },
}));

// components/Card/Card.tsx
import { View, Text } from 'react-native';
import { useTheme } from '@/providers/ThemeProvider';
import { useCardStyles } from './Card.styles';

export function Card({ title, description }: { title: string; description: string }) {
  const { theme } = useTheme();
  const styles = useCardStyles(theme);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.description}>{description}</Text>
    </View>
  );
}
```

## Best Practices

### Do's

- **Use scale for dimensions** - Consistent sizing across devices
- **Use fontScale for text** - Respects user accessibility settings
- **Prefer Flexbox** - Adaptive layouts without hardcoding
- **Use SafeAreaView** - Handle notches and system UI
- **Test on multiple devices** - iPhone SE, Pro Max, tablets

### Don'ts

- **Don't hardcode pixels** - Won't scale properly
- **Don't ignore Android differences** - Elevation vs shadow
- **Don't skip accessibility** - Large text settings matter
- **Don't use inline styles in loops** - Performance impact
- **Don't forget dark mode** - Test both themes

## Scaling Reference

```typescript
// When to use each scale function:

scale(16)           // Horizontal dimensions (margins, paddings, widths)
verticalScale(16)   // Vertical dimensions (heights, vertical margins)
moderateScale(16)   // Balanced scaling (border radius, icons)
fontScale(16)       // Font sizes (respects accessibility)

// Examples
const styles = StyleSheet.create({
  container: {
    paddingHorizontal: scale(16),      // Horizontal padding
    paddingVertical: verticalScale(12), // Vertical padding
    borderRadius: moderateScale(8),     // Border radius
  },
  title: {
    fontSize: fontScale(24),            // Font size
    lineHeight: fontScale(32),          // Line height
  },
  icon: {
    width: moderateScale(24),           // Icon size
    height: moderateScale(24),
  },
});
```

## Resources

- [react-native-size-matters](https://github.com/nirsky/react-native-size-matters)
- [React Native StyleSheet](https://reactnative.dev/docs/stylesheet)
- [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Material Design](https://m3.material.io/)
