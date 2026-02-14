# Social Login UI

Google, Apple, and Facebook login button components.

## Social Login Buttons

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
```

## Complete Login Screen

```tsx
// screens/LoginScreen.tsx
import { useState } from 'react';
import {
  View, Text, TextInput, Pressable, Alert,
  KeyboardAvoidingView, ScrollView, Platform
} from 'react-native';
import { Link } from 'expo-router';
import { useAuth } from '@/providers/AuthProvider';
import { SocialLoginButtons } from '@/components/SocialLoginButtons';
import { BiometricLogin } from '@/components/BiometricLogin';

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
          Sign in to your account
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
