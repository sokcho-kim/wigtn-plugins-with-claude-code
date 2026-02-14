# Material Design 3 for React Native

## Core Principles

### 1. Adaptive
- **Responsive** to different screen sizes and orientations
- **Accessible** to users with different abilities
- **Personal** with Dynamic Color

### 2. Personal
- **Dynamic Color** derived from user's wallpaper
- **Color roles** for consistent theming
- **Expressive** while maintaining usability

### 3. Expressive
- **Motion** that's meaningful
- **Typography** that's scalable
- **Shape** that conveys meaning

---

## Material You Color System

```typescript
// theme/material-colors.ts
export const materialColors = {
  light: {
    // Primary
    primary: '#6750A4',
    onPrimary: '#FFFFFF',
    primaryContainer: '#EADDFF',
    onPrimaryContainer: '#21005D',

    // Secondary
    secondary: '#625B71',
    onSecondary: '#FFFFFF',
    secondaryContainer: '#E8DEF8',
    onSecondaryContainer: '#1D192B',

    // Tertiary
    tertiary: '#7D5260',
    onTertiary: '#FFFFFF',
    tertiaryContainer: '#FFD8E4',
    onTertiaryContainer: '#31111D',

    // Error
    error: '#B3261E',
    onError: '#FFFFFF',
    errorContainer: '#F9DEDC',
    onErrorContainer: '#410E0B',

    // Surface
    surface: '#FFFBFE',
    onSurface: '#1C1B1F',
    surfaceVariant: '#E7E0EC',
    onSurfaceVariant: '#49454F',

    // Outline
    outline: '#79747E',
    outlineVariant: '#CAC4D0',

    // Background
    background: '#FFFBFE',
    onBackground: '#1C1B1F',

    // Inverse
    inverseSurface: '#313033',
    inverseOnSurface: '#F4EFF4',
    inversePrimary: '#D0BCFF',

    // Other
    scrim: '#000000',
    shadow: '#000000',
  },
  dark: {
    // Primary
    primary: '#D0BCFF',
    onPrimary: '#381E72',
    primaryContainer: '#4F378B',
    onPrimaryContainer: '#EADDFF',

    // Secondary
    secondary: '#CCC2DC',
    onSecondary: '#332D41',
    secondaryContainer: '#4A4458',
    onSecondaryContainer: '#E8DEF8',

    // Tertiary
    tertiary: '#EFB8C8',
    onTertiary: '#492532',
    tertiaryContainer: '#633B48',
    onTertiaryContainer: '#FFD8E4',

    // Error
    error: '#F2B8B5',
    onError: '#601410',
    errorContainer: '#8C1D18',
    onErrorContainer: '#F9DEDC',

    // Surface
    surface: '#1C1B1F',
    onSurface: '#E6E1E5',
    surfaceVariant: '#49454F',
    onSurfaceVariant: '#CAC4D0',

    // Outline
    outline: '#938F99',
    outlineVariant: '#49454F',

    // Background
    background: '#1C1B1F',
    onBackground: '#E6E1E5',

    // Inverse
    inverseSurface: '#E6E1E5',
    inverseOnSurface: '#313033',
    inversePrimary: '#6750A4',

    // Other
    scrim: '#000000',
    shadow: '#000000',
  },
} as const;
```

---

## Typography Scale

```typescript
// theme/material-typography.ts
import { moderateScale } from 'react-native-size-matters';

export const materialTypography = {
  displayLarge: {
    fontSize: moderateScale(57),
    lineHeight: moderateScale(64),
    fontWeight: '400' as const,
    letterSpacing: -0.25,
  },
  displayMedium: {
    fontSize: moderateScale(45),
    lineHeight: moderateScale(52),
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
  displaySmall: {
    fontSize: moderateScale(36),
    lineHeight: moderateScale(44),
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
  headlineLarge: {
    fontSize: moderateScale(32),
    lineHeight: moderateScale(40),
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
  headlineMedium: {
    fontSize: moderateScale(28),
    lineHeight: moderateScale(36),
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
  headlineSmall: {
    fontSize: moderateScale(24),
    lineHeight: moderateScale(32),
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
  titleLarge: {
    fontSize: moderateScale(22),
    lineHeight: moderateScale(28),
    fontWeight: '400' as const,
    letterSpacing: 0,
  },
  titleMedium: {
    fontSize: moderateScale(16),
    lineHeight: moderateScale(24),
    fontWeight: '500' as const,
    letterSpacing: 0.15,
  },
  titleSmall: {
    fontSize: moderateScale(14),
    lineHeight: moderateScale(20),
    fontWeight: '500' as const,
    letterSpacing: 0.1,
  },
  labelLarge: {
    fontSize: moderateScale(14),
    lineHeight: moderateScale(20),
    fontWeight: '500' as const,
    letterSpacing: 0.1,
  },
  labelMedium: {
    fontSize: moderateScale(12),
    lineHeight: moderateScale(16),
    fontWeight: '500' as const,
    letterSpacing: 0.5,
  },
  labelSmall: {
    fontSize: moderateScale(11),
    lineHeight: moderateScale(16),
    fontWeight: '500' as const,
    letterSpacing: 0.5,
  },
  bodyLarge: {
    fontSize: moderateScale(16),
    lineHeight: moderateScale(24),
    fontWeight: '400' as const,
    letterSpacing: 0.5,
  },
  bodyMedium: {
    fontSize: moderateScale(14),
    lineHeight: moderateScale(20),
    fontWeight: '400' as const,
    letterSpacing: 0.25,
  },
  bodySmall: {
    fontSize: moderateScale(12),
    lineHeight: moderateScale(16),
    fontWeight: '400' as const,
    letterSpacing: 0.4,
  },
} as const;
```

---

## Navigation Patterns

### Bottom Navigation

```tsx
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import MaterialCommunityIcons from '@expo/vector-icons/MaterialCommunityIcons';

const Tab = createBottomTabNavigator();

function BottomNavigation() {
  const { theme } = useTheme();

  return (
    <Tab.Navigator
      screenOptions={{
        tabBarStyle: {
          height: moderateScale(80),
          paddingBottom: moderateScale(16),
          backgroundColor: theme.colors.surface,
          borderTopWidth: 0,
          elevation: 0,
        },
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.onSurfaceVariant,
        tabBarLabelStyle: {
          ...materialTypography.labelMedium,
        },
        tabBarIconStyle: {
          marginTop: moderateScale(12),
        },
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="home" color={color} size={size} />
          ),
        }}
      />
      {/* 3-5 destinations */}
    </Tab.Navigator>
  );
}
```

### Top App Bar

```tsx
import { Appbar } from 'react-native-paper';

function TopAppBar({ title, onBack, actions }) {
  return (
    <Appbar.Header
      elevated={false}
      style={{ backgroundColor: 'transparent' }}
    >
      {onBack && <Appbar.BackAction onPress={onBack} />}
      <Appbar.Content title={title} />
      {actions?.map((action, i) => (
        <Appbar.Action
          key={i}
          icon={action.icon}
          onPress={action.onPress}
        />
      ))}
    </Appbar.Header>
  );
}
```

### Navigation Drawer

```tsx
import { createDrawerNavigator } from '@react-navigation/drawer';

const Drawer = createDrawerNavigator();

function DrawerNavigation() {
  return (
    <Drawer.Navigator
      screenOptions={{
        drawerStyle: {
          width: moderateScale(360),
        },
        drawerType: 'front',
        overlayColor: 'rgba(0, 0, 0, 0.32)',
      }}
    >
      {/* Drawer screens */}
    </Drawer.Navigator>
  );
}
```

---

## Material Components

### FAB (Floating Action Button)

```tsx
import { FAB } from 'react-native-paper';

function FloatingActionButton({ onPress, icon = 'plus' }) {
  const { theme } = useTheme();

  return (
    <FAB
      icon={icon}
      onPress={onPress}
      style={{
        position: 'absolute',
        right: scale(16),
        bottom: scale(16),
        backgroundColor: theme.colors.primaryContainer,
      }}
      color={theme.colors.onPrimaryContainer}
    />
  );
}

// Extended FAB
<FAB
  icon="plus"
  label="Create"
  extended
  onPress={onCreate}
/>
```

### Cards

```tsx
import { StyleSheet, View, Text, Pressable } from 'react-native';
import { moderateScale, scale } from 'react-native-size-matters';

function MaterialCard({ title, subtitle, onPress }) {
  const { theme } = useTheme();

  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.card,
        { backgroundColor: theme.colors.surfaceVariant }
      ]}
    >
      <Text style={[
        materialTypography.titleMedium,
        { color: theme.colors.onSurface }
      ]}>
        {title}
      </Text>
      <Text style={[
        materialTypography.bodyMedium,
        { color: theme.colors.onSurfaceVariant }
      ]}>
        {subtitle}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: moderateScale(12),
    padding: scale(16),
  },
});
```

### Bottom Sheet

```tsx
import BottomSheet from '@gorhom/bottom-sheet';

function MaterialBottomSheet({ children }) {
  const { theme } = useTheme();
  const bottomSheetRef = useRef<BottomSheet>(null);
  const snapPoints = useMemo(() => ['25%', '50%', '90%'], []);

  return (
    <BottomSheet
      ref={bottomSheetRef}
      snapPoints={snapPoints}
      backgroundStyle={{
        backgroundColor: theme.colors.surface,
      }}
      handleIndicatorStyle={{
        backgroundColor: theme.colors.onSurfaceVariant,
        width: moderateScale(32),
        height: moderateScale(4),
      }}
    >
      {children}
    </BottomSheet>
  );
}
```

### Snackbar

```tsx
import { Snackbar } from 'react-native-paper';

function useSnackbar() {
  const [visible, setVisible] = useState(false);
  const [message, setMessage] = useState('');
  const [action, setAction] = useState<{ label: string; onPress: () => void } | null>(null);

  const show = (msg: string, actionConfig?: typeof action) => {
    setMessage(msg);
    setAction(actionConfig || null);
    setVisible(true);
  };

  const SnackbarComponent = () => (
    <Snackbar
      visible={visible}
      onDismiss={() => setVisible(false)}
      duration={4000}
      action={action}
      style={{
        marginBottom: moderateScale(80), // Above bottom nav
      }}
    >
      {message}
    </Snackbar>
  );

  return { show, SnackbarComponent };
}
```

### Chips

```tsx
import { Chip } from 'react-native-paper';

function FilterChips({ filters, selected, onSelect }) {
  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false}>
      {filters.map((filter) => (
        <Chip
          key={filter.id}
          selected={selected === filter.id}
          onPress={() => onSelect(filter.id)}
          style={{ marginRight: scale(8) }}
        >
          {filter.label}
        </Chip>
      ))}
    </ScrollView>
  );
}
```

---

## Elevation (Tonal Surface)

Material 3 uses tonal elevation instead of shadows:

```typescript
// Surface tones at different elevations
const surfaceTones = {
  level0: 'transparent',
  level1: 'rgba(103, 80, 164, 0.05)', // Primary at 5%
  level2: 'rgba(103, 80, 164, 0.08)',
  level3: 'rgba(103, 80, 164, 0.11)',
  level4: 'rgba(103, 80, 164, 0.12)',
  level5: 'rgba(103, 80, 164, 0.14)',
};

// Usage
<View style={{
  backgroundColor: surfaceTones.level2,
  borderRadius: moderateScale(12),
}}>
```

---

## Motion

### Duration

```typescript
const duration = {
  short1: 50,
  short2: 100,
  short3: 150,
  short4: 200,
  medium1: 250,
  medium2: 300,
  medium3: 350,
  medium4: 400,
  long1: 450,
  long2: 500,
  long3: 550,
  long4: 600,
  extraLong1: 700,
  extraLong2: 800,
  extraLong3: 900,
  extraLong4: 1000,
};
```

### Easing

```typescript
import { Easing } from 'react-native-reanimated';

const easing = {
  standard: Easing.bezier(0.2, 0, 0, 1),
  standardDecelerate: Easing.bezier(0, 0, 0, 1),
  standardAccelerate: Easing.bezier(0.3, 0, 1, 1),
  emphasized: Easing.bezier(0.2, 0, 0, 1),
  emphasizedDecelerate: Easing.bezier(0.05, 0.7, 0.1, 1),
  emphasizedAccelerate: Easing.bezier(0.3, 0, 0.8, 0.15),
};
```

---

## Haptic Feedback

```typescript
import { Vibration, Platform } from 'react-native';
import * as Haptics from 'expo-haptics';

export const haptics = {
  // Click feedback
  click: () => {
    if (Platform.OS === 'android') {
      Vibration.vibrate(10);
    } else {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }
  },

  // Long press feedback
  longPress: () => {
    if (Platform.OS === 'android') {
      Vibration.vibrate(20);
    } else {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }
  },
};
```

---

## Do's and Don'ts

### ✅ Do
- Use Material You color system
- Apply tonal elevation
- Use FAB for primary actions
- Use bottom sheets for contextual content
- Use snackbars for brief feedback
- Follow touch target minimums (48dp)
- Support Material motion guidelines

### ❌ Don't
- Use iOS-style tab bars
- Use iOS-style action sheets
- Ignore tonal surfaces
- Use shadows instead of elevation
- Make FABs too small
- Use alerts for everything
- Skip haptic feedback
