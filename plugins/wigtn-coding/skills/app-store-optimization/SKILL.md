---
name: app-store-optimization
description: Optimize app store presence for better discoverability and conversions. Covers App Store (iOS) and Play Store (Android) metadata, screenshots, keywords, A/B testing, and ratings optimization.
---

# App Store Optimization (ASO)

## Overview

ASO improves:
- **Discoverability** - Higher search rankings
- **Conversion** - More installs from page views
- **Quality Score** - Better featuring opportunities

---

## Metadata Fundamentals

### App Store (iOS)

| Field | Limit | Indexed | Tips |
|-------|-------|---------|------|
| **App Name** | 30 chars | ✅ | Primary keyword + brand |
| **Subtitle** | 30 chars | ✅ | Secondary keywords |
| **Keywords** | 100 chars | ✅ | Comma-separated, no spaces after commas |
| **Description** | 4000 chars | ❌ | First 3 lines visible, benefits first |
| **Promotional Text** | 170 chars | ❌ | Can update anytime without review |
| **What's New** | 4000 chars | ❌ | Highlight new features |

### Play Store (Android)

| Field | Limit | Indexed | Tips |
|-------|-------|---------|------|
| **App Name** | 30 chars | ✅ | Primary keyword + brand |
| **Short Description** | 80 chars | ✅ | Call-to-action, keywords |
| **Full Description** | 4000 chars | ✅ | Keyword-rich, scannable |
| **What's New** | 500 chars | ❌ | User-facing changes |
| **Developer Name** | - | ✅ | Consistent branding |

---

## Keyword Strategy

### Research Process

1. **Brainstorm** - List all relevant terms
2. **Competitor Analysis** - Check top apps in category
3. **Search Volume** - Use ASO tools (App Annie, Sensor Tower)
4. **Difficulty** - Balance volume vs competition
5. **Relevance** - Must match app functionality

### iOS Keywords Field

```
// 100 characters, comma-separated, no spaces
task,todo,productivity,planner,checklist,organize,goals,habits,reminder,schedule,gtd,project

// Do NOT include:
// - App name (already indexed)
// - Category name (already associated)
// - "app" or "free" (waste of space)
// - Competitor names (rejection risk)
// - Plurals if singular fits (same index)
```

### Android Description Keywords

```
// Naturally incorporate keywords in description
Transform your productivity with [App Name], the ultimate task management
and todo list app. Whether you need a simple checklist or a powerful
project planner, our app helps you organize your goals and build better
habits.

Features:
• Smart task organization with customizable categories
• Daily planner with calendar integration
• Goal tracking and habit builder
• GTD (Getting Things Done) methodology support
• Reminder notifications that actually work
...
```

---

## Visual Assets

### App Icon

| Requirement | iOS | Android |
|-------------|-----|---------|
| Size | 1024×1024px | 512×512px |
| Shape | Auto-rounded | Adaptive icon |
| Background | Any | Must work on any background |

**Best Practices:**
- Simple, recognizable at small sizes
- Avoid text (won't be readable)
- Use brand colors consistently
- Test on light/dark backgrounds

### Screenshots

#### iOS Requirements

| Device | Size | Count |
|--------|------|-------|
| iPhone 6.7" | 1290×2796px | 10 max |
| iPhone 6.5" | 1284×2778px | 10 max |
| iPhone 5.5" | 1242×2208px | 10 max |
| iPad Pro 12.9" | 2048×2732px | 10 max |

#### Android Requirements

| Type | Size | Count |
|------|------|-------|
| Phone | 1080×1920px (min) | 8 max |
| Tablet 7" | 1080×1920px | 8 max |
| Tablet 10" | 1920×1200px | 8 max |

### Screenshot Best Practices

1. **First 2 Screenshots Are Critical**
   - Visible without scrolling
   - Convey core value proposition
   - Should drive conversions alone

2. **Story Arc**
   ```
   Screenshot 1: Hero feature / Main benefit
   Screenshot 2: Key differentiator
   Screenshot 3-4: Core features
   Screenshot 5-6: Secondary features
   Screenshot 7-8: Social proof / Awards
   ```

3. **Design Tips**
   - Device frames optional (A/B test)
   - Text callouts: 3-6 words max
   - Consistent style across all
   - Show actual app UI, not illustrations

### App Preview Video (iOS)

| Format | Duration | Size |
|--------|----------|------|
| MP4, MOV | 15-30 sec | 500MB max |

**Best Practices:**
- Start with strongest feature
- No audio dependency (plays muted)
- Include captions
- Avoid hands/fingers in frame
- Show real app experience

### Promotional Video (Android)

| Format | Duration | Source |
|--------|----------|--------|
| YouTube | 30 sec - 2 min | YouTube URL |

**Best Practices:**
- First 10 seconds critical
- Can include live action
- Include call-to-action
- Show app in context

---

## Expo/EAS Store Configuration

### app.json / app.config.ts

```typescript
// app.config.ts
export default {
  expo: {
    name: "TaskMaster - Todo & Planner",
    slug: "taskmaster",
    version: "2.1.0",

    ios: {
      bundleIdentifier: "com.yourcompany.taskmaster",
      buildNumber: "42",
      supportsTablet: true,
      infoPlist: {
        // Privacy descriptions (required)
        NSCameraUsageDescription: "Take photos of tasks and notes",
        NSPhotoLibraryUsageDescription: "Attach images to tasks",
        NSCalendarsUsageDescription: "Sync tasks with your calendar",
      },
    },

    android: {
      package: "com.yourcompany.taskmaster",
      versionCode: 42,
      adaptiveIcon: {
        foregroundImage: "./assets/adaptive-icon.png",
        backgroundColor: "#2563EB",
      },
      permissions: [
        "CAMERA",
        "READ_CALENDAR",
        "WRITE_CALENDAR",
        "RECEIVE_BOOT_COMPLETED",
        "VIBRATE",
      ],
    },
  },
};
```

### store.config.json (EAS Metadata)

```json
{
  "configVersion": 0,
  "apple": {
    "info": {
      "en-US": {
        "title": "TaskMaster - Todo & Planner",
        "subtitle": "Organize Goals & Build Habits",
        "description": "Transform your productivity...",
        "keywords": "task,todo,productivity,planner...",
        "releaseNotes": "• New: Calendar sync\n• Fixed: Notification timing",
        "promoText": "Now with Calendar Sync!"
      }
    },
    "categories": {
      "primary": "PRODUCTIVITY",
      "secondary": "LIFESTYLE"
    },
    "ageRating": {
      "alcoholTobaccoOrDrugUseOrReferences": "NONE",
      "contests": "NONE",
      "gamblingSimulated": "NONE",
      "medicalOrTreatmentInformation": "NONE",
      "profanityOrCrudeHumor": "NONE",
      "sexualContentGraphicAndNudity": "NONE",
      "sexualContentOrNudity": "NONE",
      "violenceCartoonOrFantasy": "NONE",
      "violenceRealistic": "NONE",
      "violenceRealisticProlongedGraphicOrSadistic": "NONE"
    }
  },
  "android": {
    "info": {
      "en-US": {
        "title": "TaskMaster - Todo & Planner",
        "shortDescription": "Organize tasks, build habits, achieve goals",
        "fullDescription": "Transform your productivity...",
        "video": "https://youtube.com/watch?v=..."
      }
    },
    "categories": {
      "primary": "PRODUCTIVITY"
    },
    "contentRating": {
      "target": "ALL_AGES"
    }
  }
}
```

### Submit with EAS

```bash
# Submit iOS
eas submit --platform ios --latest

# Submit Android
eas submit --platform android --latest

# Submit with metadata
eas metadata:push
```

---

## Ratings & Reviews

### Request Reviews Strategically

```typescript
// lib/review.ts
import * as StoreReview from 'expo-store-review';
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

interface ReviewState {
  installDate: number;
  sessionCount: number;
  lastPromptDate: number;
  hasReviewed: boolean;
  positiveActions: number;
}

const REVIEW_KEY = 'review_state';

export async function maybeRequestReview() {
  const state = getReviewState();

  // Don't prompt if already reviewed
  if (state.hasReviewed) return;

  // Wait at least 7 days after install
  const daysSinceInstall = (Date.now() - state.installDate) / (1000 * 60 * 60 * 24);
  if (daysSinceInstall < 7) return;

  // Wait at least 30 days between prompts
  const daysSinceLastPrompt = (Date.now() - state.lastPromptDate) / (1000 * 60 * 60 * 24);
  if (state.lastPromptDate && daysSinceLastPrompt < 30) return;

  // Require minimum positive actions
  if (state.positiveActions < 5) return;

  // Require minimum sessions
  if (state.sessionCount < 10) return;

  // Check if review is available
  const isAvailable = await StoreReview.isAvailableAsync();
  if (!isAvailable) return;

  // Request review
  await StoreReview.requestReview();

  // Update state
  storage.set(REVIEW_KEY, JSON.stringify({
    ...state,
    lastPromptDate: Date.now(),
  }));
}

export function trackPositiveAction() {
  const state = getReviewState();
  storage.set(REVIEW_KEY, JSON.stringify({
    ...state,
    positiveActions: state.positiveActions + 1,
  }));
}

function getReviewState(): ReviewState {
  const stored = storage.getString(REVIEW_KEY);
  if (stored) return JSON.parse(stored);

  return {
    installDate: Date.now(),
    sessionCount: 0,
    lastPromptDate: 0,
    hasReviewed: false,
    positiveActions: 0,
  };
}
```

### Good Moments to Request

```typescript
// After completing a meaningful task
const handleTaskComplete = () => {
  trackPositiveAction();

  // Only after several completions
  if (completedCount % 10 === 0) {
    maybeRequestReview();
  }
};

// After achieving a goal
const handleGoalAchieved = () => {
  trackPositiveAction();
  showCelebration();

  // Delay to let celebration play
  setTimeout(maybeRequestReview, 2000);
};

// After sharing content
const handleShareSuccess = () => {
  trackPositiveAction();
  maybeRequestReview();
};
```

### Respond to Reviews

- **All 1-2 star**: Acknowledge, apologize, offer support
- **3 star**: Thank, address specific concerns
- **4-5 star**: Thank, encourage specific features

---

## A/B Testing

### App Store (iOS)

Product Page Optimization allows testing:
- Icons
- Screenshots
- App previews

Setup in App Store Connect → App → Product Page Optimization

### Play Store (Android)

Store Listing Experiments allows testing:
- Graphics
- Short description
- Full description

Setup in Google Play Console → Store Presence → Store Listing Experiments

### What to Test

1. **Screenshots**
   - With/without device frames
   - Different first screenshot
   - Different text callouts
   - Different ordering

2. **Icon**
   - Color variations
   - Symbol variations
   - With/without text

3. **Description**
   - Different opening lines
   - Feature ordering
   - Call-to-action variations

---

## Category Selection

### iOS Categories

```
Primary (Required): PRODUCTIVITY
Secondary (Optional): LIFESTYLE

Other Options:
- BOOKS
- BUSINESS
- EDUCATION
- ENTERTAINMENT
- FINANCE
- FOOD_AND_DRINK
- GAMES
- HEALTH_AND_FITNESS
- LIFESTYLE
- MEDICAL
- MUSIC
- NAVIGATION
- NEWS
- PHOTO_AND_VIDEO
- PRODUCTIVITY
- REFERENCE
- SHOPPING
- SOCIAL_NETWORKING
- SPORTS
- TRAVEL
- UTILITIES
- WEATHER
```

### Android Categories

```
Primary: PRODUCTIVITY

Other Options:
- BOOKS_AND_REFERENCE
- BUSINESS
- COMICS
- COMMUNICATION
- EDUCATION
- ENTERTAINMENT
- FINANCE
- FOOD_AND_DRINK
- GAME_*
- HEALTH_AND_FITNESS
- HOUSE_AND_HOME
- LIBRARIES_AND_DEMO
- LIFESTYLE
- MAPS_AND_NAVIGATION
- MEDICAL
- MUSIC_AND_AUDIO
- NEWS_AND_MAGAZINES
- PARENTING
- PERSONALIZATION
- PHOTOGRAPHY
- PRODUCTIVITY
- SHOPPING
- SOCIAL
- SPORTS
- TOOLS
- TRAVEL_AND_LOCAL
- VIDEO_PLAYERS
- WEATHER
```

---

## Localization

### Priority Markets

1. English (US, UK, AU)
2. Spanish (ES, MX)
3. Portuguese (BR)
4. German
5. French
6. Japanese
7. Korean
8. Chinese (Simplified, Traditional)

### Localization Checklist

- [ ] App name localized
- [ ] Subtitle/short description localized
- [ ] Keywords researched per locale
- [ ] Full description translated
- [ ] Screenshots with localized UI
- [ ] Screenshot text callouts translated
- [ ] Release notes translated

---

## ASO Checklist

### Pre-Launch

- [ ] Keyword research completed
- [ ] Competitor analysis done
- [ ] App name optimized
- [ ] Subtitle/short description optimized
- [ ] Full description written
- [ ] Keywords field optimized (iOS)
- [ ] Screenshots created (all sizes)
- [ ] App preview video (optional)
- [ ] Icon finalized
- [ ] Category selected

### Post-Launch

- [ ] Monitor keyword rankings
- [ ] Track conversion rate
- [ ] Respond to reviews
- [ ] A/B test visuals
- [ ] Update for seasonal events
- [ ] Refresh screenshots with new features
- [ ] Iterate on keywords based on data

### Ongoing

- [ ] Weekly keyword rank check
- [ ] Monthly screenshot refresh evaluation
- [ ] Quarterly full description update
- [ ] Respond to all negative reviews
- [ ] Track competitor changes

---

## Tools & Resources

### ASO Tools
- **App Annie** - Market data, keyword research
- **Sensor Tower** - Keyword rankings, ad intelligence
- **AppTweak** - ASO audit, keyword suggestions
- **Mobile Action** - Competitor analysis

### Screenshot Tools
- **Figma** - Design screenshots
- **Rotato** - 3D device mockups
- **AppMockUp** - Quick screenshot generator

### Analytics
- **App Store Connect** - iOS analytics
- **Google Play Console** - Android analytics
- **Firebase** - Install attribution
