---
argument-hint: "<ComponentName>"
---

# Component Scaffolding

You are a React/React Native component architecture expert specializing in scaffolding production-ready, accessible, and performant components. Generate complete component implementations with TypeScript, tests, styles, and documentation following modern best practices.

## Context

The user needs automated component scaffolding that creates consistent, type-safe components with proper structure, hooks, styling, accessibility, and test coverage. Detect the project platform and generate the appropriate component type.

## Requirements

$ARGUMENTS

## Platform Detection

Before generating, detect the project platform from `package.json`:

```typescript
function detectPlatform(): "web" | "mobile" {
  if (hasDependency("react-native") || hasDependency("expo")) return "mobile";
  if (hasDependency("next") || hasDependency("react-dom")) return "web";
  return "web"; // default
}
```

## Instructions

### 1. Analyze Component Requirements

```typescript
interface ComponentSpec {
  name: string;
  type: "functional" | "page" | "layout" | "form" | "data-display" | "screen" | "list";
  props: PropDefinition[];
  state?: StateDefinition[];
  hooks?: string[];
  platform: "web" | "mobile";
  styling: "tailwind" | "css-modules" | "styled-components" | "stylesheet" | "nativewind";
  animations?: boolean;
}
```

### 2. Generate Component Structure

**Web:**
```
components/
└── [ComponentName]/
    ├── [ComponentName].tsx          # Main component
    ├── [ComponentName].module.css   # Styles (if CSS modules)
    ├── [ComponentName].test.tsx     # Unit tests
    ├── [ComponentName].stories.tsx  # Storybook stories (optional)
    └── index.ts                     # Barrel export
```

**Mobile:**
```
components/
└── [ComponentName]/
    ├── [ComponentName].tsx          # Main component
    ├── [ComponentName].styles.ts    # StyleSheet styles
    ├── [ComponentName].types.ts     # TypeScript types
    ├── [ComponentName].test.tsx     # Unit tests
    ├── [ComponentName].hooks.ts     # Custom hooks (if needed)
    └── index.ts                     # Barrel export
```

---

## Web Component Templates

### React Component

```typescript
"use client";

import { forwardRef } from "react";
import { cn } from "@/lib/utils";

export interface [ComponentName]Props extends React.HTMLAttributes<HTMLDivElement> {
  /** Visual variant */
  variant?: "default" | "outlined" | "ghost";
  /** Size preset */
  size?: "sm" | "default" | "lg";
  /** Whether the component is disabled */
  disabled?: boolean;
}

export const [ComponentName] = forwardRef<HTMLDivElement, [ComponentName]Props>(
  ({ className, variant = "default", size = "default", disabled, children, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          "rounded-lg",
          variant === "default" && "bg-white shadow",
          variant === "outlined" && "border border-gray-200",
          variant === "ghost" && "bg-transparent",
          size === "sm" && "p-3",
          size === "default" && "p-4",
          size === "lg" && "p-6",
          disabled && "opacity-50 pointer-events-none",
          className
        )}
        {...props}
      >
        {children}
      </div>
    );
  }
);

[ComponentName].displayName = "[ComponentName]";
```

### Web Test

```typescript
import { render, screen } from "@testing-library/react";
import { [ComponentName] } from "./[ComponentName]";

describe("[ComponentName]", () => {
  it("renders children correctly", () => {
    render(<[ComponentName]>Content</[ComponentName]>);
    expect(screen.getByText("Content")).toBeInTheDocument();
  });

  it("applies variant styles", () => {
    const { container } = render(<[ComponentName] variant="outlined">Content</[ComponentName]>);
    expect(container.firstChild).toHaveClass("border");
  });

  it("handles disabled state", () => {
    const { container } = render(<[ComponentName] disabled>Content</[ComponentName]>);
    expect(container.firstChild).toHaveClass("opacity-50");
  });
});
```

---

## Mobile Component Templates

### React Native Component

```tsx
import { forwardRef, memo } from 'react';
import { View, Text, Pressable, ViewProps } from 'react-native';
import Animated, { FadeIn, FadeOut } from 'react-native-reanimated';
import { useTheme } from '@/providers/ThemeProvider';
import { styles, createDynamicStyles } from './[ComponentName].styles';
import type { [ComponentName]Props } from './[ComponentName].types';

export const [ComponentName] = memo(forwardRef<View, [ComponentName]Props>(
  function [ComponentName]({
    children,
    variant = 'default',
    size = 'default',
    disabled = false,
    style,
    ...props
  }, ref) {
    const { theme } = useTheme();
    const dynamicStyles = createDynamicStyles(theme);

    return (
      <Animated.View
        ref={ref}
        entering={FadeIn}
        exiting={FadeOut}
        style={[
          styles.container,
          dynamicStyles.container,
          styles[`variant_${variant}`],
          styles[`size_${size}`],
          disabled && styles.disabled,
          style,
        ]}
        accessible
        accessibilityRole="none"
        {...props}
      >
        {children}
      </Animated.View>
    );
  }
));

[ComponentName].displayName = '[ComponentName]';
```

### Mobile Styles

```typescript
// [ComponentName].styles.ts
import { StyleSheet, Platform } from 'react-native';
import { scale, moderateScale, fontScale } from '@/lib/scale';
import type { Theme } from '@/theme';

export const styles = StyleSheet.create({
  container: {
    borderRadius: moderateScale(12),
    overflow: 'hidden',
  },
  variant_default: {},
  variant_outlined: {
    backgroundColor: 'transparent',
    borderWidth: 1,
  },
  variant_ghost: {
    backgroundColor: 'transparent',
  },
  size_sm: { padding: scale(12) },
  size_default: { padding: scale(16) },
  size_lg: { padding: scale(24) },
  disabled: { opacity: 0.5 },
  pressed: { opacity: 0.8 },
  shadow: Platform.select({
    ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1, shadowRadius: 8 },
    android: { elevation: 4 },
  }),
});

export const createDynamicStyles = (theme: Theme) =>
  StyleSheet.create({
    container: { backgroundColor: theme.colors.card },
  });
```

### Mobile Types

```typescript
// [ComponentName].types.ts
import type { ViewProps, StyleProp, ViewStyle } from 'react-native';

export interface [ComponentName]Props extends ViewProps {
  children?: React.ReactNode;
  variant?: 'default' | 'outlined' | 'ghost';
  size?: 'sm' | 'default' | 'lg';
  disabled?: boolean;
  style?: StyleProp<ViewStyle>;
  onPress?: () => void;
}
```

### Mobile Test

```tsx
import { render, screen, fireEvent } from '@testing-library/react-native';
import { ThemeProvider } from '@/providers/ThemeProvider';
import { [ComponentName] } from './[ComponentName]';
import { Text } from 'react-native';

const renderWithTheme = (component: React.ReactElement) => {
  return render(<ThemeProvider>{component}</ThemeProvider>);
};

describe('[ComponentName]', () => {
  it('renders correctly', () => {
    renderWithTheme(
      <[ComponentName]><Text>Content</Text></[ComponentName]>
    );
    expect(screen.getByText('Content')).toBeOnTheScreen();
  });

  it('handles disabled state', () => {
    renderWithTheme(
      <[ComponentName] disabled testID="component"><Text>Content</Text></[ComponentName]>
    );
    const component = screen.getByTestId('component');
    expect(component).toHaveStyle({ opacity: 0.5 });
  });

  it('is accessible', () => {
    renderWithTheme(
      <[ComponentName] accessibilityLabel="Test component"><Text>Content</Text></[ComponentName]>
    );
    expect(screen.getByLabelText('Test component')).toBeOnTheScreen();
  });
});
```

---

## Output Format

1. **Platform Detection**: Web or Mobile (auto-detected)
2. **Component File**: Fully implemented component
3. **Type Definitions**: TypeScript interfaces and types
4. **Styles**: Tailwind/CSS modules (Web) or StyleSheet (Mobile)
5. **Tests**: Complete test suite
6. **Stories**: Storybook stories (Web, optional)
7. **Index File**: Barrel exports for clean imports

## Accessibility Requirements

**Web:** ARIA labels, roles, color contrast, keyboard navigation, focus management
**Mobile:** `accessible={true}`, `accessibilityRole`, `accessibilityLabel`, `accessibilityHint`, VoiceOver/TalkBack support

## Performance Considerations

**Web:** React.memo for pure components, useMemo/useCallback, lazy loading, Suspense
**Mobile:** memo() for list items, useCallback for event handlers, Pressable over TouchableOpacity, expo-image, StyleSheet.create
