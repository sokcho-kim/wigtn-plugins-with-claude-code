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

### Auth Options

| Solution | Complexity | Best For |
|----------|------------|----------|
| **Firebase Auth** | Low | Quick setup, Google ecosystem |
| **Supabase Auth** | Low | Open source, PostgreSQL |
| **Auth0/Clerk** | Medium | Enterprise, advanced features |
| **Custom Backend** | High | Full control |

### Storage Security

```
Regular data → MMKV
Tokens → SecureStore (Keychain/Keystore)
Sensitive user data → SecureStore + encryption
```

## Quick Start

### Firebase Auth Setup

```bash
npx expo install @react-native-firebase/app @react-native-firebase/auth
```

```typescript
// lib/firebase.ts
import auth from '@react-native-firebase/auth';

export const firebaseAuth = {
  async signIn(email: string, password: string) {
    const { user } = await auth().signInWithEmailAndPassword(email, password);
    return user;
  },

  async signOut() {
    await auth().signOut();
  },

  onAuthStateChanged(callback: (user: any) => void) {
    return auth().onAuthStateChanged(callback);
  },
};
```

## Available Patterns

Load detailed patterns as needed:

| Pattern | File | Description |
|---------|------|-------------|
| Firebase Auth | `patterns/firebase.md` | Full Firebase setup with social login |
| Biometric Auth | `patterns/biometric.md` | Face ID, Touch ID, Fingerprint |
| Supabase Auth | `patterns/supabase.md` | Supabase with secure storage |
| Token Refresh | `patterns/token-refresh.md` | Auto token refresh and session management |
| Social Login UI | `patterns/social-login.md` | Google, Apple, Facebook buttons |
| React Native CLI | `patterns/cli-auth.md` | Non-Expo biometric and Firebase |
| Auth Provider | `patterns/auth-provider.md` | Context-based auth state |
| Navigation Flow | `patterns/navigation.md` | React Navigation auth flow |

## References

- `common/security.md` - Mobile security best practices
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Expo Local Authentication](https://docs.expo.dev/versions/latest/sdk/local-authentication/)
