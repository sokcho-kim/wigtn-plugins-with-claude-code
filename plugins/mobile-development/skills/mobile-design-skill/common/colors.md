# Mobile App Color Systems

## Overview

Color in mobile apps must:
- Support light and dark modes
- Meet accessibility contrast requirements
- Adapt to platform conventions (iOS/Android)
- Scale consistently across the app

---

## Color Architecture

### Semantic Color Tokens

```typescript
// theme/colors.ts
export interface ColorTokens {
  // Backgrounds
  background: string;
  backgroundSecondary: string;
  backgroundTertiary: string;

  // Foregrounds
  foreground: string;
  foregroundSecondary: string;
  foregroundTertiary: string;

  // Primary
  primary: string;
  primaryForeground: string;

  // Secondary
  secondary: string;
  secondaryForeground: string;

  // Accent
  accent: string;
  accentForeground: string;

  // Destructive
  destructive: string;
  destructiveForeground: string;

  // Success
  success: string;
  successForeground: string;

  // Warning
  warning: string;
  warningForeground: string;

  // Muted
  muted: string;
  mutedForeground: string;

  // Card
  card: string;
  cardForeground: string;

  // Border
  border: string;
  borderSecondary: string;

  // Input
  input: string;
  inputForeground: string;

  // Overlay
  overlay: string;
}
```

### Light Theme Example

```typescript
export const lightColors: ColorTokens = {
  // Backgrounds
  background: '#FFFFFF',
  backgroundSecondary: '#F5F5F7',
  backgroundTertiary: '#EFEFF4',

  // Foregrounds
  foreground: '#1C1C1E',
  foregroundSecondary: '#3C3C43',
  foregroundTertiary: '#8E8E93',

  // Primary (Brand)
  primary: '#007AFF',
  primaryForeground: '#FFFFFF',

  // Secondary
  secondary: '#5856D6',
  secondaryForeground: '#FFFFFF',

  // Accent
  accent: '#FF9500',
  accentForeground: '#FFFFFF',

  // Destructive
  destructive: '#FF3B30',
  destructiveForeground: '#FFFFFF',

  // Success
  success: '#34C759',
  successForeground: '#FFFFFF',

  // Warning
  warning: '#FF9500',
  warningForeground: '#FFFFFF',

  // Muted
  muted: '#F2F2F7',
  mutedForeground: '#8E8E93',

  // Card
  card: '#FFFFFF',
  cardForeground: '#1C1C1E',

  // Border
  border: '#C6C6C8',
  borderSecondary: '#E5E5EA',

  // Input
  input: '#F2F2F7',
  inputForeground: '#1C1C1E',

  // Overlay
  overlay: 'rgba(0, 0, 0, 0.4)',
};
```

### Dark Theme Example

```typescript
export const darkColors: ColorTokens = {
  // Backgrounds
  background: '#000000',
  backgroundSecondary: '#1C1C1E',
  backgroundTertiary: '#2C2C2E',

  // Foregrounds
  foreground: '#FFFFFF',
  foregroundSecondary: '#EBEBF5',
  foregroundTertiary: '#8E8E93',

  // Primary (Brand)
  primary: '#0A84FF',
  primaryForeground: '#FFFFFF',

  // Secondary
  secondary: '#5E5CE6',
  secondaryForeground: '#FFFFFF',

  // Accent
  accent: '#FF9F0A',
  accentForeground: '#000000',

  // Destructive
  destructive: '#FF453A',
  destructiveForeground: '#FFFFFF',

  // Success
  success: '#30D158',
  successForeground: '#000000',

  // Warning
  warning: '#FF9F0A',
  warningForeground: '#000000',

  // Muted
  muted: '#1C1C1E',
  mutedForeground: '#8E8E93',

  // Card
  card: '#1C1C1E',
  cardForeground: '#FFFFFF',

  // Border
  border: '#38383A',
  borderSecondary: '#48484A',

  // Input
  input: '#1C1C1E',
  inputForeground: '#FFFFFF',

  // Overlay
  overlay: 'rgba(0, 0, 0, 0.6)',
};
```

---

## Theme Provider

```tsx
// providers/ThemeProvider.tsx
import React, { createContext, useContext, useState, useEffect } from 'react';
import { useColorScheme, StatusBar } from 'react-native';
import { MMKV } from 'react-native-mmkv';
import { lightColors, darkColors, ColorTokens } from '@/theme/colors';

const storage = new MMKV();

type ThemeMode = 'light' | 'dark' | 'system';

interface ThemeContextType {
  colors: ColorTokens;
  mode: ThemeMode;
  isDark: boolean;
  setMode: (mode: ThemeMode) => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const systemScheme = useColorScheme();
  const [mode, setModeState] = useState<ThemeMode>(() => {
    return (storage.getString('theme_mode') as ThemeMode) || 'system';
  });

  const resolvedScheme = mode === 'system' ? (systemScheme || 'light') : mode;
  const isDark = resolvedScheme === 'dark';
  const colors = isDark ? darkColors : lightColors;

  const setMode = (newMode: ThemeMode) => {
    storage.set('theme_mode', newMode);
    setModeState(newMode);
  };

  return (
    <ThemeContext.Provider value={{ colors, mode, isDark, setMode }}>
      <StatusBar
        barStyle={isDark ? 'light-content' : 'dark-content'}
        backgroundColor={colors.background}
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
```

---

## Accessibility Contrast

### WCAG Requirements

| Level | Normal Text | Large Text |
|-------|-------------|------------|
| AA | 4.5:1 | 3:1 |
| AAA | 7:1 | 4.5:1 |

Large text = 18pt+ regular or 14pt+ bold

### Contrast Checker Utility

```typescript
// lib/color-utils.ts
function getLuminance(hex: string): number {
  const rgb = hexToRgb(hex);
  const [r, g, b] = rgb.map(c => {
    c /= 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

export function getContrastRatio(fg: string, bg: string): number {
  const l1 = getLuminance(fg);
  const l2 = getLuminance(bg);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

export function meetsContrastRequirement(
  fg: string,
  bg: string,
  level: 'AA' | 'AAA' = 'AA',
  isLargeText: boolean = false
): boolean {
  const ratio = getContrastRatio(fg, bg);
  const requirement = level === 'AAA'
    ? (isLargeText ? 4.5 : 7)
    : (isLargeText ? 3 : 4.5);
  return ratio >= requirement;
}
```

---

## Platform-Specific Colors

### iOS System Colors

```typescript
export const iosSystemColors = {
  // Adaptive colors that work in light/dark
  systemRed: '#FF3B30',
  systemOrange: '#FF9500',
  systemYellow: '#FFCC00',
  systemGreen: '#34C759',
  systemMint: '#00C7BE',
  systemTeal: '#30B0C7',
  systemCyan: '#32ADE6',
  systemBlue: '#007AFF',
  systemIndigo: '#5856D6',
  systemPurple: '#AF52DE',
  systemPink: '#FF2D55',
  systemBrown: '#A2845E',

  // Grayscale
  systemGray: '#8E8E93',
  systemGray2: '#AEAEB2',
  systemGray3: '#C7C7CC',
  systemGray4: '#D1D1D6',
  systemGray5: '#E5E5EA',
  systemGray6: '#F2F2F7',
};
```

### Android Material Colors

```typescript
export const materialSystemColors = {
  // Primary palette
  primary: '#6750A4',
  onPrimary: '#FFFFFF',
  primaryContainer: '#EADDFF',
  onPrimaryContainer: '#21005D',

  // Error palette
  error: '#B3261E',
  onError: '#FFFFFF',
  errorContainer: '#F9DEDC',
  onErrorContainer: '#410E0B',

  // Neutral palette
  surface: '#FFFBFE',
  onSurface: '#1C1B1F',
  surfaceVariant: '#E7E0EC',
  onSurfaceVariant: '#49454F',
  outline: '#79747E',
};
```

---

## Color Usage Guidelines

### Do's

- **Use semantic tokens** - `colors.primary` not `#007AFF`
- **Test both modes** - Verify colors in light AND dark
- **Check contrast** - Especially for text on backgrounds
- **Use opacity carefully** - Semi-transparent colors may fail contrast
- **Consider color blindness** - Don't rely solely on color for meaning

### Don'ts

- **Hardcode colors** - Always use theme tokens
- **Ignore dark mode** - Many users prefer it
- **Use pure black/white** - Slightly off-white/gray is easier on eyes
- **Over-saturate** - Bright colors are fatiguing
- **Mix color systems** - Stick to one palette

---

## Color Palette Generation

```typescript
// Generate tints and shades
function generatePalette(baseColor: string) {
  return {
    50: lighten(baseColor, 0.95),
    100: lighten(baseColor, 0.9),
    200: lighten(baseColor, 0.7),
    300: lighten(baseColor, 0.5),
    400: lighten(baseColor, 0.3),
    500: baseColor,
    600: darken(baseColor, 0.1),
    700: darken(baseColor, 0.3),
    800: darken(baseColor, 0.5),
    900: darken(baseColor, 0.7),
    950: darken(baseColor, 0.9),
  };
}

// Usage
const primaryPalette = generatePalette('#007AFF');
// primaryPalette[500] = '#007AFF'
// primaryPalette[100] = lighter tint
// primaryPalette[900] = darker shade
```

---

## Quick Reference

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `background` | #FFFFFF | #000000 | Main screen background |
| `foreground` | #1C1C1E | #FFFFFF | Primary text |
| `primary` | #007AFF | #0A84FF | Buttons, links, accents |
| `destructive` | #FF3B30 | #FF453A | Delete, errors |
| `success` | #34C759 | #30D158 | Success states |
| `muted` | #F2F2F7 | #1C1C1E | Disabled, secondary bg |
| `border` | #C6C6C8 | #38383A | Dividers, outlines |
