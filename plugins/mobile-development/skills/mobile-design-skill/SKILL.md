---
name: mobile-design-implementation
description: Mobile design patterns and implementation rules for React Native apps. Works with mobile-design-discovery agent for context gathering. Contains iOS HIG, Material Design 3, and cross-platform patterns with anti-patterns to avoid.
---

# Mobile Design Implementation Guide

## Overview

This skill provides **design patterns and implementation rules** for React Native mobile apps.

**For design discovery and direction selection**, use the `app-design-discovery` agent which:
- Gathers context through step-by-step questions
- Uses VS (Verbalized Sampling) technique to recommend directions with suitability percentages
- Considers platform guidelines (iOS HIG, Material Design)

This skill is automatically loaded after the agent completes discovery.

---

## How to Use

### With Discovery Agent (Recommended)
1. User requests app design
2. `app-design-discovery` agent conducts context gathering
3. Agent presents VS-based direction recommendations
4. After selection, agent loads this skill for implementation

### Direct Usage (Quick Mode)
If user already knows their direction, skip discovery:
```
"Build me a social app with iOS native style, tab navigation, and playful animations"
```
In this case, directly read the relevant pattern guide and implement.

---

## Pattern Selection & Guidelines

Based on user responses, select the appropriate patterns and read the corresponding guides.

**⚠️ IMPORTANT: You MUST read both the pattern guide AND relevant common modules before implementing.**

### Pattern Guides
Use the `Read` tool to read the corresponding pattern file:
- iOS Native → `patterns/ios-hig.md`
- Material Design → `patterns/material-design.md`
- Tab Bar Navigation → `patterns/tab-bar.md`
- Bottom Sheet → `patterns/bottom-sheet.md`
- Card Patterns → `patterns/card-patterns.md`
- List Patterns → `patterns/list-patterns.md`
- Form Patterns → `patterns/form-patterns.md`

### Common Modules (Always Read Based on User Choices)
- Colors → `common/colors.md` (color systems, dark mode)
- Typography → `common/typography.md` (font scaling, hierarchy)
- Haptics → `common/haptics.md` (tactile feedback patterns)

Do NOT proceed to implementation without reading:
1. The relevant platform/pattern guide
2. Relevant common modules based on user's choices

---

## Universal Mobile Principles

### ❌ Never Do This (Mobile Anti-Patterns)

- **Tiny touch targets** - Below 44pt (iOS) or 48dp (Android)
- **Web-style hover states** - Mobile has no hover
- **Ignoring safe areas** - Content behind notch/home indicator
- **No loading states** - Users see blank screens
- **Missing haptic feedback** - Actions feel unresponsive
- **Inconsistent navigation** - Confusing back behavior
- **Blocking main thread** - UI freezes during operations
- **Ignoring accessibility** - No support for VoiceOver/TalkBack
- **Fixed pixel sizes** - Doesn't scale across devices
- **Horizontal scroll in lists** - Conflicts with back gesture

### ✅ Always Do This

- **44pt minimum touch targets** (iOS) / 48dp (Android)
- **Use scale functions** for responsive sizing
- **Handle safe areas** with SafeAreaView or insets
- **Show loading skeletons** not spinners
- **Add haptic feedback** for significant actions
- **Consistent navigation** following platform patterns
- **Offload heavy work** to background threads
- **Support accessibility** labels, roles, hints
- **Test on multiple devices** - SE, Pro Max, tablets
- **Handle interruptions** - calls, notifications

---

## Platform Quick Reference

### iOS (Human Interface Guidelines)

| Element | Guideline |
|---------|-----------|
| Touch Target | Minimum 44×44 pt |
| Tab Bar | 5 items max, center for primary |
| Navigation | Large title → small on scroll |
| Modals | Sheet presentation (iOS 15+) |
| Icons | SF Symbols preferred |
| Typography | SF Pro, Dynamic Type support |
| Colors | System colors for adaptability |
| Haptics | UIImpactFeedback, UINotificationFeedback |

### Android (Material Design 3)

| Element | Guideline |
|---------|-----------|
| Touch Target | Minimum 48×48 dp |
| FAB | Primary action, bottom-right |
| Navigation | Bottom nav or nav rail |
| Modals | Bottom sheet preferred |
| Icons | Material Symbols |
| Typography | Roboto, scalable |
| Colors | Dynamic Color from wallpaper |
| Haptics | HapticFeedbackConstants |

---

## Component Sizing Reference

```typescript
// Touch targets
const TOUCH_TARGET = {
  ios: moderateScale(44),
  android: moderateScale(48),
};

// Icon sizes
const ICON_SIZE = {
  small: moderateScale(16),
  medium: moderateScale(24),
  large: moderateScale(32),
};

// Border radius
const RADIUS = {
  none: 0,
  small: moderateScale(4),
  medium: moderateScale(8),
  large: moderateScale(12),
  xl: moderateScale(16),
  full: 9999,
};

// Spacing
const SPACING = {
  xs: scale(4),
  sm: scale(8),
  md: scale(16),
  lg: scale(24),
  xl: scale(32),
};
```

---

## Navigation Patterns

### Tab Bar (Recommended for 3-5 sections)

```typescript
// Good: Clear, consistent tabs
const tabs = [
  { name: 'Home', icon: 'house' },
  { name: 'Search', icon: 'magnifyingglass' },
  { name: 'Create', icon: 'plus.circle.fill' }, // Primary action
  { name: 'Activity', icon: 'bell' },
  { name: 'Profile', icon: 'person' },
];

// iOS: Labels always visible
// Android: Labels on selection or always
```

### Stack Navigation

```typescript
// Header configuration
const screenOptions = {
  headerLargeTitle: true, // iOS
  headerShadowVisible: false,
  headerBackTitleVisible: false,
  animation: 'slide_from_right', // or 'fade'
};
```

### Modal/Sheet

```typescript
// iOS-style sheet
const modalOptions = {
  presentation: 'modal', // or 'formSheet', 'pageSheet'
  sheetAllowedDetents: ['medium', 'large'],
  sheetGrabberVisible: true,
};
```

---

## Animation Guidelines

| Level | When to Use | Examples |
|-------|-------------|----------|
| **System Default** | Utility apps, productivity | Screen transitions only |
| **Subtle Polish** | Most apps | Button press, list items |
| **Expressive** | Social, lifestyle | Page transitions, gestures |
| **Rich & Playful** | Gen Z, gaming | Celebrations, onboarding |

### Spring Configurations

```typescript
import { withSpring } from 'react-native-reanimated';

// Snappy (buttons, small elements)
const snappySpring = { damping: 15, stiffness: 150 };

// Smooth (cards, sheets)
const smoothSpring = { damping: 20, stiffness: 100 };

// Bouncy (playful, celebrations)
const bouncySpring = { damping: 10, stiffness: 100 };
```

---

## Example Scenarios

### Scenario 1: iOS Social App

```
Platform: iOS First
Direction: Playful Expressive
Colors: Dynamic/Vibrant
Navigation: Tab Bar
Animation: Rich & Playful
Components: Rounded Soft

→ Apply iOS HIG with personality
→ Large titles, SF Symbols, haptics
→ Custom animations for likes, shares
→ Rounded cards, soft shadows
```

### Scenario 2: Cross-Platform Productivity

```
Platform: Cross-Platform
Direction: Minimal Utility
Colors: Neutral + Accent
Navigation: Tab Bar + Stack
Animation: Subtle Polish
Components: Platform Native

→ Hybrid adaptive approach
→ Platform-specific navigation feel
→ Consistent functionality
→ Minimal animations, max efficiency
```

### Scenario 3: Android E-commerce

```
Platform: Android First
Direction: Material You
Colors: Brand Dominant
Navigation: Bottom Nav + Drawer
Animation: Expressive
Components: Card-Based

→ Apply Material Design 3
→ Dynamic color for personalization
→ FAB for cart/purchase action
→ Elevated product cards
```

---

## Final Checklist

Before completing the design, verify:

- [ ] Touch targets meet platform minimums (44pt/48dp)
- [ ] Safe areas are properly handled
- [ ] Loading states are implemented (skeletons preferred)
- [ ] Error states are user-friendly
- [ ] Haptic feedback on significant actions
- [ ] Navigation is consistent and predictable
- [ ] Accessibility labels are present
- [ ] Scales properly across device sizes
- [ ] Dark mode is supported
- [ ] Platform conventions are respected

---

## Response Format

When presenting design choices to users, summarize the configuration:

```
## App Design Configuration Summary

| Setting | Choice |
|---------|--------|
| Platform | iOS First |
| Direction | Playful Expressive |
| Colors | Dynamic/Vibrant |
| Navigation | Tab Bar (5 tabs) |
| Animation | Rich & Playful |
| Components | Rounded Soft |

### Implementation Notes
- Using SF Symbols for icons
- Haptic feedback on all interactions
- Custom spring animations for social actions
- Supporting Dynamic Type

Proceeding with implementation...
```
