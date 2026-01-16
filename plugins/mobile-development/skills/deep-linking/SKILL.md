---
name: deep-linking
description: Implement Universal Links (iOS) and App Links (Android) for seamless web-to-app transitions. Covers Expo Router deep linking, custom URL schemes, deferred deep links, and branch.io integration.
---

# Deep Linking for React Native

## Overview

Deep linking enables:
- Opening specific screens from URLs
- Web-to-app seamless transitions
- Marketing campaign tracking
- Social sharing with app previews
- Referral programs

---

## Types of Deep Links

| Type | Platform | Example | Fallback |
|------|----------|---------|----------|
| **URL Scheme** | Both | `myapp://profile/123` | None (app must be installed) |
| **Universal Links** | iOS | `https://myapp.com/profile/123` | Opens in Safari |
| **App Links** | Android | `https://myapp.com/profile/123` | Opens in browser |
| **Deferred** | Both | Works even if app not installed | Store → App → Screen |

---

## Expo Router Deep Linking

### Basic Setup

```typescript
// app.config.ts
export default {
  expo: {
    scheme: 'myapp',
    web: {
      bundler: 'metro',
    },
    // For Universal/App Links
    extra: {
      eas: {
        projectId: 'your-project-id',
      },
    },
  },
};
```

### File-Based Routes

```
app/
├── (tabs)/
│   ├── index.tsx           → myapp://
│   ├── profile/
│   │   ├── index.tsx       → myapp://profile
│   │   └── [id].tsx        → myapp://profile/123
│   └── settings.tsx        → myapp://settings
├── product/
│   └── [id].tsx            → myapp://product/abc
└── _layout.tsx
```

### Dynamic Route with Params

```tsx
// app/product/[id].tsx
import { useLocalSearchParams } from 'expo-router';

export default function ProductScreen() {
  const { id, ref, campaign } = useLocalSearchParams<{
    id: string;
    ref?: string;
    campaign?: string;
  }>();

  // URL: myapp://product/123?ref=email&campaign=summer2024
  // id = "123", ref = "email", campaign = "summer2024"

  useEffect(() => {
    if (campaign) {
      analytics.track('deep_link_opened', { campaign, ref });
    }
  }, [campaign, ref]);

  return <ProductDetail productId={id} />;
}
```

### Handling Deep Links in Root Layout

```tsx
// app/_layout.tsx
import { useEffect } from 'react';
import { Linking } from 'react-native';
import { useRouter, useSegments } from 'expo-router';

export default function RootLayout() {
  const router = useRouter();

  useEffect(() => {
    // Handle deep link when app is already open
    const subscription = Linking.addEventListener('url', ({ url }) => {
      handleDeepLink(url);
    });

    // Handle deep link that opened the app
    Linking.getInitialURL().then((url) => {
      if (url) handleDeepLink(url);
    });

    return () => subscription.remove();
  }, []);

  const handleDeepLink = (url: string) => {
    console.log('Deep link received:', url);
    // Custom handling if needed
    // Expo Router handles most navigation automatically
  };

  return <Stack />;
}
```

---

## Universal Links (iOS)

### Apple App Site Association (AASA)

Host at `https://yourdomain.com/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appIDs": ["TEAM_ID.com.yourcompany.yourapp"],
        "components": [
          {
            "/": "/product/*",
            "comment": "Product pages"
          },
          {
            "/": "/profile/*",
            "comment": "User profiles"
          },
          {
            "/": "/invite/*",
            "comment": "Invitation links"
          }
        ]
      }
    ]
  }
}
```

### Expo Configuration

```typescript
// app.config.ts
export default {
  expo: {
    ios: {
      bundleIdentifier: 'com.yourcompany.yourapp',
      associatedDomains: [
        'applinks:yourdomain.com',
        'applinks:www.yourdomain.com',
      ],
    },
  },
};
```

### Validation

```bash
# Test AASA file
curl -I https://yourdomain.com/.well-known/apple-app-site-association

# Apple's validation tool
https://search.developer.apple.com/appsearch-validation-tool/
```

---

## App Links (Android)

### Digital Asset Links

Host at `https://yourdomain.com/.well-known/assetlinks.json`:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.yourcompany.yourapp",
      "sha256_cert_fingerprints": [
        "YOUR_SHA256_FINGERPRINT"
      ]
    }
  }
]
```

### Get SHA256 Fingerprint

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android

# EAS Build (production)
eas credentials --platform android
```

### Expo Configuration

```typescript
// app.config.ts
export default {
  expo: {
    android: {
      package: 'com.yourcompany.yourapp',
      intentFilters: [
        {
          action: 'VIEW',
          autoVerify: true,
          data: [
            {
              scheme: 'https',
              host: 'yourdomain.com',
              pathPrefix: '/product',
            },
            {
              scheme: 'https',
              host: 'yourdomain.com',
              pathPrefix: '/profile',
            },
          ],
          category: ['BROWSABLE', 'DEFAULT'],
        },
      ],
    },
  },
};
```

---

## Custom URL Scheme

### Configuration

```typescript
// app.config.ts
export default {
  expo: {
    scheme: 'myapp', // myapp://
    // Multiple schemes
    // scheme: ['myapp', 'myapp-dev'],
  },
};
```

### Usage Examples

```typescript
// Open product
Linking.openURL('myapp://product/123');

// Open with params
Linking.openURL('myapp://profile/456?tab=posts');

// Open settings
Linking.openURL('myapp://settings');
```

---

## Deferred Deep Links

For users who don't have the app installed yet.

### With Expo Linking

```tsx
// After app install, check for deferred link
import * as Linking from 'expo-linking';

async function checkDeferredDeepLink() {
  const initialUrl = await Linking.getInitialURL();

  if (initialUrl) {
    // User came from a link
    const { path, queryParams } = Linking.parse(initialUrl);

    if (queryParams?.ref) {
      // Track referral
      await analytics.track('referral_completed', {
        referrer: queryParams.ref,
      });
    }

    // Navigate to intended screen
    router.push(path as any);
  }
}
```

### With Branch.io

```bash
npx expo install react-native-branch
```

```typescript
// app/_layout.tsx
import branch from 'react-native-branch';

export default function RootLayout() {
  useEffect(() => {
    branch.subscribe(({ error, params }) => {
      if (error) {
        console.error('Branch error:', error);
        return;
      }

      if (params['+clicked_branch_link']) {
        // User came from Branch link
        const { product_id, campaign, $deeplink_path } = params;

        if ($deeplink_path) {
          router.push($deeplink_path);
        }

        analytics.track('branch_link_opened', { product_id, campaign });
      }
    });
  }, []);

  return <Stack />;
}
```

---

## Testing Deep Links

### iOS Simulator

```bash
# URL scheme
xcrun simctl openurl booted "myapp://product/123"

# Universal Link
xcrun simctl openurl booted "https://yourdomain.com/product/123"
```

### Android Emulator

```bash
# URL scheme
adb shell am start -a android.intent.action.VIEW -d "myapp://product/123"

# App Link
adb shell am start -a android.intent.action.VIEW -d "https://yourdomain.com/product/123"
```

### Expo Go

```bash
# Use exp:// scheme
npx uri-scheme open "exp://127.0.0.1:8081/--/product/123" --ios
```

### Debug Utility

```tsx
// components/DeepLinkDebugger.tsx (dev only)
import { useState, useEffect } from 'react';
import { Linking, View, Text } from 'react-native';

export function DeepLinkDebugger() {
  const [lastUrl, setLastUrl] = useState<string | null>(null);

  useEffect(() => {
    Linking.getInitialURL().then(setLastUrl);

    const sub = Linking.addEventListener('url', ({ url }) => {
      setLastUrl(url);
    });

    return () => sub.remove();
  }, []);

  if (!__DEV__) return null;

  return (
    <View style={{ padding: 10, backgroundColor: '#ffeb3b' }}>
      <Text>Last Deep Link: {lastUrl || 'None'}</Text>
    </View>
  );
}
```

---

## Common Patterns

### Auth Callback

```tsx
// app/auth/callback.tsx
import { useLocalSearchParams, useRouter } from 'expo-router';

export default function AuthCallback() {
  const { token, provider } = useLocalSearchParams();
  const router = useRouter();

  useEffect(() => {
    if (token) {
      // Exchange token for session
      handleAuthCallback(token as string, provider as string)
        .then(() => router.replace('/'))
        .catch(() => router.replace('/auth/error'));
    }
  }, [token]);

  return <LoadingScreen />;
}
```

### Share Link Generation

```typescript
// lib/share.ts
import * as Linking from 'expo-linking';
import { Share } from 'react-native';

export function generateShareLink(type: string, id: string) {
  // Use Universal Link for sharing (works whether app installed or not)
  return `https://yourdomain.com/${type}/${id}`;
}

export async function shareContent(title: string, type: string, id: string) {
  const url = generateShareLink(type, id);

  await Share.share({
    title,
    message: `Check out ${title}`,
    url, // iOS only, Android includes in message
  });
}

// Usage
shareContent('Cool Product', 'product', '123');
```

### Marketing Campaign Tracking

```tsx
// hooks/useDeepLinkTracking.ts
import { useLocalSearchParams } from 'expo-router';
import { useEffect } from 'react';

export function useDeepLinkTracking() {
  const params = useLocalSearchParams<{
    utm_source?: string;
    utm_medium?: string;
    utm_campaign?: string;
    ref?: string;
  }>();

  useEffect(() => {
    if (params.utm_campaign || params.ref) {
      analytics.track('campaign_opened', {
        source: params.utm_source,
        medium: params.utm_medium,
        campaign: params.utm_campaign,
        referrer: params.ref,
      });
    }
  }, [params]);
}
```

---

## Checklist

### Setup
- [ ] URL scheme configured in app.config.ts
- [ ] Universal Links AASA file hosted
- [ ] App Links assetlinks.json hosted
- [ ] Associated domains configured (iOS)
- [ ] Intent filters configured (Android)

### Testing
- [ ] URL scheme works on iOS
- [ ] URL scheme works on Android
- [ ] Universal Links work on iOS
- [ ] App Links work on Android
- [ ] Deferred deep links work
- [ ] Fallback to web works

### Tracking
- [ ] Deep link opens tracked in analytics
- [ ] UTM parameters captured
- [ ] Referral codes processed
- [ ] Conversions attributed

---

## React Native CLI Patterns

The following patterns are for **bare React Native** projects using React Navigation.

### CLI Pattern 1: React Navigation Linking Configuration

```typescript
// navigation/linking.ts
import { LinkingOptions } from '@react-navigation/native';
import { RootStackParamList } from './types';

export const linking: LinkingOptions<RootStackParamList> = {
  prefixes: [
    'myapp://',
    'https://myapp.com',
    'https://www.myapp.com',
  ],

  config: {
    screens: {
      // Tab Navigator
      Main: {
        screens: {
          Home: 'home',
          Search: 'search',
          Profile: {
            path: 'profile/:userId?',
            parse: {
              userId: (userId: string) => userId,
            },
          },
        },
      },

      // Stack screens
      ProductDetail: {
        path: 'product/:id',
        parse: {
          id: (id: string) => id,
        },
      },

      Settings: 'settings',

      // Nested stack
      SettingsStack: {
        screens: {
          SettingsHome: 'settings',
          Notifications: 'settings/notifications',
          Privacy: 'settings/privacy',
        },
      },

      // Auth flow
      Auth: {
        screens: {
          Login: 'login',
          Register: 'register',
          ForgotPassword: 'forgot-password',
          ResetPassword: {
            path: 'reset-password/:token',
            parse: {
              token: (token: string) => token,
            },
          },
        },
      },

      // Auth callback (OAuth)
      AuthCallback: {
        path: 'auth/callback',
        parse: {
          code: (code: string) => code,
          state: (state: string) => state,
        },
      },

      // Not found
      NotFound: '*',
    },
  },

  // Custom URL parsing
  getStateFromPath: (path, options) => {
    // Handle UTM parameters
    const url = new URL(path, 'https://myapp.com');
    const utmParams = {
      utm_source: url.searchParams.get('utm_source'),
      utm_medium: url.searchParams.get('utm_medium'),
      utm_campaign: url.searchParams.get('utm_campaign'),
    };

    if (utmParams.utm_campaign) {
      // Track campaign
      analytics.track('deep_link_campaign', utmParams);
    }

    // Use default parsing
    return options.getStateFromPath?.(path, options);
  },
};
```

### CLI Pattern 2: Navigation Container Setup

```tsx
// navigation/index.tsx
import React, { useEffect, useRef } from 'react';
import {
  NavigationContainer,
  NavigationContainerRef,
} from '@react-navigation/native';
import { Linking } from 'react-native';
import { linking } from './linking';
import { RootStackParamList } from './types';

export default function Navigation() {
  const navigationRef = useRef<NavigationContainerRef<RootStackParamList>>(null);

  useEffect(() => {
    // Handle deep link when app is already open
    const subscription = Linking.addEventListener('url', ({ url }) => {
      handleDeepLink(url);
    });

    // Handle deep link that opened the app
    Linking.getInitialURL().then((url) => {
      if (url) handleDeepLink(url);
    });

    return () => subscription.remove();
  }, []);

  const handleDeepLink = (url: string) => {
    console.log('Deep link received:', url);

    // Custom handling if needed
    // React Navigation will handle most cases automatically
  };

  return (
    <NavigationContainer
      ref={navigationRef}
      linking={linking}
      fallback={<LoadingScreen />}
      onStateChange={(state) => {
        // Track screen views
        const currentRoute = getCurrentRoute(state);
        if (currentRoute) {
          analytics.screen(currentRoute.name, currentRoute.params);
        }
      }}
    >
      <RootNavigator />
    </NavigationContainer>
  );
}

// Helper to get current route
function getCurrentRoute(state: any): { name: string; params?: any } | null {
  if (!state) return null;

  const route = state.routes[state.index];

  if (route.state) {
    return getCurrentRoute(route.state);
  }

  return { name: route.name, params: route.params };
}
```

### CLI Pattern 3: iOS Native Configuration

```xml
<!-- ios/MyApp/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>

<!-- Universal Links -->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:myapp.com</string>
  <string>applinks:www.myapp.com</string>
</array>
```

```swift
// ios/MyApp/AppDelegate.swift (or .mm)
import React
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  // Handle URL scheme
  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return RCTLinkingManager.application(app, open: url, options: options)
  }

  // Handle Universal Links
  func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return RCTLinkingManager.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }
}
```

### CLI Pattern 4: Android Native Configuration

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application>
    <activity
      android:name=".MainActivity"
      android:launchMode="singleTask">

      <!-- URL Scheme -->
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" />
      </intent-filter>

      <!-- App Links (Verified) -->
      <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
          android:scheme="https"
          android:host="myapp.com"
          android:pathPrefix="/" />
        <data
          android:scheme="https"
          android:host="www.myapp.com"
          android:pathPrefix="/" />
      </intent-filter>

    </activity>
  </application>
</manifest>
```

### CLI Pattern 5: Programmatic Navigation from Deep Links

```typescript
// hooks/useDeepLinkHandler.ts
import { useEffect } from 'react';
import { Linking } from 'react-native';
import { useNavigation, CommonActions } from '@react-navigation/native';

export function useDeepLinkHandler() {
  const navigation = useNavigation();

  useEffect(() => {
    const handleUrl = ({ url }: { url: string }) => {
      const parsed = parseDeepLink(url);

      if (!parsed) return;

      switch (parsed.type) {
        case 'product':
          navigation.navigate('ProductDetail', { id: parsed.id });
          break;

        case 'profile':
          navigation.navigate('Main', {
            screen: 'Profile',
            params: { userId: parsed.id },
          });
          break;

        case 'reset-password':
          // Navigate to auth stack
          navigation.dispatch(
            CommonActions.reset({
              index: 0,
              routes: [
                {
                  name: 'Auth',
                  state: {
                    routes: [
                      { name: 'ResetPassword', params: { token: parsed.token } },
                    ],
                  },
                },
              ],
            })
          );
          break;

        case 'share':
          // Handle share/referral links
          handleShareLink(parsed);
          break;
      }
    };

    const subscription = Linking.addEventListener('url', handleUrl);

    return () => subscription.remove();
  }, [navigation]);
}

function parseDeepLink(url: string) {
  try {
    const urlObj = new URL(url);
    const pathParts = urlObj.pathname.split('/').filter(Boolean);

    if (pathParts[0] === 'product' && pathParts[1]) {
      return { type: 'product', id: pathParts[1] };
    }

    if (pathParts[0] === 'profile' && pathParts[1]) {
      return { type: 'profile', id: pathParts[1] };
    }

    if (pathParts[0] === 'reset-password' && pathParts[1]) {
      return { type: 'reset-password', token: pathParts[1] };
    }

    if (urlObj.searchParams.has('ref')) {
      return {
        type: 'share',
        ref: urlObj.searchParams.get('ref'),
        path: urlObj.pathname,
      };
    }

    return null;
  } catch {
    return null;
  }
}
```

### CLI Pattern 6: Testing Deep Links

```bash
# iOS Simulator - URL Scheme
xcrun simctl openurl booted "myapp://product/123"

# iOS Simulator - Universal Link
xcrun simctl openurl booted "https://myapp.com/product/123"

# Android Emulator - URL Scheme
adb shell am start -a android.intent.action.VIEW -d "myapp://product/123"

# Android Emulator - App Link
adb shell am start -a android.intent.action.VIEW -d "https://myapp.com/product/123"

# Verify App Links (Android)
adb shell pm get-app-links com.myapp.app
```

---

## Troubleshooting

### Universal Links Not Working

1. **AASA not accessible**: Must be HTTPS, no redirects
2. **Wrong Team ID**: Check in Apple Developer Portal
3. **Cache issue**: Remove app, restart device, reinstall
4. **Domain not associated**: Check entitlements in Xcode

### App Links Not Working

1. **assetlinks.json not accessible**: Must be HTTPS
2. **Wrong SHA256**: Regenerate for correct keystore
3. **autoVerify not set**: Check intent filter
4. **Package name mismatch**: Must match exactly

### Debugging Tips

```typescript
// Log all incoming URLs
Linking.addEventListener('url', ({ url }) => {
  console.log('Received URL:', url);
  console.log('Parsed:', Linking.parse(url));
});
```
