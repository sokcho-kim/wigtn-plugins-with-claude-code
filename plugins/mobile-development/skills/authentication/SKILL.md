---
name: mobile-authentication
description: Master mobile authentication with biometrics, social login, secure token storage, and session management. Implement Firebase Auth, Supabase, or custom auth flows for React Native.
---

# Mobile Authentication

Comprehensive authentication patterns for React Native including biometrics, social login, secure storage, and session management.

## When to Use This Skill

- Implementing user authentication in a mobile app
- Setting up biometric login (Face ID, Touch ID, Fingerprint)
- Integrating social login (Google, Apple, Facebook)
- Secure token storage and refresh
- Session management and auto-logout

## Core Concepts

### 1. Auth Options

| Solution | Complexity | Best For |
|----------|------------|----------|
| **Firebase Auth** | Low | Quick setup, Google ecosystem |
| **Supabase Auth** | Low | Open source, PostgreSQL |
| **Auth0/Clerk** | Medium | Enterprise, advanced features |
| **Custom Backend** | High | Full control |

### 2. Storage Security

```
Regular data → MMKV
Tokens → SecureStore (Keychain/Keystore)
Sensitive user data → SecureStore + encryption
```

## Patterns

### Pattern 1: Firebase Authentication

```bash
npx expo install @react-native-firebase/app @react-native-firebase/auth
```

```typescript
// lib/firebase.ts
import auth from '@react-native-firebase/auth';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { appleAuth } from '@invertase/react-native-apple-authentication';

GoogleSignin.configure({
  webClientId: process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID,
});

export const firebaseAuth = {
  // Email/Password
  async signUp(email: string, password: string) {
    const { user } = await auth().createUserWithEmailAndPassword(email, password);
    await user.sendEmailVerification();
    return user;
  },

  async signIn(email: string, password: string) {
    const { user } = await auth().signInWithEmailAndPassword(email, password);
    return user;
  },

  async signOut() {
    await auth().signOut();
  },

  // Google Sign In
  async signInWithGoogle() {
    await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
    const { idToken } = await GoogleSignin.signIn();
    const googleCredential = auth.GoogleAuthProvider.credential(idToken);
    const { user } = await auth().signInWithCredential(googleCredential);
    return user;
  },

  // Apple Sign In
  async signInWithApple() {
    const appleAuthRequestResponse = await appleAuth.performRequest({
      requestedOperation: appleAuth.Operation.LOGIN,
      requestedScopes: [appleAuth.Scope.EMAIL, appleAuth.Scope.FULL_NAME],
    });

    const { identityToken, nonce } = appleAuthRequestResponse;

    if (!identityToken) {
      throw new Error('Apple Sign-In failed - no identity token');
    }

    const appleCredential = auth.AppleAuthProvider.credential(identityToken, nonce);
    const { user } = await auth().signInWithCredential(appleCredential);
    return user;
  },

  // Password Reset
  async sendPasswordResetEmail(email: string) {
    await auth().sendPasswordResetEmail(email);
  },

  // Auth state listener
  onAuthStateChanged(callback: (user: any) => void) {
    return auth().onAuthStateChanged(callback);
  },

  // Get current user
  getCurrentUser() {
    return auth().currentUser;
  },

  // Get ID token for API calls
  async getIdToken() {
    const user = auth().currentUser;
    if (!user) return null;
    return user.getIdToken();
  },
};

// providers/AuthProvider.tsx
import { createContext, useContext, useEffect, useState } from 'react';
import { firebaseAuth } from '@/lib/firebase';
import { router, useSegments } from 'expo-router';

interface AuthContextType {
  user: any;
  isLoading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string) => Promise<void>;
  signInWithGoogle: () => Promise<void>;
  signInWithApple: () => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const segments = useSegments();

  useEffect(() => {
    const unsubscribe = firebaseAuth.onAuthStateChanged((user) => {
      setUser(user);
      setIsLoading(false);
    });

    return unsubscribe;
  }, []);

  // Protected route handling
  useEffect(() => {
    if (isLoading) return;

    const inAuthGroup = segments[0] === '(auth)';

    if (!user && !inAuthGroup) {
      router.replace('/(auth)/login');
    } else if (user && inAuthGroup) {
      router.replace('/(tabs)');
    }
  }, [user, segments, isLoading]);

  const value: AuthContextType = {
    user,
    isLoading,
    signIn: async (email, password) => {
      await firebaseAuth.signIn(email, password);
    },
    signUp: async (email, password) => {
      await firebaseAuth.signUp(email, password);
    },
    signInWithGoogle: async () => {
      await firebaseAuth.signInWithGoogle();
    },
    signInWithApple: async () => {
      await firebaseAuth.signInWithApple();
    },
    signOut: async () => {
      await firebaseAuth.signOut();
    },
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
```

### Pattern 2: Biometric Authentication

```bash
npx expo install expo-local-authentication expo-secure-store
```

```typescript
// lib/biometrics.ts
import * as LocalAuthentication from 'expo-local-authentication';
import * as SecureStore from 'expo-secure-store';

export const biometrics = {
  // Check if biometrics is available
  async isAvailable(): Promise<boolean> {
    const compatible = await LocalAuthentication.hasHardwareAsync();
    const enrolled = await LocalAuthentication.isEnrolledAsync();
    return compatible && enrolled;
  },

  // Get available authentication types
  async getAuthTypes(): Promise<LocalAuthentication.AuthenticationType[]> {
    return LocalAuthentication.supportedAuthenticationTypesAsync();
  },

  // Authenticate with biometrics
  async authenticate(promptMessage = 'Authenticate to continue'): Promise<boolean> {
    const result = await LocalAuthentication.authenticateAsync({
      promptMessage,
      cancelLabel: 'Cancel',
      disableDeviceFallback: false, // Allow PIN fallback
      fallbackLabel: 'Use passcode',
    });

    return result.success;
  },

  // Store credentials securely after biometric auth
  async storeCredentials(email: string, password: string): Promise<void> {
    const isAuthed = await this.authenticate('Enable biometric login');
    if (!isAuthed) throw new Error('Authentication failed');

    await SecureStore.setItemAsync('bio_email', email);
    await SecureStore.setItemAsync('bio_password', password);
    await SecureStore.setItemAsync('bio_enabled', 'true');
  },

  // Get stored credentials after biometric auth
  async getCredentials(): Promise<{ email: string; password: string } | null> {
    const enabled = await SecureStore.getItemAsync('bio_enabled');
    if (enabled !== 'true') return null;

    const isAuthed = await this.authenticate('Sign in with biometrics');
    if (!isAuthed) return null;

    const email = await SecureStore.getItemAsync('bio_email');
    const password = await SecureStore.getItemAsync('bio_password');

    if (!email || !password) return null;
    return { email, password };
  },

  // Check if biometric login is enabled
  async isEnabled(): Promise<boolean> {
    const enabled = await SecureStore.getItemAsync('bio_enabled');
    return enabled === 'true';
  },

  // Disable biometric login
  async disable(): Promise<void> {
    await SecureStore.deleteItemAsync('bio_email');
    await SecureStore.deleteItemAsync('bio_password');
    await SecureStore.deleteItemAsync('bio_enabled');
  },
};

// components/BiometricLogin.tsx
import { useEffect, useState } from 'react';
import { View, Text, Pressable, Alert } from 'react-native';
import { Fingerprint, FaceId } from 'lucide-react-native';
import { biometrics } from '@/lib/biometrics';
import { useAuth } from '@/providers/AuthProvider';
import * as LocalAuthentication from 'expo-local-authentication';

export function BiometricLogin() {
  const { signIn } = useAuth();
  const [available, setAvailable] = useState(false);
  const [enabled, setEnabled] = useState(false);
  const [authType, setAuthType] = useState<'face' | 'fingerprint' | null>(null);

  useEffect(() => {
    checkBiometrics();
  }, []);

  const checkBiometrics = async () => {
    const isAvailable = await biometrics.isAvailable();
    setAvailable(isAvailable);

    if (isAvailable) {
      const isEnabled = await biometrics.isEnabled();
      setEnabled(isEnabled);

      const types = await biometrics.getAuthTypes();
      if (types.includes(LocalAuthentication.AuthenticationType.FACIAL_RECOGNITION)) {
        setAuthType('face');
      } else if (types.includes(LocalAuthentication.AuthenticationType.FINGERPRINT)) {
        setAuthType('fingerprint');
      }
    }
  };

  const handleBiometricLogin = async () => {
    try {
      const credentials = await biometrics.getCredentials();
      if (credentials) {
        await signIn(credentials.email, credentials.password);
      }
    } catch (error) {
      Alert.alert('Error', 'Biometric login failed');
    }
  };

  if (!available || !enabled) return null;

  const Icon = authType === 'face' ? FaceId : Fingerprint;
  const label = authType === 'face' ? 'Face ID' : 'Fingerprint';

  return (
    <View className="items-center mt-6">
      <Text className="text-muted-foreground mb-4">Or sign in with</Text>
      <Pressable
        onPress={handleBiometricLogin}
        className="flex-row items-center bg-secondary px-6 py-3 rounded-xl"
      >
        <Icon size={24} color="#0F172A" />
        <Text className="ml-2 font-semibold text-secondary-foreground">
          {label}
        </Text>
      </Pressable>
    </View>
  );
}

// Settings screen toggle
export function BiometricSettings() {
  const [available, setAvailable] = useState(false);
  const [enabled, setEnabled] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    checkStatus();
  }, []);

  const checkStatus = async () => {
    const isAvailable = await biometrics.isAvailable();
    setAvailable(isAvailable);
    if (isAvailable) {
      const isEnabled = await biometrics.isEnabled();
      setEnabled(isEnabled);
    }
  };

  const toggleBiometric = async () => {
    setLoading(true);
    try {
      if (enabled) {
        await biometrics.disable();
        setEnabled(false);
      } else {
        // User needs to re-enter credentials to enable
        // This would typically show a modal to collect email/password
        Alert.alert(
          'Enable Biometric Login',
          'Please enter your credentials to enable biometric login'
        );
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to update biometric settings');
    } finally {
      setLoading(false);
    }
  };

  if (!available) return null;

  return (
    <View className="flex-row justify-between items-center py-4 px-4 border-b border-border">
      <Text className="text-foreground">Biometric Login</Text>
      <Switch
        value={enabled}
        onValueChange={toggleBiometric}
        disabled={loading}
      />
    </View>
  );
}
```

### Pattern 3: Supabase Authentication

```bash
npx expo install @supabase/supabase-js expo-secure-store
```

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

// Secure storage adapter for Supabase
const ExpoSecureStoreAdapter = {
  getItem: async (key: string) => {
    if (Platform.OS === 'web') {
      return localStorage.getItem(key);
    }
    return SecureStore.getItemAsync(key);
  },
  setItem: async (key: string, value: string) => {
    if (Platform.OS === 'web') {
      localStorage.setItem(key, value);
      return;
    }
    await SecureStore.setItemAsync(key, value);
  },
  removeItem: async (key: string) => {
    if (Platform.OS === 'web') {
      localStorage.removeItem(key);
      return;
    }
    await SecureStore.deleteItemAsync(key);
  },
};

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: ExpoSecureStoreAdapter,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

// Auth functions
export const supabaseAuth = {
  async signUp(email: string, password: string) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });
    if (error) throw error;
    return data;
  },

  async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    return data;
  },

  async signInWithOAuth(provider: 'google' | 'apple' | 'github') {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: 'myapp://auth/callback',
      },
    });
    if (error) throw error;
    return data;
  },

  async signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  async getSession() {
    const { data: { session }, error } = await supabase.auth.getSession();
    if (error) throw error;
    return session;
  },

  async getUser() {
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error) throw error;
    return user;
  },

  async resetPassword(email: string) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: 'myapp://auth/reset-password',
    });
    if (error) throw error;
  },

  onAuthStateChange(callback: (event: string, session: any) => void) {
    return supabase.auth.onAuthStateChange(callback);
  },
};
```

### Pattern 4: Token Refresh & Session Management

```typescript
// lib/api.ts
import { useAuthStore } from '@/stores/useAuthStore';
import * as SecureStore from 'expo-secure-store';

const BASE_URL = process.env.EXPO_PUBLIC_API_URL;

async function refreshToken(): Promise<string | null> {
  const refreshToken = await SecureStore.getItemAsync('refresh_token');
  if (!refreshToken) return null;

  try {
    const response = await fetch(`${BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });

    if (!response.ok) {
      // Refresh token expired - logout
      useAuthStore.getState().logout();
      return null;
    }

    const data = await response.json();

    // Store new tokens
    await SecureStore.setItemAsync('access_token', data.accessToken);
    await SecureStore.setItemAsync('refresh_token', data.refreshToken);

    return data.accessToken;
  } catch (error) {
    useAuthStore.getState().logout();
    return null;
  }
}

export async function apiClient(
  endpoint: string,
  options: RequestInit = {}
): Promise<any> {
  let accessToken = await SecureStore.getItemAsync('access_token');

  const makeRequest = async (token: string | null) => {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    return fetch(`${BASE_URL}${endpoint}`, {
      ...options,
      headers,
    });
  };

  let response = await makeRequest(accessToken);

  // Handle 401 - try refresh
  if (response.status === 401) {
    accessToken = await refreshToken();
    if (accessToken) {
      response = await makeRequest(accessToken);
    }
  }

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'API request failed');
  }

  return response.json();
}

// hooks/useApiClient.ts
import { useCallback } from 'react';
import { apiClient } from '@/lib/api';

export function useApiClient() {
  const get = useCallback((endpoint: string) => {
    return apiClient(endpoint, { method: 'GET' });
  }, []);

  const post = useCallback((endpoint: string, data: any) => {
    return apiClient(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }, []);

  const put = useCallback((endpoint: string, data: any) => {
    return apiClient(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }, []);

  const del = useCallback((endpoint: string) => {
    return apiClient(endpoint, { method: 'DELETE' });
  }, []);

  return { get, post, put, del };
}
```

### Pattern 5: Social Login UI

```tsx
// components/SocialLoginButtons.tsx
import { View, Text, Pressable, Platform, Alert } from 'react-native';
import { useAuth } from '@/providers/AuthProvider';

export function SocialLoginButtons() {
  const { signInWithGoogle, signInWithApple } = useAuth();

  const handleGoogleLogin = async () => {
    try {
      await signInWithGoogle();
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Google sign in failed');
    }
  };

  const handleAppleLogin = async () => {
    try {
      await signInWithApple();
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Apple sign in failed');
    }
  };

  return (
    <View className="mt-6">
      <View className="flex-row items-center mb-6">
        <View className="flex-1 h-px bg-border" />
        <Text className="mx-4 text-muted-foreground">Or continue with</Text>
        <View className="flex-1 h-px bg-border" />
      </View>

      <View className="flex-row gap-4">
        <Pressable
          onPress={handleGoogleLogin}
          className="flex-1 flex-row items-center justify-center bg-white border border-border py-3 rounded-xl"
        >
          <GoogleIcon size={20} />
          <Text className="ml-2 font-medium text-foreground">Google</Text>
        </Pressable>

        {Platform.OS === 'ios' && (
          <Pressable
            onPress={handleAppleLogin}
            className="flex-1 flex-row items-center justify-center bg-black py-3 rounded-xl"
          >
            <AppleIcon size={20} color="#FFFFFF" />
            <Text className="ml-2 font-medium text-white">Apple</Text>
          </Pressable>
        )}
      </View>
    </View>
  );
}

// Complete Login Screen
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
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      className="flex-1 bg-background"
    >
      <ScrollView
        contentContainerStyle={{ flexGrow: 1, justifyContent: 'center' }}
        className="p-6"
      >
        <Text className="text-3xl font-bold text-foreground mb-2">
          Welcome back
        </Text>
        <Text className="text-muted-foreground mb-8">
          Sign in to your account to continue
        </Text>

        <View className="mb-4">
          <Text className="text-foreground mb-2 font-medium">Email</Text>
          <TextInput
            className="bg-muted px-4 py-3 rounded-xl text-foreground"
            placeholder="your@email.com"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
        </View>

        <View className="mb-6">
          <Text className="text-foreground mb-2 font-medium">Password</Text>
          <TextInput
            className="bg-muted px-4 py-3 rounded-xl text-foreground"
            placeholder="Enter your password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
          />
        </View>

        <Link href="/(auth)/forgot-password" asChild>
          <Pressable className="mb-6">
            <Text className="text-primary text-right">Forgot password?</Text>
          </Pressable>
        </Link>

        <Pressable
          onPress={handleLogin}
          disabled={loading}
          className={`py-4 rounded-xl items-center ${
            loading ? 'bg-primary/50' : 'bg-primary'
          }`}
        >
          <Text className="text-primary-foreground font-semibold">
            {loading ? 'Signing in...' : 'Sign In'}
          </Text>
        </Pressable>

        <SocialLoginButtons />

        <BiometricLogin />

        <View className="flex-row justify-center mt-8">
          <Text className="text-muted-foreground">Don't have an account? </Text>
          <Link href="/(auth)/register" asChild>
            <Pressable>
              <Text className="text-primary font-semibold">Sign Up</Text>
            </Pressable>
          </Link>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
```

---

## React Native CLI Patterns

The following patterns are for **bare React Native** projects without Expo.

### CLI Pattern 1: Biometric Auth with react-native-biometrics

```bash
npm install react-native-biometrics
npm install react-native-keychain
cd ios && pod install
```

```typescript
// lib/biometrics.ts
import ReactNativeBiometrics, { BiometryTypes } from 'react-native-biometrics';
import * as Keychain from 'react-native-keychain';

const rnBiometrics = new ReactNativeBiometrics({ allowDeviceCredentials: true });

export const biometrics = {
  // Check if biometrics is available
  async isAvailable(): Promise<{ available: boolean; biometryType: string | null }> {
    const { available, biometryType } = await rnBiometrics.isSensorAvailable();

    return {
      available,
      biometryType: biometryType === BiometryTypes.FaceID
        ? 'FaceID'
        : biometryType === BiometryTypes.TouchID
        ? 'TouchID'
        : biometryType === BiometryTypes.Biometrics
        ? 'Fingerprint'
        : null,
    };
  },

  // Authenticate with biometrics
  async authenticate(promptMessage = 'Authenticate to continue'): Promise<boolean> {
    try {
      const { success } = await rnBiometrics.simplePrompt({
        promptMessage,
        cancelButtonText: 'Cancel',
      });

      return success;
    } catch (error) {
      console.error('Biometric auth error:', error);
      return false;
    }
  },

  // Create biometric keys for signing
  async createKeys(): Promise<string | null> {
    try {
      const { publicKey } = await rnBiometrics.createKeys();
      return publicKey;
    } catch (error) {
      console.error('Create keys error:', error);
      return null;
    }
  },

  // Sign a payload with biometric
  async signPayload(payload: string): Promise<string | null> {
    try {
      const { success, signature } = await rnBiometrics.createSignature({
        promptMessage: 'Sign in',
        payload,
      });

      return success ? signature : null;
    } catch (error) {
      console.error('Sign payload error:', error);
      return null;
    }
  },

  // Delete biometric keys
  async deleteKeys(): Promise<boolean> {
    try {
      const { keysDeleted } = await rnBiometrics.deleteKeys();
      return keysDeleted;
    } catch (error) {
      console.error('Delete keys error:', error);
      return false;
    }
  },
};

// Secure storage with Keychain
export const secureStorage = {
  async setCredentials(username: string, password: string): Promise<boolean> {
    try {
      await Keychain.setGenericPassword(username, password, {
        accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
      });
      return true;
    } catch (error) {
      console.error('Set credentials error:', error);
      return false;
    }
  },

  async getCredentials(): Promise<{ username: string; password: string } | null> {
    try {
      const credentials = await Keychain.getGenericPassword();
      if (credentials) {
        return {
          username: credentials.username,
          password: credentials.password,
        };
      }
      return null;
    } catch (error) {
      console.error('Get credentials error:', error);
      return null;
    }
  },

  async clearCredentials(): Promise<boolean> {
    try {
      await Keychain.resetGenericPassword();
      return true;
    } catch (error) {
      console.error('Clear credentials error:', error);
      return false;
    }
  },

  // Store with biometric protection
  async setSecureItem(
    key: string,
    value: string,
    requireBiometric = true
  ): Promise<boolean> {
    try {
      await Keychain.setGenericPassword(key, value, {
        service: key,
        accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
        accessControl: requireBiometric
          ? Keychain.ACCESS_CONTROL.BIOMETRY_CURRENT_SET_OR_DEVICE_PASSCODE
          : undefined,
      });
      return true;
    } catch (error) {
      console.error('Set secure item error:', error);
      return false;
    }
  },

  async getSecureItem(key: string): Promise<string | null> {
    try {
      const result = await Keychain.getGenericPassword({ service: key });
      return result ? result.password : null;
    } catch (error) {
      console.error('Get secure item error:', error);
      return null;
    }
  },

  async deleteSecureItem(key: string): Promise<boolean> {
    try {
      await Keychain.resetGenericPassword({ service: key });
      return true;
    } catch (error) {
      console.error('Delete secure item error:', error);
      return false;
    }
  },
};
```

### CLI Pattern 2: Firebase Auth (Non-Expo)

```bash
npm install @react-native-firebase/app @react-native-firebase/auth
npm install @react-native-google-signin/google-signin
npm install @invertase/react-native-apple-authentication
cd ios && pod install
```

```typescript
// lib/firebase.ts
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { appleAuth } from '@invertase/react-native-apple-authentication';
import { secureStorage } from './biometrics';

// Configure Google Sign-In
GoogleSignin.configure({
  webClientId: 'YOUR_WEB_CLIENT_ID', // From Firebase Console
});

export const firebaseAuth = {
  // Email/Password Sign Up
  async signUp(
    email: string,
    password: string
  ): Promise<FirebaseAuthTypes.User | null> {
    try {
      const { user } = await auth().createUserWithEmailAndPassword(email, password);
      await user.sendEmailVerification();
      return user;
    } catch (error: any) {
      throw this.handleError(error);
    }
  },

  // Email/Password Sign In
  async signIn(
    email: string,
    password: string
  ): Promise<FirebaseAuthTypes.User | null> {
    try {
      const { user } = await auth().signInWithEmailAndPassword(email, password);

      // Store token securely
      const token = await user.getIdToken();
      await secureStorage.setSecureItem('auth_token', token, false);

      return user;
    } catch (error: any) {
      throw this.handleError(error);
    }
  },

  // Google Sign In
  async signInWithGoogle(): Promise<FirebaseAuthTypes.User | null> {
    try {
      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      const { idToken } = await GoogleSignin.signIn();

      const googleCredential = auth.GoogleAuthProvider.credential(idToken);
      const { user } = await auth().signInWithCredential(googleCredential);

      return user;
    } catch (error: any) {
      throw this.handleError(error);
    }
  },

  // Apple Sign In
  async signInWithApple(): Promise<FirebaseAuthTypes.User | null> {
    try {
      const appleAuthRequestResponse = await appleAuth.performRequest({
        requestedOperation: appleAuth.Operation.LOGIN,
        requestedScopes: [appleAuth.Scope.EMAIL, appleAuth.Scope.FULL_NAME],
      });

      const { identityToken, nonce } = appleAuthRequestResponse;

      if (!identityToken) {
        throw new Error('Apple Sign-In failed - no identity token');
      }

      const appleCredential = auth.AppleAuthProvider.credential(identityToken, nonce);
      const { user } = await auth().signInWithCredential(appleCredential);

      return user;
    } catch (error: any) {
      throw this.handleError(error);
    }
  },

  // Sign Out
  async signOut(): Promise<void> {
    try {
      // Sign out from Google if signed in
      const isGoogleSignedIn = await GoogleSignin.isSignedIn();
      if (isGoogleSignedIn) {
        await GoogleSignin.signOut();
      }

      // Sign out from Firebase
      await auth().signOut();

      // Clear secure storage
      await secureStorage.deleteSecureItem('auth_token');
    } catch (error: any) {
      throw this.handleError(error);
    }
  },

  // Password Reset
  async sendPasswordResetEmail(email: string): Promise<void> {
    try {
      await auth().sendPasswordResetEmail(email);
    } catch (error: any) {
      throw this.handleError(error);
    }
  },

  // Get current user
  getCurrentUser(): FirebaseAuthTypes.User | null {
    return auth().currentUser;
  },

  // Get ID token
  async getIdToken(): Promise<string | null> {
    const user = auth().currentUser;
    if (!user) return null;
    return user.getIdToken();
  },

  // Auth state listener
  onAuthStateChanged(
    callback: (user: FirebaseAuthTypes.User | null) => void
  ): () => void {
    return auth().onAuthStateChanged(callback);
  },

  // Error handler
  handleError(error: any): Error {
    let message = 'An error occurred';

    switch (error.code) {
      case 'auth/email-already-in-use':
        message = 'This email is already registered';
        break;
      case 'auth/invalid-email':
        message = 'Invalid email address';
        break;
      case 'auth/weak-password':
        message = 'Password is too weak';
        break;
      case 'auth/user-not-found':
        message = 'No account found with this email';
        break;
      case 'auth/wrong-password':
        message = 'Incorrect password';
        break;
      case 'auth/too-many-requests':
        message = 'Too many attempts. Please try again later';
        break;
      case 'auth/network-request-failed':
        message = 'Network error. Please check your connection';
        break;
      default:
        message = error.message || message;
    }

    return new Error(message);
  },
};
```

### CLI Pattern 3: Auth Provider with React Navigation

```tsx
// providers/AuthProvider.tsx
import React, { createContext, useContext, useEffect, useState } from 'react';
import { FirebaseAuthTypes } from '@react-native-firebase/auth';
import { firebaseAuth } from '@/lib/firebase';
import { biometrics, secureStorage } from '@/lib/biometrics';

interface AuthContextType {
  user: FirebaseAuthTypes.User | null;
  isLoading: boolean;
  biometricEnabled: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string) => Promise<void>;
  signInWithGoogle: () => Promise<void>;
  signInWithApple: () => Promise<void>;
  signInWithBiometric: () => Promise<void>;
  signOut: () => Promise<void>;
  enableBiometric: (email: string, password: string) => Promise<void>;
  disableBiometric: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<FirebaseAuthTypes.User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [biometricEnabled, setBiometricEnabled] = useState(false);

  useEffect(() => {
    // Check if biometric is enabled
    checkBiometricStatus();

    // Listen for auth state changes
    const unsubscribe = firebaseAuth.onAuthStateChanged((user) => {
      setUser(user);
      setIsLoading(false);
    });

    return unsubscribe;
  }, []);

  const checkBiometricStatus = async () => {
    const enabled = await secureStorage.getSecureItem('biometric_enabled');
    setBiometricEnabled(enabled === 'true');
  };

  const signIn = async (email: string, password: string) => {
    await firebaseAuth.signIn(email, password);
  };

  const signUp = async (email: string, password: string) => {
    await firebaseAuth.signUp(email, password);
  };

  const signInWithGoogle = async () => {
    await firebaseAuth.signInWithGoogle();
  };

  const signInWithApple = async () => {
    await firebaseAuth.signInWithApple();
  };

  const signInWithBiometric = async () => {
    const { available } = await biometrics.isAvailable();
    if (!available) {
      throw new Error('Biometric not available');
    }

    const authenticated = await biometrics.authenticate('Sign in');
    if (!authenticated) {
      throw new Error('Biometric authentication failed');
    }

    const email = await secureStorage.getSecureItem('bio_email');
    const password = await secureStorage.getSecureItem('bio_password');

    if (!email || !password) {
      throw new Error('No stored credentials');
    }

    await firebaseAuth.signIn(email, password);
  };

  const signOut = async () => {
    await firebaseAuth.signOut();
  };

  const enableBiometric = async (email: string, password: string) => {
    const { available } = await biometrics.isAvailable();
    if (!available) {
      throw new Error('Biometric not available on this device');
    }

    // Verify credentials first
    await firebaseAuth.signIn(email, password);

    // Store credentials securely
    await secureStorage.setSecureItem('bio_email', email);
    await secureStorage.setSecureItem('bio_password', password);
    await secureStorage.setSecureItem('biometric_enabled', 'true');

    setBiometricEnabled(true);
  };

  const disableBiometric = async () => {
    await secureStorage.deleteSecureItem('bio_email');
    await secureStorage.deleteSecureItem('bio_password');
    await secureStorage.deleteSecureItem('biometric_enabled');
    setBiometricEnabled(false);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        biometricEnabled,
        signIn,
        signUp,
        signInWithGoogle,
        signInWithApple,
        signInWithBiometric,
        signOut,
        enableBiometric,
        disableBiometric,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
```

### CLI Pattern 4: Navigation Auth Flow (React Navigation)

```tsx
// navigation/index.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAuth } from '@/providers/AuthProvider';
import { ActivityIndicator, View } from 'react-native';

// Screens
import LoginScreen from '@/screens/auth/LoginScreen';
import RegisterScreen from '@/screens/auth/RegisterScreen';
import ForgotPasswordScreen from '@/screens/auth/ForgotPasswordScreen';
import MainTabNavigator from './MainTabNavigator';

export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
};

export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
};

const RootStack = createNativeStackNavigator<RootStackParamList>();
const AuthStack = createNativeStackNavigator<AuthStackParamList>();

function AuthNavigator() {
  return (
    <AuthStack.Navigator screenOptions={{ headerShown: false }}>
      <AuthStack.Screen name="Login" component={LoginScreen} />
      <AuthStack.Screen name="Register" component={RegisterScreen} />
      <AuthStack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
    </AuthStack.Navigator>
  );
}

export default function Navigation() {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <RootStack.Navigator screenOptions={{ headerShown: false }}>
        {user ? (
          <RootStack.Screen name="Main" component={MainTabNavigator} />
        ) : (
          <RootStack.Screen name="Auth" component={AuthNavigator} />
        )}
      </RootStack.Navigator>
    </NavigationContainer>
  );
}
```

---

## Best Practices

### Do's

- **Use SecureStore for tokens** - Never use AsyncStorage for auth tokens
- **Implement token refresh** - Don't let users re-login frequently
- **Enable biometrics** - Better UX than passwords
- **Support Apple Sign In** - Required for iOS apps with social login
- **Handle auth state globally** - Use context or state management

### Don'ts

- **Don't store passwords** - Only store tokens
- **Don't skip validation** - Validate on both client and server
- **Don't ignore errors** - Show meaningful error messages
- **Don't forget logout cleanup** - Clear all secure storage
- **Don't skip HTTPS** - Always use secure connections

## Resources

- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Expo Local Authentication](https://docs.expo.dev/versions/latest/sdk/local-authentication/)
- [Expo SecureStore](https://docs.expo.dev/versions/latest/sdk/securestore/)
