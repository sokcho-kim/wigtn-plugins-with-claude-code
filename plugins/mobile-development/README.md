# Mobile Development Plugin

Complete mobile development solution for Claude Code. Build production-ready React Native applications with Expo and React Native CLI.

## Features

### Agents (2)

| Agent | Description | Usage |
|-------|-------------|-------|
| `mobile-developer` | Full-stack mobile expert with RN CLI & Expo | Auto-invoked for mobile tasks |
| `mobile-design-discovery` | VS-based design direction with iOS HIG & Material Design | Auto-invoked for mobile design tasks |

### Skills (11)

Invoke with `/skill-name` or let Claude use them automatically.

| Category | Skill | Description |
|----------|-------|-------------|
| **Design** | `/mobile-design` | iOS HIG, Material Design 3, mobile patterns |
| **Styling** | `/rn-styling` | StyleSheet + react-native-size-matters, dark mode |
| **Navigation** | `/navigation` | Expo Router, React Navigation, deep linking |
| **State** | `/mobile-state-management` | Zustand + MMKV, React Query, offline support |
| **Auth** | `/mobile-authentication` | Biometrics, Firebase, Supabase, secure storage |
| **Native** | `/native-modules` | Camera, notifications, location, file system |
| **Testing** | `/mobile-testing` | Jest, RNTL, Detox, Maestro |
| **Performance** | `/mobile-performance` | FlatList, images, memory, startup time |
| **Responsive** | `/responsive-design` | Multi-device layouts, tablets, scaling |
| **Deep Links** | `/deep-linking` | Universal Links, App Links, deferred deep links |
| **ASO** | `/app-store-optimization` | Store metadata, screenshots, ratings, A/B testing |

### Commands (2)

| Command | Description |
|---------|-------------|
| `/component-scaffold` | Generate complete RN component with types, tests |
| `/add-feature` | Add new feature with proper architecture |

## Quick Start

### Installation

Add to your project's `.claude/settings.local.json`:

```json
{
  "plugins": [
    "mobile-development"
  ]
}
```

### Basic Usage

```
# Let the agent handle everything
"Create a tab-based app with authentication"

# Design discovery workflow
"Design a social app for Gen Z"

# Use specific skills
/rn-styling
/navigation
/mobile-authentication

# Use commands
/component-scaffold UserCard
/add-feature user profile with settings
```

## Design System

### Design Discovery Agent

The `mobile-design-discovery` agent uses **VS (Verbalized Sampling)** to recommend design directions:

```
User: "Design a fitness app"

Agent asks:
1. Platform? (iOS First / Android First / Cross-Platform)
2. App Type? (Social / Utility / E-commerce / Content)
3. Audience? (Gen Z / Millennials / Professionals)
4. Personality? (Bold / Clean / Professional / Premium)

Agent outputs:
| Rank | Direction | Suitability | Why |
|------|-----------|-------------|-----|
| 1 | Content-Forward | 87% | Fitness apps need visual focus |
| 2 | iOS Native | 72% | Health-conscious users prefer iOS |
| 3 | Playful Expressive | 65% | Motivation through delight |
```

### Design Patterns Included

- **iOS HIG** - SF Symbols, large titles, haptics
- **Material Design 3** - Dynamic color, FAB, bottom sheets
- **Colors** - Semantic tokens, dark mode, accessibility
- **Typography** - Dynamic Type, font scaling
- **Haptics** - Tactile feedback patterns

## Styling Approach

이 플러그인은 **StyleSheet + react-native-size-matters**를 기본 스타일링 방식으로 사용합니다.

### Why StyleSheet + Scale?

| 접근법 | 장점 | 단점 |
|--------|------|------|
| **StyleSheet + scale** | 기기별 크기 대응, 성능 최적화, 타입 안전 | 코드량 많음 |
| NativeWind | Tailwind 문법 | 기기별 스케일링 부족 |

### 기본 사용법

```typescript
import { StyleSheet } from 'react-native';
import { scale, moderateScale, fontScale } from '@/lib/scale';

const styles = StyleSheet.create({
  container: {
    padding: scale(16),           // 수평 스케일
    borderRadius: moderateScale(12), // 균형 스케일
  },
  title: {
    fontSize: fontScale(24),      // 폰트 스케일 (접근성 대응)
  },
});
```

### Scale 함수 사용 가이드

```typescript
scale(16)           // 수평 치수 (마진, 패딩, 너비)
verticalScale(16)   // 수직 치수 (높이)
moderateScale(16)   // 균형 스케일 (border radius, 아이콘)
fontScale(16)       // 폰트 크기 (접근성 설정 반영)
```

## Tech Stack Support

### Expo (Recommended)

- Expo SDK 52+
- Expo Router (file-based navigation)
- EAS Build & Submit
- Expo Dev Client
- Config plugins for native customization

### React Native CLI

- React Native 0.73+
- React Navigation v6
- Native module linking
- Hermes JavaScript engine
- Custom native modules

## Key Patterns

### Theme System

```typescript
// theme/colors.ts
export const colors = {
  light: {
    background: '#FFFFFF',
    foreground: '#0F172A',
    primary: '#3B82F6',
  },
  dark: {
    background: '#0F172A',
    foreground: '#F8FAFC',
    primary: '#3B82F6',
  },
};

// Usage with ThemeProvider
const { theme } = useTheme();
<View style={{ backgroundColor: theme.colors.background }}>
```

### State Management

```typescript
// Zustand + MMKV for persistent state
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
    }),
    {
      name: 'mobile-store',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);
```

### Authentication

```typescript
// Biometric login with secure storage
import * as LocalAuthentication from 'expo-local-authentication';
import * as SecureStore from 'expo-secure-store';

const authenticateWithBiometrics = async () => {
  const result = await LocalAuthentication.authenticateAsync({
    promptMessage: 'Sign in with biometrics',
  });

  if (result.success) {
    const token = await SecureStore.getItemAsync('auth_token');
    // Continue with token
  }
};
```

## Skill Details

### `/mobile-design`

Mobile design patterns:
- iOS Human Interface Guidelines
- Material Design 3
- Platform-specific components
- Haptic feedback patterns
- Color systems and dark mode

### `/rn-styling`

Mobile styling patterns:
- StyleSheet.create with scale functions
- react-native-size-matters 설정
- Dark mode with theme providers
- Platform-specific styling (iOS/Android)
- Animated styles with Reanimated

### `/navigation`

Navigation patterns:
- Expo Router file-based routing
- React Navigation stack, tabs, drawers
- Deep linking and universal links
- Authentication flow navigation
- Modal presentations

### `/deep-linking`

Deep link implementation:
- Universal Links (iOS)
- App Links (Android)
- Custom URL schemes
- Deferred deep links
- Branch.io integration

### `/app-store-optimization`

ASO best practices:
- Keyword research and optimization
- Screenshot and video guidelines
- Ratings and review management
- A/B testing strategies
- Localization tips

### `/mobile-state-management`

State management for mobile:
- Zustand with MMKV persistence
- React Query with offline support
- Secure storage for sensitive data
- Form state with React Hook Form
- Sync patterns for offline-first apps

### `/mobile-authentication`

Authentication patterns:
- Firebase Auth integration
- Supabase Auth integration
- Biometric authentication (Face ID, Touch ID)
- Social login (Google, Apple)
- Token refresh and session management

### `/native-modules`

Native device features:
- Camera and image picker
- Push notifications (FCM, APNs)
- Location services
- File system operations
- Haptic feedback

### `/mobile-testing`

Testing patterns:
- Jest configuration for RN
- React Native Testing Library
- E2E testing with Detox
- UI automation with Maestro
- MSW for API mocking

### `/mobile-performance`

Performance optimization:
- FlatList/FlashList optimization
- Image optimization with expo-image
- Memory management
- Bundle size reduction
- Startup time optimization
- Hermes engine configuration

## Project Structure

```
plugins/mobile-development/
├── agents/
│   ├── mobile-developer.md
│   └── mobile-design-discovery.md
├── commands/
│   ├── component-scaffold.md
│   └── add-feature.md
├── skills/
│   ├── mobile-design-skill/
│   │   ├── SKILL.md
│   │   ├── patterns/
│   │   │   ├── ios-hig.md
│   │   │   └── material-design.md
│   │   └── common/
│   │       ├── colors.md
│   │       ├── typography.md
│   │       └── haptics.md
│   ├── rn-styling/
│   ├── navigation/
│   ├── state-management/
│   ├── authentication/
│   ├── native-modules/
│   ├── mobile-testing/
│   ├── responsive-design/
│   ├── performance-optimization/
│   ├── deep-linking/
│   └── app-store-optimization/
└── README.md
```

## Requirements

- Claude Code CLI
- Node.js 18+
- Expo SDK 52+ (for Expo projects)
- React Native 0.73+ (for CLI projects)
- Xcode 15+ (for iOS development)
- Android Studio (for Android development)

## Examples

### Design a Complete App

```
"Design a social media app with:
- iOS-first design with HIG patterns
- Tab navigation with 5 screens
- Playful animations for Gen Z audience
- Dark mode support"
```

### Create a Complete App

```
"Build a social media app with:
- User authentication with Google and Apple
- Tab navigation with home, search, profile
- Camera for posting photos
- Push notifications
- Offline support for viewing posts"
```

### Add Authentication

```
/mobile-authentication

"Set up Firebase Auth with biometric login,
Google Sign-In, and secure token storage"
```

### Optimize for App Store

```
/app-store-optimization

"Prepare metadata and screenshots for
App Store and Play Store submission"
```

### Set Up Deep Links

```
/deep-linking

"Configure Universal Links for iOS
and App Links for Android with
marketing campaign tracking"
```

## License

MIT

## Author

[wigtn](https://github.com/wigtn)

---

Built with Claude Code Plugin System
