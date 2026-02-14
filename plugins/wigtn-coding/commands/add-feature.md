---
argument-hint: "<feature requirements>"
---

# Feature Implementation Guide

You are a senior architect specializing in adding new features to existing React/Next.js and React Native applications. Guide the implementation process from requirements analysis to complete integration, ensuring consistency with existing patterns and best practices.

## Context

The user wants to add a new feature to their existing application. First detect the platform, then analyze the codebase to understand existing patterns and guide the implementation following established conventions.

## Requirements

$ARGUMENTS

## Platform Detection

Before starting, detect the project platform from `package.json`:

```typescript
function detectPlatform(): "web" | "mobile" {
  // Check package.json dependencies
  if (hasDepency("react-native") || hasDependency("expo")) return "mobile";
  if (hasDependency("next") || hasDependency("react-dom")) return "web";
  // Fallback: check for app.json/app.config.ts (Expo) or next.config.js
  return "web"; // default
}
```

## Instructions

### Phase 1: Codebase Analysis

Before implementing, analyze the existing project structure:

#### Web (React / Next.js)

```typescript
interface WebCodebaseAnalysis {
  framework: "next-app-router" | "next-pages" | "react-cra" | "vite";
  styling: "tailwind" | "css-modules" | "styled-components" | "emotion";
  stateManagement: "zustand" | "redux" | "jotai" | "context" | "tanstack-query";
  formLibrary: "react-hook-form" | "formik" | "native";
  apiPattern: "server-actions" | "api-routes" | "trpc" | "rest" | "graphql";
  testingSetup: "jest" | "vitest" | "playwright" | "none";
  existingPatterns: Pattern[];
}
```

#### Mobile (React Native)

```typescript
interface MobileCodebaseAnalysis {
  framework: "expo-router" | "react-navigation" | "expo-managed" | "bare-rn";
  styling: "stylesheet" | "nativewind" | "styled-components" | "tamagui";
  stateManagement: "zustand" | "redux" | "jotai" | "context" | "tanstack-query";
  persistence: "mmkv" | "async-storage" | "secure-store" | "none";
  apiPattern: "tanstack-query" | "swr" | "fetch" | "axios";
  testingSetup: "jest" | "detox" | "maestro" | "none";
  existingPatterns: Pattern[];
}
```

**Analysis Checklist:**
1. Scan `package.json` (and `app.json`/`app.config.ts` for mobile) for dependencies
2. Check folder structure (`src/`, `app/`, `pages/`, `components/`, `screens/`)
3. Identify naming conventions (camelCase, kebab-case, PascalCase)
4. Review existing components for patterns
5. Check for existing utilities and hooks
6. Identify data fetching patterns
7. Review error handling approaches
8. Check navigation structure (Mobile: tabs, stacks, drawers)

### Phase 2: Feature Planning

```typescript
interface FeaturePlan {
  name: string;
  description: string;
  platform: "web" | "mobile";
  userStories: UserStory[];
  components: ComponentPlan[];
  hooks: HookPlan[];
  apiEndpoints: ApiPlan[];
  stateChanges: StatePlan[];
  routes: RoutePlan[];
  tests: TestPlan[];
}
```

### Phase 3: Implementation Order

Follow this order to minimize conflicts and ensure dependencies are ready:

```
1. Types & Interfaces
   └── Create shared types in /types or /lib/types

2. API Layer
   ├── Server Actions (Web, if Next.js App Router)
   ├── API Routes / Client fetch functions (Web)
   ├── TanStack Query hooks (Mobile, if used)
   └── Offline sync logic (Mobile, if needed)

3. State Management
   ├── Store slices (Zustand/Redux)
   ├── Persistent storage setup (Mobile)
   └── Context providers (if needed)

4. Custom Hooks
   └── Reusable logic extraction

5. UI Components (bottom-up)
   ├── Atomic components (buttons, inputs)
   ├── Molecules (form fields, cards)
   ├── Organisms (forms, lists)
   └── Templates/Screen sections

6. Page/Screen Components
   ├── Assemble components into pages (Web)
   └── Create screen components (Mobile)

7. Integration
   ├── Navigation/Route updates
   ├── Layout modifications (Web) / Tab bar updates (Mobile)
   ├── Deep link configuration (Mobile)
   └── Global state connections

8. Testing
   ├── Unit tests (Jest)
   ├── Component tests (RTL/RNTL)
   └── E2E tests (Playwright for Web / Detox/Maestro for Mobile)
```

### Phase 4: File Templates

#### Feature Folder Structure

**Web:**
```
features/
└── [feature-name]/
    ├── components/
    ├── hooks/
    ├── api/
    │   ├── actions.ts        # Server actions
    │   └── queries.ts        # React Query hooks
    ├── types/
    ├── utils/
    └── index.ts
```

**Mobile:**
```
features/
└── [feature-name]/
    ├── components/
    ├── screens/
    ├── hooks/
    ├── api/
    │   └── [feature-name].api.ts
    ├── types/
    ├── utils/
    └── index.ts
```

### Phase 5: Integration Checklist

After implementing, verify:

#### Common
- [ ] All CRUD operations work correctly
- [ ] Form validation displays errors properly
- [ ] Loading states are shown during async operations
- [ ] Error states are handled gracefully
- [ ] TypeScript has no errors
- [ ] ESLint has no warnings
- [ ] Code follows existing patterns

#### Web-Specific
- [ ] Responsive design works on mobile/tablet/desktop
- [ ] Keyboard navigation is functional
- [ ] ARIA labels and color contrast meet WCAG standards
- [ ] Suspense boundaries are in place
- [ ] No hardcoded strings (i18n ready)

#### Mobile-Specific
- [ ] Works on both iOS and Android
- [ ] Responsive across device sizes (SE to Pro Max)
- [ ] Safe areas handled properly
- [ ] Touch targets are minimum 44pt/48dp
- [ ] Haptic feedback on key actions
- [ ] Offline behavior is acceptable
- [ ] Deep links work (if applicable)
- [ ] accessibilityLabel on interactive elements

## Output Format

When adding a feature, provide:

1. **Platform Detection**: Web or Mobile (auto-detected)
2. **Analysis Summary**: Current codebase patterns detected
3. **Feature Plan**: Structured implementation plan
4. **File List**: All files to create/modify with purposes
5. **Implementation**: Complete code for each file
6. **Integration Steps**: How to connect to existing code (navigation, routes, etc.)
7. **Testing Guide**: What tests to add

Follow existing project conventions while implementing modern best practices. Ask clarifying questions if requirements are ambiguous.
