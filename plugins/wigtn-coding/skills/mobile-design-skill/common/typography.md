# Mobile App Typography

## Overview

Typography in mobile apps must:
- Scale properly across device sizes
- Support accessibility settings (Dynamic Type)
- Maintain readability at all sizes
- Follow platform conventions

---

## Typography Scale

```typescript
// theme/typography.ts
import { Platform, PixelRatio, TextStyle } from 'react-native';
import { moderateScale } from 'react-native-size-matters';

// Respects user accessibility settings
const fontScale = (size: number) => {
  const scaled = moderateScale(size, 0.3);
  return PixelRatio.roundToNearestPixel(scaled);
};

export const typography = {
  // Display - Hero headlines
  displayLarge: {
    fontSize: fontScale(48),
    lineHeight: fontScale(56),
    fontWeight: '700' as const,
    letterSpacing: -0.5,
  },
  displayMedium: {
    fontSize: fontScale(40),
    lineHeight: fontScale(48),
    fontWeight: '700' as const,
    letterSpacing: -0.25,
  },
  displaySmall: {
    fontSize: fontScale(32),
    lineHeight: fontScale(40),
    fontWeight: '700' as const,
    letterSpacing: 0,
  },

  // Headlines - Section headers
  headlineLarge: {
    fontSize: fontScale(28),
    lineHeight: fontScale(36),
    fontWeight: '600' as const,
    letterSpacing: 0,
  },
  headlineMedium: {
    fontSize: fontScale(24),
    lineHeight: fontScale(32),
    fontWeight: '600' as const,
    letterSpacing: 0,
  },
  headlineSmall: {
    fontSize: fontScale(20),
    lineHeight: fontScale(28),
    fontWeight: '600' as const,
    letterSpacing: 0,
  },

  // Titles - Card titles, list headers
  titleLarge: {
    fontSize: fontScale(18),
    lineHeight: fontScale(26),
    fontWeight: '600' as const,
    letterSpacing: 0,
  },
  titleMedium: {
    fontSize: fontScale(16),
    lineHeight: fontScale(24),
    fontWeight: '600' as const,
    letterSpacing: 0.15,
  },
  titleSmall: {
    fontSize: fontScale(14),
    lineHeight: fontScale(20),
    fontWeight: '600' as const,
    letterSpacing: 0.1,
  },

  // Body - Main content
  bodyLarge: {
    fontSize: fontScale(16),
    lineHeight: fontScale(24),
    fontWeight: '400' as const,
    letterSpacing: 0.5,
  },
  bodyMedium: {
    fontSize: fontScale(14),
    lineHeight: fontScale(20),
    fontWeight: '400' as const,
    letterSpacing: 0.25,
  },
  bodySmall: {
    fontSize: fontScale(12),
    lineHeight: fontScale(16),
    fontWeight: '400' as const,
    letterSpacing: 0.4,
  },

  // Labels - Buttons, tabs, chips
  labelLarge: {
    fontSize: fontScale(14),
    lineHeight: fontScale(20),
    fontWeight: '500' as const,
    letterSpacing: 0.1,
  },
  labelMedium: {
    fontSize: fontScale(12),
    lineHeight: fontScale(16),
    fontWeight: '500' as const,
    letterSpacing: 0.5,
  },
  labelSmall: {
    fontSize: fontScale(10),
    lineHeight: fontScale(14),
    fontWeight: '500' as const,
    letterSpacing: 0.5,
  },

  // Caption - Metadata, timestamps
  caption: {
    fontSize: fontScale(11),
    lineHeight: fontScale(16),
    fontWeight: '400' as const,
    letterSpacing: 0.4,
  },
} as const;

export type TypographyVariant = keyof typeof typography;
```

---

## Platform Fonts

### iOS (SF Pro)

```typescript
// iOS uses SF Pro automatically with fontWeight
const iosFonts = {
  regular: { fontWeight: '400' },
  medium: { fontWeight: '500' },
  semibold: { fontWeight: '600' },
  bold: { fontWeight: '700' },
};
```

### Android (Roboto / Custom)

```typescript
// Android may need fontFamily for weights
const androidFonts = {
  regular: { fontFamily: 'Roboto', fontWeight: '400' },
  medium: { fontFamily: 'Roboto-Medium', fontWeight: '500' },
  semibold: { fontFamily: 'Roboto-Medium', fontWeight: '600' },
  bold: { fontFamily: 'Roboto-Bold', fontWeight: '700' },
};

// Cross-platform helper
const fontWeight = (weight: '400' | '500' | '600' | '700') => {
  if (Platform.OS === 'ios') {
    return { fontWeight: weight };
  }

  const families: Record<string, string> = {
    '400': 'Roboto',
    '500': 'Roboto-Medium',
    '600': 'Roboto-Medium',
    '700': 'Roboto-Bold',
  };

  return { fontFamily: families[weight], fontWeight: weight };
};
```

---

## Custom Fonts

### Loading Custom Fonts (Expo)

```typescript
// App.tsx
import { useFonts } from 'expo-font';
import * as SplashScreen from 'expo-splash-screen';

SplashScreen.preventAutoHideAsync();

export default function App() {
  const [fontsLoaded] = useFonts({
    'Inter-Regular': require('./assets/fonts/Inter-Regular.ttf'),
    'Inter-Medium': require('./assets/fonts/Inter-Medium.ttf'),
    'Inter-SemiBold': require('./assets/fonts/Inter-SemiBold.ttf'),
    'Inter-Bold': require('./assets/fonts/Inter-Bold.ttf'),
  });

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded]);

  if (!fontsLoaded) return null;

  return <RootNavigator />;
}
```

### Custom Font Typography

```typescript
export const customTypography = {
  headlineLarge: {
    fontFamily: 'Inter-Bold',
    fontSize: fontScale(28),
    lineHeight: fontScale(36),
  },
  bodyMedium: {
    fontFamily: 'Inter-Regular',
    fontSize: fontScale(14),
    lineHeight: fontScale(20),
  },
  labelLarge: {
    fontFamily: 'Inter-Medium',
    fontSize: fontScale(14),
    lineHeight: fontScale(20),
  },
};
```

---

## Text Component

```tsx
// components/Text.tsx
import { Text as RNText, TextProps as RNTextProps, StyleSheet } from 'react-native';
import { typography, TypographyVariant } from '@/theme/typography';
import { useTheme } from '@/providers/ThemeProvider';

interface TextProps extends RNTextProps {
  variant?: TypographyVariant;
  color?: string;
}

export function Text({
  variant = 'bodyMedium',
  color,
  style,
  ...props
}: TextProps) {
  const { colors } = useTheme();

  return (
    <RNText
      style={[
        typography[variant],
        { color: color || colors.foreground },
        style,
      ]}
      {...props}
    />
  );
}

// Usage
<Text variant="headlineLarge">Welcome</Text>
<Text variant="bodyMedium" color={colors.foregroundSecondary}>
  Subtitle text here
</Text>
```

---

## Accessibility (Dynamic Type)

### Supporting Dynamic Type

```typescript
import { PixelRatio } from 'react-native';

// This already respects system font scale
const accessibleFontSize = (baseSize: number) => {
  const fontScale = PixelRatio.getFontScale();
  const maxScale = 1.5; // Prevent text from getting too large
  const clampedScale = Math.min(fontScale, maxScale);
  return baseSize * clampedScale;
};
```

### allowFontScaling

```tsx
// Enable accessibility scaling (default: true)
<Text allowFontScaling={true}>
  This text scales with system settings
</Text>

// Disable for fixed-size elements (use sparingly)
<Text allowFontScaling={false}>
  Fixed size text
</Text>
```

### Testing Dynamic Type

```bash
# iOS Simulator
Settings > Accessibility > Display & Text Size > Larger Text

# Android Emulator
Settings > Accessibility > Font size
```

---

## Typography Hierarchy

### Recommended Hierarchy

| Level | Variant | Usage |
|-------|---------|-------|
| 1 | `displayLarge` | Hero headlines (rare) |
| 2 | `headlineLarge` | Screen titles |
| 3 | `headlineMedium` | Section headers |
| 4 | `titleLarge` | Card titles |
| 5 | `titleMedium` | List item titles |
| 6 | `bodyLarge` | Primary content |
| 7 | `bodyMedium` | Secondary content |
| 8 | `bodySmall` | Supporting text |
| 9 | `caption` | Metadata, timestamps |

### Example Screen

```tsx
function ProfileScreen() {
  return (
    <View>
      {/* Level 2: Screen title */}
      <Text variant="headlineLarge">Profile</Text>

      {/* Level 3: Section header */}
      <Text variant="headlineMedium">Account Settings</Text>

      {/* Level 5: List item title */}
      <Text variant="titleMedium">Email</Text>

      {/* Level 7: Supporting text */}
      <Text variant="bodyMedium" color={colors.foregroundSecondary}>
        user@example.com
      </Text>

      {/* Level 9: Metadata */}
      <Text variant="caption" color={colors.foregroundTertiary}>
        Last updated 2 hours ago
      </Text>
    </View>
  );
}
```

---

## Line Length

Optimal line length for readability:
- **45-75 characters** for body text
- Use `maxWidth` to constrain text containers

```tsx
const styles = StyleSheet.create({
  paragraph: {
    ...typography.bodyLarge,
    maxWidth: scale(600), // Prevents overly long lines on tablets
  },
});
```

---

## Best Practices

### Do's

- **Use the type scale** - Don't invent new sizes
- **Limit hierarchy levels** - 3-4 levels per screen max
- **Support Dynamic Type** - Accessibility is required
- **Test extremes** - Smallest and largest font settings
- **Use proper weights** - Regular, Medium, Semibold, Bold

### Don'ts

- **Don't use too many fonts** - 1-2 font families max
- **Don't disable font scaling** - Unless absolutely necessary
- **Don't use tiny text** - 10pt minimum for body
- **Don't center long text** - Left-align paragraphs
- **Don't rely on weight alone** - Combine with size/color

---

## Quick Reference

| Use Case | Variant | Min Size |
|----------|---------|----------|
| Screen Title | `headlineLarge` | 28pt |
| Section Header | `headlineMedium` | 24pt |
| Card Title | `titleLarge` | 18pt |
| Button Label | `labelLarge` | 14pt |
| Body Text | `bodyMedium` | 14pt |
| Caption | `caption` | 11pt |
| Tab Bar | `labelSmall` | 10pt |
