# Firebase Authentication

Complete Firebase Auth setup with social login providers.

## Installation

```bash
npx expo install @react-native-firebase/app @react-native-firebase/auth
npm install @react-native-google-signin/google-signin
npm install @invertase/react-native-apple-authentication
```

## Firebase Auth Service

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

  // Get ID token for API calls
  async getIdToken() {
    const user = auth().currentUser;
    if (!user) return null;
    return user.getIdToken();
  },
};
```

## Auth Provider

```typescript
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
