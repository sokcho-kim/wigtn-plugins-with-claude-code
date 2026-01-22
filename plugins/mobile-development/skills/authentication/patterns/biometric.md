# Biometric Authentication

Face ID, Touch ID, and Fingerprint authentication for React Native.

## Installation (Expo)

```bash
npx expo install expo-local-authentication expo-secure-store
```

## Biometrics Service

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
```

## Biometric Login Component

```typescript
// components/BiometricLogin.tsx
import { useEffect, useState } from 'react';
import { View, Text, Pressable, Alert } from 'react-native';
import { Fingerprint } from 'lucide-react-native';
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

  const label = authType === 'face' ? 'Face ID' : 'Fingerprint';

  return (
    <View className="items-center mt-6">
      <Text className="text-muted-foreground mb-4">Or sign in with</Text>
      <Pressable
        onPress={handleBiometricLogin}
        className="flex-row items-center bg-secondary px-6 py-3 rounded-xl"
      >
        <Fingerprint size={24} color="#0F172A" />
        <Text className="ml-2 font-semibold text-secondary-foreground">
          {label}
        </Text>
      </Pressable>
    </View>
  );
}
```

## Settings Toggle

```typescript
// components/BiometricSettings.tsx
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
        // Show modal to collect credentials
        Alert.alert('Enable Biometric', 'Enter credentials to enable');
      }
    } finally {
      setLoading(false);
    }
  };

  if (!available) return null;

  return (
    <View className="flex-row justify-between items-center py-4">
      <Text>Biometric Login</Text>
      <Switch value={enabled} onValueChange={toggleBiometric} disabled={loading} />
    </View>
  );
}
```
