# Mobile Haptic Feedback Patterns

## Overview

Haptic feedback provides tactile responses that:
- Confirm user actions
- Provide feedback for gestures
- Enhance the sense of direct manipulation
- Communicate state changes

---

## Setup

### Expo

```bash
npx expo install expo-haptics
```

### React Native CLI

```bash
npm install react-native-haptic-feedback
cd ios && pod install
```

---

## Haptic Types

### Impact Feedback

Physical "tap" sensations of varying intensity.

```typescript
import * as Haptics from 'expo-haptics';

// Light - Subtle tap
// Use for: Toggles, selections, light touches
Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

// Medium - Standard tap
// Use for: Button presses, confirmations
Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);

// Heavy - Strong tap
// Use for: Significant actions, mode changes
Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);

// Soft - Gentle impact (iOS 13+)
// Use for: Soft UI elements, subtle feedback
Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Soft);

// Rigid - Sharp impact (iOS 13+)
// Use for: Rigid UI elements, precise actions
Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Rigid);
```

### Notification Feedback

Communicates outcomes of actions.

```typescript
// Success - Task completed successfully
// Use for: Save complete, upload done, payment success
Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

// Warning - Attention needed
// Use for: Destructive action warning, low battery
Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);

// Error - Action failed
// Use for: Failed submission, validation error
Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
```

### Selection Feedback

For scrolling through discrete values.

```typescript
// Selection - Tick through values
// Use for: Picker scrolling, segment changes, slider ticks
Haptics.selectionAsync();
```

---

## Haptics Utility

```typescript
// lib/haptics.ts
import * as Haptics from 'expo-haptics';
import { Platform } from 'react-native';

const isHapticsSupported = Platform.OS === 'ios' || Platform.OS === 'android';

export const haptics = {
  // Light tap for minor interactions
  light: () => {
    if (!isHapticsSupported) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  },

  // Medium tap for standard actions
  medium: () => {
    if (!isHapticsSupported) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
  },

  // Heavy tap for significant actions
  heavy: () => {
    if (!isHapticsSupported) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
  },

  // Selection tick for pickers/sliders
  selection: () => {
    if (!isHapticsSupported) return;
    Haptics.selectionAsync();
  },

  // Success notification
  success: () => {
    if (!isHapticsSupported) return;
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  },

  // Warning notification
  warning: () => {
    if (!isHapticsSupported) return;
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
  },

  // Error notification
  error: () => {
    if (!isHapticsSupported) return;
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
  },
};
```

---

## Usage Patterns

### Button Press

```tsx
import { Pressable } from 'react-native';
import { haptics } from '@/lib/haptics';

function Button({ onPress, children }) {
  const handlePress = () => {
    haptics.medium();
    onPress?.();
  };

  return (
    <Pressable onPress={handlePress}>
      {children}
    </Pressable>
  );
}
```

### Toggle Switch

```tsx
function Toggle({ value, onChange }) {
  const handleChange = (newValue: boolean) => {
    haptics.light();
    onChange(newValue);
  };

  return (
    <Switch value={value} onValueChange={handleChange} />
  );
}
```

### Pull to Refresh

```tsx
function PullToRefresh({ onRefresh }) {
  const handleRefresh = async () => {
    haptics.medium();
    await onRefresh();
    haptics.success();
  };

  return (
    <RefreshControl
      refreshing={refreshing}
      onRefresh={handleRefresh}
    />
  );
}
```

### Form Validation

```tsx
function Form() {
  const onSubmit = async (data) => {
    try {
      await submitForm(data);
      haptics.success();
      // Show success state
    } catch (error) {
      haptics.error();
      // Show error state
    }
  };

  const onValidationError = () => {
    haptics.warning();
    // Highlight invalid fields
  };
}
```

### Picker/Selector

```tsx
import { Picker } from '@react-native-picker/picker';

function ValuePicker({ value, options, onChange }) {
  return (
    <Picker
      selectedValue={value}
      onValueChange={(itemValue) => {
        haptics.selection();
        onChange(itemValue);
      }}
    >
      {options.map(option => (
        <Picker.Item key={option.value} {...option} />
      ))}
    </Picker>
  );
}
```

### Slider

```tsx
import Slider from '@react-native-community/slider';
import { useRef } from 'react';

function HapticSlider({ value, onChange, step = 1 }) {
  const lastValue = useRef(value);

  const handleChange = (newValue: number) => {
    // Only trigger haptic when crossing a step
    if (Math.floor(newValue / step) !== Math.floor(lastValue.current / step)) {
      haptics.selection();
    }
    lastValue.current = newValue;
    onChange(newValue);
  };

  return (
    <Slider
      value={value}
      onValueChange={handleChange}
      step={step}
    />
  );
}
```

### Swipe Actions

```tsx
import { Swipeable } from 'react-native-gesture-handler';

function SwipeableRow({ children, onDelete }) {
  const handleSwipeOpen = () => {
    haptics.medium();
  };

  const handleDelete = () => {
    haptics.heavy();
    onDelete();
  };

  return (
    <Swipeable
      onSwipeableOpen={handleSwipeOpen}
      renderRightActions={() => (
        <DeleteButton onPress={handleDelete} />
      )}
    >
      {children}
    </Swipeable>
  );
}
```

### Long Press

```tsx
function LongPressable({ onLongPress, children }) {
  const handleLongPress = () => {
    haptics.heavy();
    onLongPress?.();
  };

  return (
    <Pressable
      onLongPress={handleLongPress}
      delayLongPress={500}
    >
      {children}
    </Pressable>
  );
}
```

### Gesture Threshold

```tsx
import Animated, { useAnimatedReaction, runOnJS } from 'react-native-reanimated';

function DragGesture() {
  const translateX = useSharedValue(0);
  const hasTriggeredHaptic = useSharedValue(false);
  const THRESHOLD = 100;

  useAnimatedReaction(
    () => translateX.value,
    (value) => {
      if (Math.abs(value) > THRESHOLD && !hasTriggeredHaptic.value) {
        hasTriggeredHaptic.value = true;
        runOnJS(haptics.medium)();
      } else if (Math.abs(value) <= THRESHOLD) {
        hasTriggeredHaptic.value = false;
      }
    }
  );
}
```

---

## When to Use Haptics

### ✅ Good Use Cases

| Action | Haptic Type | Reason |
|--------|-------------|--------|
| Button tap | Medium | Confirms press |
| Toggle change | Light | Subtle state change |
| Picker scroll | Selection | Each value tick |
| Pull to refresh | Medium → Success | Start and complete |
| Form error | Warning/Error | Alert user |
| Delete swipe | Heavy | Significant action |
| Long press menu | Heavy | Mode change |
| Successful save | Success | Positive confirmation |

### ❌ Avoid Haptics For

- Every scroll event (battery drain)
- Automatic/timed events (annoying)
- Background operations (unexpected)
- High-frequency updates (overwhelming)
- Animations (not user-initiated)

---

## Platform Considerations

### iOS

- Haptic Engine available on iPhone 7+
- All haptic types supported
- Respects system haptic settings

### Android

- Vibration API (less nuanced)
- Varies by device manufacturer
- May need fallback patterns

```typescript
// Platform-aware haptics
const platformHaptics = {
  medium: () => {
    if (Platform.OS === 'ios') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    } else {
      // Android fallback
      Vibration.vibrate(10);
    }
  },
};
```

---

## Testing Haptics

Haptics only work on **physical devices**, not simulators.

```typescript
// Development helper
const isDev = __DEV__;

export const haptics = {
  medium: () => {
    if (isDev) console.log('Haptic: medium');
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
  },
};
```

---

## Best Practices

### Do's

- **Be consistent** - Same action = same haptic
- **Be purposeful** - Every haptic should have meaning
- **Be subtle** - Light/medium for most interactions
- **Confirm actions** - Especially destructive ones
- **Respect user settings** - Check system preferences

### Don'ts

- **Don't overuse** - Haptic fatigue is real
- **Don't use for passive content** - Only user-initiated actions
- **Don't ignore feedback** - Test on real devices
- **Don't use heavy for everything** - Reserve for significant actions
- **Don't chain haptics** - One per action is enough
