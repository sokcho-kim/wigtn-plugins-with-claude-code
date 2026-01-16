---
name: navigation
description: Master mobile navigation with Expo Router and React Navigation. Implement tab bars, stacks, drawers, deep linking, and authentication flows. Use when setting up app navigation or implementing complex routing patterns.
---

# Navigation in React Native

Comprehensive guide to mobile navigation with Expo Router (file-based) and React Navigation (imperative).

## When to Use This Skill

- Setting up app navigation structure
- Implementing tab bars with nested stacks
- Building authentication flows
- Handling deep links and universal links
- Creating modal presentations
- Navigation state persistence

## Core Concepts

### 1. Navigation Options

| Library | Approach | Best For |
|---------|----------|----------|
| **Expo Router** | File-based | Expo projects, simplicity |
| **React Navigation** | Imperative | Complex patterns, RN CLI |

### 2. Navigator Types

```
Stack - Screen hierarchy (push/pop)
Tab - Bottom/top tab bar
Drawer - Side menu
Modal - Overlay screens
```

## Quick Start

### Expo Router Setup

```bash
npx create-expo-app@latest --template tabs
```

```
app/
├── _layout.tsx          # Root layout (providers, fonts)
├── index.tsx            # Home screen (/)
├── (tabs)/              # Tab group
│   ├── _layout.tsx      # Tab bar configuration
│   ├── index.tsx        # First tab
│   ├── explore.tsx      # Second tab
│   └── profile.tsx      # Third tab
├── (auth)/              # Auth group (no tab bar)
│   ├── _layout.tsx
│   ├── login.tsx
│   └── register.tsx
├── [id].tsx             # Dynamic route (/123)
├── settings/
│   ├── _layout.tsx      # Settings stack
│   ├── index.tsx
│   └── [setting].tsx    # /settings/notifications
└── +not-found.tsx       # 404 page
```

## Patterns

### Pattern 1: Expo Router Tab Navigation

```tsx
// app/_layout.tsx
import { Stack } from 'expo-router';
import { ThemeProvider } from '@/providers/ThemeProvider';
import { AuthProvider } from '@/providers/AuthProvider';

export default function RootLayout() {
  return (
    <AuthProvider>
      <ThemeProvider>
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="(tabs)" />
          <Stack.Screen name="(auth)" />
          <Stack.Screen
            name="modal"
            options={{ presentation: 'modal' }}
          />
        </Stack>
      </ThemeProvider>
    </AuthProvider>
  );
}

// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { Home, Search, User } from 'lucide-react-native';
import { useTheme } from '@/providers/ThemeProvider';

export default function TabLayout() {
  const { colors } = useTheme();

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.mutedForeground,
        tabBarStyle: {
          backgroundColor: colors.background,
          borderTopColor: colors.border,
          height: 85,
          paddingBottom: 30,
          paddingTop: 10,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '500',
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => <Home size={size} color={color} />,
        }}
      />
      <Tabs.Screen
        name="explore"
        options={{
          title: 'Explore',
          tabBarIcon: ({ color, size }) => <Search size={size} color={color} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => <User size={size} color={color} />,
        }}
      />
    </Tabs>
  );
}

// app/(tabs)/index.tsx
import { View, Text, Pressable } from 'react-native';
import { Link, router } from 'expo-router';

export default function HomeScreen() {
  return (
    <View className="flex-1 bg-background p-4">
      <Text className="text-2xl font-bold text-foreground">Home</Text>

      {/* Declarative navigation */}
      <Link href="/explore" asChild>
        <Pressable className="bg-primary p-4 rounded-xl mt-4">
          <Text className="text-primary-foreground">Go to Explore</Text>
        </Pressable>
      </Link>

      {/* Imperative navigation */}
      <Pressable
        onPress={() => router.push('/profile')}
        className="bg-secondary p-4 rounded-xl mt-4"
      >
        <Text className="text-secondary-foreground">Go to Profile</Text>
      </Pressable>

      {/* With params */}
      <Link href={{ pathname: '/[id]', params: { id: '123' } }} asChild>
        <Pressable className="bg-muted p-4 rounded-xl mt-4">
          <Text className="text-muted-foreground">View Item 123</Text>
        </Pressable>
      </Link>
    </View>
  );
}
```

### Pattern 2: Authentication Flow

```tsx
// app/(auth)/_layout.tsx
import { Stack } from 'expo-router';

export default function AuthLayout() {
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="login" />
      <Stack.Screen name="register" />
      <Stack.Screen name="forgot-password" />
    </Stack>
  );
}

// providers/AuthProvider.tsx
import { createContext, useContext, useEffect, useState } from 'react';
import { router, useSegments, useRootNavigationState } from 'expo-router';
import * as SecureStore from 'expo-secure-store';

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const segments = useSegments();
  const navigationState = useRootNavigationState();

  // Check auth state on mount
  useEffect(() => {
    checkAuth();
  }, []);

  // Handle navigation based on auth state
  useEffect(() => {
    if (!navigationState?.key) return;

    const inAuthGroup = segments[0] === '(auth)';

    if (!user && !inAuthGroup) {
      // Redirect to login if not authenticated
      router.replace('/(auth)/login');
    } else if (user && inAuthGroup) {
      // Redirect to home if authenticated but on auth screen
      router.replace('/(tabs)');
    }
  }, [user, segments, navigationState]);

  const checkAuth = async () => {
    try {
      const token = await SecureStore.getItemAsync('auth_token');
      if (token) {
        const userData = await fetchUser(token);
        setUser(userData);
      }
    } catch (error) {
      console.error('Auth check failed:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const signIn = async (email: string, password: string) => {
    const response = await api.login(email, password);
    await SecureStore.setItemAsync('auth_token', response.token);
    setUser(response.user);
  };

  const signOut = async () => {
    await SecureStore.deleteItemAsync('auth_token');
    setUser(null);
    router.replace('/(auth)/login');
  };

  return (
    <AuthContext.Provider value={{ user, isLoading, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};

// app/(auth)/login.tsx
import { useState } from 'react';
import { View, TextInput, Pressable, Text, Alert } from 'react-native';
import { Link } from 'expo-router';
import { useAuth } from '@/providers/AuthProvider';

export default function LoginScreen() {
  const { signIn } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      await signIn(email, password);
    } catch (error) {
      Alert.alert('Error', 'Invalid credentials');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className="flex-1 bg-background justify-center p-6">
      <Text className="text-3xl font-bold text-foreground mb-8">Sign In</Text>

      <TextInput
        className="bg-muted px-4 py-3 rounded-xl mb-4 text-foreground"
        placeholder="Email"
        placeholderTextColor="#64748B"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
      />

      <TextInput
        className="bg-muted px-4 py-3 rounded-xl mb-6 text-foreground"
        placeholder="Password"
        placeholderTextColor="#64748B"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />

      <Pressable
        onPress={handleLogin}
        disabled={loading}
        className="bg-primary py-4 rounded-xl items-center"
      >
        <Text className="text-primary-foreground font-semibold">
          {loading ? 'Signing in...' : 'Sign In'}
        </Text>
      </Pressable>

      <Link href="/(auth)/register" asChild>
        <Pressable className="mt-4 items-center">
          <Text className="text-muted-foreground">
            Don't have an account? <Text className="text-primary">Sign Up</Text>
          </Text>
        </Pressable>
      </Link>
    </View>
  );
}
```

### Pattern 3: Deep Linking

```tsx
// app.json
{
  "expo": {
    "scheme": "myapp",
    "web": {
      "bundler": "metro"
    },
    "ios": {
      "bundleIdentifier": "com.myapp.app",
      "associatedDomains": ["applinks:myapp.com"]
    },
    "android": {
      "package": "com.myapp.app",
      "intentFilters": [
        {
          "action": "VIEW",
          "autoVerify": true,
          "data": [
            {
              "scheme": "https",
              "host": "myapp.com",
              "pathPrefix": "/"
            }
          ],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}

// Deep link handling
// myapp://item/123 → /[id].tsx with id=123
// https://myapp.com/item/123 → same

// app/[id].tsx
import { useLocalSearchParams } from 'expo-router';
import { View, Text } from 'react-native';
import { useQuery } from '@tanstack/react-query';

export default function ItemScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();

  const { data: item, isLoading } = useQuery({
    queryKey: ['item', id],
    queryFn: () => fetchItem(id),
    enabled: !!id,
  });

  if (isLoading) return <LoadingSkeleton />;

  return (
    <View className="flex-1 bg-background p-4">
      <Text className="text-2xl font-bold">{item?.title}</Text>
      <Text className="text-muted-foreground mt-2">{item?.description}</Text>
    </View>
  );
}

// Handling deep links programmatically
import * as Linking from 'expo-linking';

// Get initial URL (app opened from link)
const url = await Linking.getInitialURL();

// Listen for incoming links
Linking.addEventListener('url', ({ url }) => {
  const parsed = Linking.parse(url);
  // Handle the parsed URL
});

// Create a shareable link
const shareUrl = Linking.createURL('/item/123');
```

### Pattern 4: React Navigation (Non-Expo)

```tsx
// navigation/index.tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Home, Search, User } from 'lucide-react-native';

export type RootStackParamList = {
  Main: undefined;
  Auth: undefined;
  Modal: { itemId: string };
};

export type MainTabParamList = {
  Home: undefined;
  Explore: undefined;
  Profile: undefined;
};

export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();
const AuthStack = createNativeStackNavigator<AuthStackParamList>();

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#3B82F6',
        tabBarInactiveTintColor: '#64748B',
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color, size }) => <Home size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="Explore"
        component={ExploreScreen}
        options={{
          tabBarIcon: ({ color, size }) => <Search size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ color, size }) => <User size={size} color={color} />,
        }}
      />
    </Tab.Navigator>
  );
}

function AuthScreens() {
  return (
    <AuthStack.Navigator screenOptions={{ headerShown: false }}>
      <AuthStack.Screen name="Login" component={LoginScreen} />
      <AuthStack.Screen name="Register" component={RegisterScreen} />
    </AuthStack.Navigator>
  );
}

export default function Navigation() {
  const { user } = useAuth();

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {user ? (
          <>
            <Stack.Screen name="Main" component={MainTabs} />
            <Stack.Screen
              name="Modal"
              component={ModalScreen}
              options={{ presentation: 'modal' }}
            />
          </>
        ) : (
          <Stack.Screen name="Auth" component={AuthScreens} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

// Type-safe navigation hook
import { useNavigation, NavigationProp } from '@react-navigation/native';

type NavigationType = NavigationProp<RootStackParamList>;

export function useAppNavigation() {
  return useNavigation<NavigationType>();
}

// Usage
const navigation = useAppNavigation();
navigation.navigate('Modal', { itemId: '123' });
```

### Pattern 5: Modal Presentations

```tsx
// app/modal.tsx (Expo Router)
import { View, Text, Pressable } from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { BlurView } from 'expo-blur';
import { X } from 'lucide-react-native';
import Animated, {
  FadeIn,
  FadeOut,
  SlideInDown,
  SlideOutDown
} from 'react-native-reanimated';

export default function ModalScreen() {
  const { title, message } = useLocalSearchParams<{
    title: string;
    message: string;
  }>();

  return (
    <Animated.View
      entering={FadeIn}
      exiting={FadeOut}
      className="flex-1 justify-end"
    >
      <Pressable
        className="absolute inset-0 bg-black/50"
        onPress={() => router.back()}
      />

      <Animated.View
        entering={SlideInDown.springify().damping(15)}
        exiting={SlideOutDown}
        className="bg-background rounded-t-3xl p-6 min-h-[300]"
      >
        <View className="flex-row justify-between items-center mb-4">
          <Text className="text-xl font-bold text-foreground">{title}</Text>
          <Pressable
            onPress={() => router.back()}
            className="p-2 bg-muted rounded-full"
          >
            <X size={20} color="#64748B" />
          </Pressable>
        </View>

        <Text className="text-muted-foreground">{message}</Text>

        <Pressable
          onPress={() => router.back()}
          className="bg-primary py-4 rounded-xl mt-6 items-center"
        >
          <Text className="text-primary-foreground font-semibold">Close</Text>
        </Pressable>
      </Animated.View>
    </Animated.View>
  );
}

// Opening the modal
router.push({
  pathname: '/modal',
  params: { title: 'Success!', message: 'Your action was completed.' },
});
```

### Pattern 6: Nested Navigation with Header

```tsx
// app/settings/_layout.tsx
import { Stack } from 'expo-router';
import { useTheme } from '@/providers/ThemeProvider';

export default function SettingsLayout() {
  const { colors } = useTheme();

  return (
    <Stack
      screenOptions={{
        headerStyle: { backgroundColor: colors.background },
        headerTintColor: colors.foreground,
        headerTitleStyle: { fontWeight: '600' },
        headerShadowVisible: false,
        headerBackTitle: 'Back',
      }}
    >
      <Stack.Screen
        name="index"
        options={{ title: 'Settings' }}
      />
      <Stack.Screen
        name="profile"
        options={{ title: 'Edit Profile' }}
      />
      <Stack.Screen
        name="notifications"
        options={{ title: 'Notifications' }}
      />
      <Stack.Screen
        name="privacy"
        options={{ title: 'Privacy' }}
      />
    </Stack>
  );
}

// app/settings/index.tsx
import { View, Text, Pressable } from 'react-native';
import { Link } from 'expo-router';
import {
  User,
  Bell,
  Shield,
  ChevronRight
} from 'lucide-react-native';

const settingsItems = [
  { href: '/settings/profile', icon: User, label: 'Edit Profile' },
  { href: '/settings/notifications', icon: Bell, label: 'Notifications' },
  { href: '/settings/privacy', icon: Shield, label: 'Privacy' },
];

export default function SettingsScreen() {
  return (
    <View className="flex-1 bg-background">
      {settingsItems.map((item) => (
        <Link key={item.href} href={item.href} asChild>
          <Pressable className="flex-row items-center px-4 py-4 border-b border-border">
            <item.icon size={24} color="#64748B" />
            <Text className="flex-1 text-foreground ml-3">{item.label}</Text>
            <ChevronRight size={20} color="#64748B" />
          </Pressable>
        </Link>
      ))}
    </View>
  );
}
```

## Best Practices

### Do's

- **Use file-based routing** with Expo Router when possible
- **Type your navigation params** for type safety
- **Handle deep links** for app sharing and marketing
- **Persist navigation state** for better UX
- **Use native transitions** for platform feel

### Don'ts

- **Don't nest too deeply** - Keep hierarchy flat
- **Don't block navigation** with slow screens
- **Don't forget gesture handling** on modals
- **Don't ignore Android back button** behavior
- **Don't hardcode screen names** - Use constants

## Resources

- [Expo Router Documentation](https://docs.expo.dev/router/introduction/)
- [React Navigation](https://reactnavigation.org/)
- [Deep Linking Guide](https://docs.expo.dev/guides/deep-linking/)
