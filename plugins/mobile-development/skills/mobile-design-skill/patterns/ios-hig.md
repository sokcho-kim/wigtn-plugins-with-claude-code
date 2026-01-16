# iOS Human Interface Guidelines for React Native

## Core Principles

### 1. Clarity
- **Legible text** at every size with Dynamic Type support
- **Precise icons** using SF Symbols
- **Purposeful design** - every element serves a function

### 2. Deference
- **Content is king** - UI supports, doesn't compete
- **Fluid motion** - respects real-world physics
- **Subtle chrome** - interface recedes, content shines

### 3. Depth
- **Visual layers** create hierarchy
- **Translucency** provides context
- **Motion** reinforces spatial relationships

---

## Navigation Patterns

### Large Title Navigation

```tsx
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

function AppNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerLargeTitle: true,
        headerLargeTitleShadowVisible: false,
        headerShadowVisible: false,
        headerBlurEffect: 'regular',
        headerTransparent: Platform.OS === 'ios',
        headerLargeTitleStyle: {
          fontWeight: '700',
        },
      }}
    >
      <Stack.Screen name="Home" component={HomeScreen} />
    </Stack.Navigator>
  );
}
```

### Tab Bar

```tsx
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { BlurView } from 'expo-blur';

const Tab = createBottomTabNavigator();

function TabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarStyle: {
          position: 'absolute',
          borderTopWidth: 0,
        },
        tabBarBackground: () => (
          <BlurView
            intensity={100}
            style={StyleSheet.absoluteFill}
            tint="light"
          />
        ),
        tabBarActiveTintColor: '#007AFF', // iOS Blue
        tabBarInactiveTintColor: '#8E8E93',
      }}
    >
      {/* Max 5 tabs */}
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Search" component={SearchScreen} />
      <Tab.Screen name="Library" component={LibraryScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}
```

### Sheet Presentation (iOS 15+)

```tsx
// Using Expo Router
<Stack.Screen
  name="modal"
  options={{
    presentation: 'modal',
    sheetAllowedDetents: ['medium', 'large'],
    sheetGrabberVisible: true,
    sheetCornerRadius: 10,
  }}
/>

// Using React Native Modal
import { Modal } from 'react-native';

<Modal
  animationType="slide"
  presentationStyle="pageSheet"
  visible={visible}
  onRequestClose={onClose}
>
  <View style={styles.sheetContainer}>
    <View style={styles.grabber} />
    {children}
  </View>
</Modal>
```

---

## SF Symbols Integration

```tsx
// Using expo-symbols (Expo SDK 51+)
import { SymbolView } from 'expo-symbols';

function IconButton({ symbolName, onPress }) {
  return (
    <Pressable onPress={onPress} style={styles.iconButton}>
      <SymbolView
        name={symbolName}
        style={styles.icon}
        tintColor="#007AFF"
        weight="medium"
      />
    </Pressable>
  );
}

// Common SF Symbol names
const SF_SYMBOLS = {
  home: 'house.fill',
  search: 'magnifyingglass',
  add: 'plus',
  settings: 'gearshape.fill',
  profile: 'person.fill',
  heart: 'heart.fill',
  share: 'square.and.arrow.up',
  more: 'ellipsis',
  close: 'xmark',
  back: 'chevron.left',
  forward: 'chevron.right',
  check: 'checkmark',
  camera: 'camera.fill',
  photo: 'photo.fill',
  bell: 'bell.fill',
  message: 'message.fill',
};
```

---

## Typography with Dynamic Type

```typescript
// lib/typography.ts
import { PixelRatio, TextStyle } from 'react-native';
import { moderateScale } from 'react-native-size-matters';

// iOS Text Styles (approximate)
export const typography = {
  largeTitle: {
    fontSize: moderateScale(34),
    fontWeight: '700' as const,
    letterSpacing: 0.37,
    lineHeight: moderateScale(41),
  },
  title1: {
    fontSize: moderateScale(28),
    fontWeight: '700' as const,
    letterSpacing: 0.36,
    lineHeight: moderateScale(34),
  },
  title2: {
    fontSize: moderateScale(22),
    fontWeight: '700' as const,
    letterSpacing: 0.35,
    lineHeight: moderateScale(28),
  },
  title3: {
    fontSize: moderateScale(20),
    fontWeight: '600' as const,
    letterSpacing: 0.38,
    lineHeight: moderateScale(25),
  },
  headline: {
    fontSize: moderateScale(17),
    fontWeight: '600' as const,
    letterSpacing: -0.41,
    lineHeight: moderateScale(22),
  },
  body: {
    fontSize: moderateScale(17),
    fontWeight: '400' as const,
    letterSpacing: -0.41,
    lineHeight: moderateScale(22),
  },
  callout: {
    fontSize: moderateScale(16),
    fontWeight: '400' as const,
    letterSpacing: -0.32,
    lineHeight: moderateScale(21),
  },
  subheadline: {
    fontSize: moderateScale(15),
    fontWeight: '400' as const,
    letterSpacing: -0.24,
    lineHeight: moderateScale(20),
  },
  footnote: {
    fontSize: moderateScale(13),
    fontWeight: '400' as const,
    letterSpacing: -0.08,
    lineHeight: moderateScale(18),
  },
  caption1: {
    fontSize: moderateScale(12),
    fontWeight: '400' as const,
    letterSpacing: 0,
    lineHeight: moderateScale(16),
  },
  caption2: {
    fontSize: moderateScale(11),
    fontWeight: '400' as const,
    letterSpacing: 0.07,
    lineHeight: moderateScale(13),
  },
} as const;
```

---

## iOS System Colors

```typescript
// theme/ios-colors.ts
export const iosColors = {
  light: {
    // Labels
    label: '#000000',
    secondaryLabel: '#3C3C43', // 60% opacity
    tertiaryLabel: '#3C3C43', // 30% opacity
    quaternaryLabel: '#3C3C43', // 18% opacity

    // Fills
    systemFill: 'rgba(120, 120, 128, 0.2)',
    secondarySystemFill: 'rgba(120, 120, 128, 0.16)',
    tertiarySystemFill: 'rgba(118, 118, 128, 0.12)',
    quaternarySystemFill: 'rgba(116, 116, 128, 0.08)',

    // Backgrounds
    systemBackground: '#FFFFFF',
    secondarySystemBackground: '#F2F2F7',
    tertiarySystemBackground: '#FFFFFF',

    // Grouped Backgrounds
    systemGroupedBackground: '#F2F2F7',
    secondarySystemGroupedBackground: '#FFFFFF',
    tertiarySystemGroupedBackground: '#F2F2F7',

    // Separator
    separator: 'rgba(60, 60, 67, 0.29)',
    opaqueSeparator: '#C6C6C8',
  },
  dark: {
    // Labels
    label: '#FFFFFF',
    secondaryLabel: 'rgba(235, 235, 245, 0.6)',
    tertiaryLabel: 'rgba(235, 235, 245, 0.3)',
    quaternaryLabel: 'rgba(235, 235, 245, 0.18)',

    // Fills
    systemFill: 'rgba(120, 120, 128, 0.36)',
    secondarySystemFill: 'rgba(120, 120, 128, 0.32)',
    tertiarySystemFill: 'rgba(118, 118, 128, 0.24)',
    quaternarySystemFill: 'rgba(116, 116, 128, 0.18)',

    // Backgrounds
    systemBackground: '#000000',
    secondarySystemBackground: '#1C1C1E',
    tertiarySystemBackground: '#2C2C2E',

    // Grouped Backgrounds
    systemGroupedBackground: '#000000',
    secondarySystemGroupedBackground: '#1C1C1E',
    tertiarySystemGroupedBackground: '#2C2C2E',

    // Separator
    separator: 'rgba(84, 84, 88, 0.6)',
    opaqueSeparator: '#38383A',
  },
  // Tint Colors
  systemBlue: '#007AFF',
  systemGreen: '#34C759',
  systemIndigo: '#5856D6',
  systemOrange: '#FF9500',
  systemPink: '#FF2D55',
  systemPurple: '#AF52DE',
  systemRed: '#FF3B30',
  systemTeal: '#5AC8FA',
  systemYellow: '#FFCC00',
} as const;
```

---

## Haptic Feedback

```typescript
// lib/haptics.ts
import * as Haptics from 'expo-haptics';

export const haptics = {
  // Light tap for selections, toggles
  light: () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light),

  // Medium for button presses, confirmations
  medium: () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium),

  // Heavy for significant actions
  heavy: () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy),

  // Selection changed (picker, segment)
  selection: () => Haptics.selectionAsync(),

  // Success notification
  success: () => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success),

  // Warning
  warning: () => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning),

  // Error
  error: () => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error),
};

// Usage
<Pressable
  onPress={() => {
    haptics.medium();
    handlePress();
  }}
>
```

---

## iOS-Style Components

### Action Sheet

```tsx
import { ActionSheetIOS, Platform } from 'react-native';

function showActionSheet(options: string[], onSelect: (index: number) => void) {
  if (Platform.OS === 'ios') {
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options: [...options, 'Cancel'],
        cancelButtonIndex: options.length,
        destructiveButtonIndex: options.findIndex(o => o.includes('Delete')),
      },
      (buttonIndex) => {
        if (buttonIndex !== options.length) {
          onSelect(buttonIndex);
        }
      }
    );
  }
}
```

### Context Menu

```tsx
import { ContextMenuButton } from 'react-native-ios-context-menu';

<ContextMenuButton
  menuConfig={{
    menuTitle: '',
    menuItems: [
      {
        actionKey: 'edit',
        actionTitle: 'Edit',
        icon: { iconType: 'SYSTEM', iconValue: 'pencil' },
      },
      {
        actionKey: 'share',
        actionTitle: 'Share',
        icon: { iconType: 'SYSTEM', iconValue: 'square.and.arrow.up' },
      },
      {
        actionKey: 'delete',
        actionTitle: 'Delete',
        icon: { iconType: 'SYSTEM', iconValue: 'trash' },
        menuAttributes: ['destructive'],
      },
    ],
  }}
  onPressMenuItem={({ nativeEvent }) => {
    handleAction(nativeEvent.actionKey);
  }}
>
  <ItemComponent />
</ContextMenuButton>
```

### Pull to Refresh

```tsx
<FlatList
  refreshControl={
    <RefreshControl
      refreshing={refreshing}
      onRefresh={onRefresh}
      tintColor="#007AFF"
    />
  }
/>
```

---

## Accessibility

```tsx
<Pressable
  accessible={true}
  accessibilityLabel="Add to favorites"
  accessibilityHint="Double tap to add this item to your favorites"
  accessibilityRole="button"
  accessibilityState={{ selected: isFavorite }}
  onPress={handleFavorite}
>
  <HeartIcon filled={isFavorite} />
</Pressable>
```

---

## Do's and Don'ts

### ✅ Do
- Use SF Symbols for icons
- Support Dynamic Type
- Use system colors that adapt
- Add haptic feedback
- Use large titles
- Support pull-to-refresh
- Use sheet presentations
- Respect safe areas

### ❌ Don't
- Use custom icons when SF Symbol exists
- Hardcode font sizes
- Use non-adaptive colors
- Skip haptic feedback
- Use Android-style navigation
- Use alert() for everything
- Ignore the notch
- Disable system gestures
