---
name: native-modules
description: Master native device features in React Native - camera, notifications, location, file system, biometrics, and more. Covers both Expo SDK modules and custom native integrations.
disable-model-invocation: true
---

# Native Modules & Device Features

Comprehensive guide to accessing native device capabilities in React Native with Expo SDK modules and custom native code.

## When to Use This Skill

- Implementing camera or image picker functionality
- Setting up push notifications (FCM/APNs)
- Accessing device location
- Working with file system and storage
- Implementing biometric authentication
- Using device sensors

## Core Concepts

### 1. Expo vs Bare

| Feature | Expo Managed | Expo Bare / RN CLI |
|---------|--------------|-------------------|
| **Camera** | expo-camera | react-native-camera |
| **Notifications** | expo-notifications | @notifee/react-native |
| **Location** | expo-location | react-native-geolocation |
| **File System** | expo-file-system | react-native-fs |
| **Biometrics** | expo-local-authentication | react-native-biometrics |

### 2. Permission Handling

```
1. Check permission status
2. Request if needed
3. Handle denial gracefully
4. Direct to settings if blocked
```

## Patterns

### Pattern 1: Camera & Image Picker

```bash
npx expo install expo-camera expo-image-picker expo-media-library
```

```typescript
// hooks/useCamera.ts
import { useState, useRef } from 'react';
import { CameraView, CameraType, useCameraPermissions } from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import * as MediaLibrary from 'expo-media-library';
import { Alert, Linking } from 'react-native';

export function useCamera() {
  const [permission, requestPermission] = useCameraPermissions();
  const [mediaPermission, requestMediaPermission] = MediaLibrary.usePermissions();
  const cameraRef = useRef<CameraView>(null);
  const [facing, setFacing] = useState<CameraType>('back');

  const ensureCameraPermission = async (): Promise<boolean> => {
    if (permission?.granted) return true;

    const { granted } = await requestPermission();

    if (!granted) {
      Alert.alert(
        'Camera Permission',
        'Camera access is required to take photos. Please enable it in Settings.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Open Settings', onPress: () => Linking.openSettings() },
        ]
      );
      return false;
    }

    return true;
  };

  const takePicture = async (): Promise<string | null> => {
    if (!cameraRef.current) return null;

    try {
      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.8,
        base64: false,
        exif: false,
      });

      return photo?.uri ?? null;
    } catch (error) {
      console.error('Failed to take picture:', error);
      return null;
    }
  };

  const saveToGallery = async (uri: string): Promise<boolean> => {
    if (!mediaPermission?.granted) {
      const { granted } = await requestMediaPermission();
      if (!granted) {
        Alert.alert('Permission needed', 'Media library access is required to save photos.');
        return false;
      }
    }

    try {
      await MediaLibrary.saveToLibraryAsync(uri);
      return true;
    } catch (error) {
      console.error('Failed to save to gallery:', error);
      return false;
    }
  };

  const toggleFacing = () => {
    setFacing((current) => (current === 'back' ? 'front' : 'back'));
  };

  return {
    cameraRef,
    permission,
    facing,
    ensureCameraPermission,
    takePicture,
    saveToGallery,
    toggleFacing,
  };
}

// Image Picker hook
export function useImagePicker() {
  const [image, setImage] = useState<string | null>(null);

  const pickImage = async (options?: ImagePicker.ImagePickerOptions): Promise<string | null> => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();

    if (status !== 'granted') {
      Alert.alert(
        'Permission needed',
        'Please allow access to your photo library.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Settings', onPress: () => Linking.openSettings() },
        ]
      );
      return null;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.8,
      ...options,
    });

    if (!result.canceled && result.assets[0]) {
      setImage(result.assets[0].uri);
      return result.assets[0].uri;
    }

    return null;
  };

  const takePhoto = async (options?: ImagePicker.ImagePickerOptions): Promise<string | null> => {
    const { status } = await ImagePicker.requestCameraPermissionsAsync();

    if (status !== 'granted') {
      Alert.alert('Permission needed', 'Camera access is required.');
      return null;
    }

    const result = await ImagePicker.launchCameraAsync({
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.8,
      ...options,
    });

    if (!result.canceled && result.assets[0]) {
      setImage(result.assets[0].uri);
      return result.assets[0].uri;
    }

    return null;
  };

  return { image, pickImage, takePhoto, setImage };
}

// components/CameraScreen.tsx
import { View, Pressable, Text } from 'react-native';
import { CameraView } from 'expo-camera';
import { useCamera } from '@/hooks/useCamera';
import { Camera, RotateCcw, Check } from 'lucide-react-native';

export function CameraScreen({ onCapture }: { onCapture: (uri: string) => void }) {
  const { cameraRef, facing, ensureCameraPermission, takePicture, toggleFacing } = useCamera();
  const [ready, setReady] = useState(false);
  const [photo, setPhoto] = useState<string | null>(null);

  useEffect(() => {
    ensureCameraPermission().then(setReady);
  }, []);

  const handleCapture = async () => {
    const uri = await takePicture();
    if (uri) setPhoto(uri);
  };

  const handleConfirm = () => {
    if (photo) {
      onCapture(photo);
    }
  };

  if (!ready) return <LoadingScreen />;

  if (photo) {
    return (
      <View className="flex-1">
        <Image source={{ uri: photo }} className="flex-1" />
        <View className="absolute bottom-10 left-0 right-0 flex-row justify-center gap-6">
          <Pressable
            onPress={() => setPhoto(null)}
            className="bg-white/20 p-4 rounded-full"
          >
            <RotateCcw size={24} color="#FFF" />
          </Pressable>
          <Pressable
            onPress={handleConfirm}
            className="bg-primary p-4 rounded-full"
          >
            <Check size={24} color="#FFF" />
          </Pressable>
        </View>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-black">
      <CameraView
        ref={cameraRef}
        facing={facing}
        style={{ flex: 1 }}
      />
      <View className="absolute bottom-10 left-0 right-0 flex-row justify-center items-center gap-6">
        <Pressable
          onPress={toggleFacing}
          className="bg-white/20 p-4 rounded-full"
        >
          <RotateCcw size={24} color="#FFF" />
        </Pressable>
        <Pressable
          onPress={handleCapture}
          className="bg-white w-20 h-20 rounded-full items-center justify-center"
        >
          <View className="bg-white w-16 h-16 rounded-full border-4 border-black" />
        </Pressable>
        <View className="w-14" />
      </View>
    </View>
  );
}
```

### Pattern 2: Push Notifications

```bash
npx expo install expo-notifications expo-device expo-constants
```

```typescript
// lib/notifications.ts
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import Constants from 'expo-constants';
import { Platform } from 'react-native';

// Configure notification handling
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export const notifications = {
  async registerForPushNotifications(): Promise<string | null> {
    if (!Device.isDevice) {
      console.log('Push notifications require a physical device');
      return null;
    }

    // Check existing permission
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;

    // Request permission if not granted
    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }

    if (finalStatus !== 'granted') {
      console.log('Failed to get push token for push notification');
      return null;
    }

    // Get the token
    const token = await Notifications.getExpoPushTokenAsync({
      projectId: Constants.expoConfig?.extra?.eas?.projectId,
    });

    // Android specific channel setup
    if (Platform.OS === 'android') {
      await Notifications.setNotificationChannelAsync('default', {
        name: 'default',
        importance: Notifications.AndroidImportance.MAX,
        vibrationPattern: [0, 250, 250, 250],
        lightColor: '#3B82F6',
      });
    }

    return token.data;
  },

  async scheduleLocalNotification(
    title: string,
    body: string,
    data?: Record<string, any>,
    trigger?: Notifications.NotificationTriggerInput
  ) {
    await Notifications.scheduleNotificationAsync({
      content: {
        title,
        body,
        data,
        sound: true,
      },
      trigger: trigger ?? null, // null = immediate
    });
  },

  async cancelAllNotifications() {
    await Notifications.cancelAllScheduledNotificationsAsync();
  },

  async setBadgeCount(count: number) {
    await Notifications.setBadgeCountAsync(count);
  },

  async getBadgeCount(): Promise<number> {
    return Notifications.getBadgeCountAsync();
  },

  // Listeners
  addNotificationReceivedListener(
    callback: (notification: Notifications.Notification) => void
  ) {
    return Notifications.addNotificationReceivedListener(callback);
  },

  addNotificationResponseListener(
    callback: (response: Notifications.NotificationResponse) => void
  ) {
    return Notifications.addNotificationResponseReceivedListener(callback);
  },
};

// hooks/useNotifications.ts
import { useEffect, useRef, useState } from 'react';
import { notifications } from '@/lib/notifications';
import * as Notifications from 'expo-notifications';
import { router } from 'expo-router';

export function useNotifications() {
  const [expoPushToken, setExpoPushToken] = useState<string | null>(null);
  const notificationListener = useRef<Notifications.Subscription>();
  const responseListener = useRef<Notifications.Subscription>();

  useEffect(() => {
    // Register for push notifications
    notifications.registerForPushNotifications().then((token) => {
      if (token) {
        setExpoPushToken(token);
        // Send token to your server
        sendTokenToServer(token);
      }
    });

    // Listen for incoming notifications while app is foregrounded
    notificationListener.current = notifications.addNotificationReceivedListener(
      (notification) => {
        console.log('Notification received:', notification);
      }
    );

    // Listen for user interaction with notification
    responseListener.current = notifications.addNotificationResponseListener(
      (response) => {
        const data = response.notification.request.content.data;

        // Handle navigation based on notification data
        if (data?.screen) {
          router.push(data.screen);
        }
      }
    );

    return () => {
      if (notificationListener.current) {
        Notifications.removeNotificationSubscription(notificationListener.current);
      }
      if (responseListener.current) {
        Notifications.removeNotificationSubscription(responseListener.current);
      }
    };
  }, []);

  return { expoPushToken };
}

// Use in your app
// app/_layout.tsx
import { useNotifications } from '@/hooks/useNotifications';

export default function RootLayout() {
  useNotifications(); // Initialize notification handling

  return (
    // ...
  );
}
```

### Pattern 3: Location Services

```bash
npx expo install expo-location
```

```typescript
// hooks/useLocation.ts
import { useState, useEffect } from 'react';
import * as Location from 'expo-location';
import { Alert, Linking } from 'react-native';

interface LocationState {
  latitude: number;
  longitude: number;
  accuracy: number | null;
}

export function useLocation() {
  const [location, setLocation] = useState<LocationState | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const requestPermission = async (): Promise<boolean> => {
    const { status } = await Location.requestForegroundPermissionsAsync();

    if (status !== 'granted') {
      Alert.alert(
        'Location Permission',
        'Location access is required for this feature.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Open Settings', onPress: () => Linking.openSettings() },
        ]
      );
      return false;
    }

    return true;
  };

  const getCurrentLocation = async (): Promise<LocationState | null> => {
    setLoading(true);
    setError(null);

    try {
      const hasPermission = await requestPermission();
      if (!hasPermission) {
        setLoading(false);
        return null;
      }

      const { coords } = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });

      const locationData = {
        latitude: coords.latitude,
        longitude: coords.longitude,
        accuracy: coords.accuracy,
      };

      setLocation(locationData);
      return locationData;
    } catch (err) {
      setError('Failed to get location');
      return null;
    } finally {
      setLoading(false);
    }
  };

  const watchLocation = (
    callback: (location: LocationState) => void
  ): (() => void) => {
    let subscription: Location.LocationSubscription | null = null;

    (async () => {
      const hasPermission = await requestPermission();
      if (!hasPermission) return;

      subscription = await Location.watchPositionAsync(
        {
          accuracy: Location.Accuracy.High,
          timeInterval: 5000,
          distanceInterval: 10,
        },
        ({ coords }) => {
          const locationData = {
            latitude: coords.latitude,
            longitude: coords.longitude,
            accuracy: coords.accuracy,
          };
          setLocation(locationData);
          callback(locationData);
        }
      );
    })();

    return () => {
      subscription?.remove();
    };
  };

  const getAddress = async (
    latitude: number,
    longitude: number
  ): Promise<string | null> => {
    try {
      const [result] = await Location.reverseGeocodeAsync({
        latitude,
        longitude,
      });

      if (result) {
        return [
          result.street,
          result.city,
          result.region,
          result.country,
        ]
          .filter(Boolean)
          .join(', ');
      }
      return null;
    } catch (error) {
      return null;
    }
  };

  return {
    location,
    loading,
    error,
    getCurrentLocation,
    watchLocation,
    getAddress,
  };
}

// Background location tracking
export async function startBackgroundLocationTracking() {
  const { status } = await Location.requestBackgroundPermissionsAsync();

  if (status !== 'granted') {
    Alert.alert('Background location permission is required');
    return;
  }

  await Location.startLocationUpdatesAsync('background-location-task', {
    accuracy: Location.Accuracy.Balanced,
    timeInterval: 60000, // 1 minute
    distanceInterval: 100, // 100 meters
    foregroundService: {
      notificationTitle: 'Location Tracking',
      notificationBody: 'App is tracking your location',
      notificationColor: '#3B82F6',
    },
  });
}

// Define the background task (in a separate file loaded at app start)
import * as TaskManager from 'expo-task-manager';

TaskManager.defineTask('background-location-task', async ({ data, error }) => {
  if (error) {
    console.error('Background location error:', error);
    return;
  }

  if (data) {
    const { locations } = data as { locations: Location.LocationObject[] };
    // Send locations to your server
    console.log('Background location:', locations);
  }
});
```

### Pattern 4: File System Operations

```bash
npx expo install expo-file-system expo-document-picker expo-sharing
```

```typescript
// lib/fileSystem.ts
import * as FileSystem from 'expo-file-system';
import * as DocumentPicker from 'expo-document-picker';
import * as Sharing from 'expo-sharing';

export const files = {
  // App directories
  get documentDirectory() {
    return FileSystem.documentDirectory;
  },

  get cacheDirectory() {
    return FileSystem.cacheDirectory;
  },

  // Read file
  async readFile(path: string): Promise<string> {
    return FileSystem.readAsStringAsync(path);
  },

  // Write file
  async writeFile(path: string, content: string): Promise<void> {
    await FileSystem.writeAsStringAsync(path, content);
  },

  // Delete file
  async deleteFile(path: string): Promise<void> {
    await FileSystem.deleteAsync(path, { idempotent: true });
  },

  // Check if file exists
  async exists(path: string): Promise<boolean> {
    const info = await FileSystem.getInfoAsync(path);
    return info.exists;
  },

  // Get file info
  async getInfo(path: string) {
    return FileSystem.getInfoAsync(path);
  },

  // Create directory
  async createDirectory(path: string): Promise<void> {
    await FileSystem.makeDirectoryAsync(path, { intermediates: true });
  },

  // List directory contents
  async listDirectory(path: string): Promise<string[]> {
    return FileSystem.readDirectoryAsync(path);
  },

  // Download file
  async downloadFile(
    url: string,
    localPath: string,
    onProgress?: (progress: number) => void
  ): Promise<string> {
    const callback = onProgress
      ? (downloadProgress: FileSystem.DownloadProgressData) => {
          const progress =
            downloadProgress.totalBytesWritten /
            downloadProgress.totalBytesExpectedToWrite;
          onProgress(progress);
        }
      : undefined;

    const downloadResumable = FileSystem.createDownloadResumable(
      url,
      localPath,
      {},
      callback
    );

    const result = await downloadResumable.downloadAsync();
    return result?.uri ?? localPath;
  },

  // Upload file
  async uploadFile(
    localPath: string,
    uploadUrl: string,
    fieldName = 'file'
  ): Promise<any> {
    const response = await FileSystem.uploadAsync(uploadUrl, localPath, {
      fieldName,
      httpMethod: 'POST',
      uploadType: FileSystem.FileSystemUploadType.MULTIPART,
    });

    return JSON.parse(response.body);
  },

  // Pick document
  async pickDocument(options?: DocumentPicker.DocumentPickerOptions) {
    const result = await DocumentPicker.getDocumentAsync({
      type: '*/*',
      copyToCacheDirectory: true,
      ...options,
    });

    if (result.canceled) return null;
    return result.assets[0];
  },

  // Share file
  async shareFile(path: string): Promise<void> {
    const isAvailable = await Sharing.isAvailableAsync();
    if (!isAvailable) {
      throw new Error('Sharing is not available on this device');
    }

    await Sharing.shareAsync(path);
  },

  // Get cache size
  async getCacheSize(): Promise<number> {
    const cacheDir = FileSystem.cacheDirectory;
    if (!cacheDir) return 0;

    let totalSize = 0;
    const files = await FileSystem.readDirectoryAsync(cacheDir);

    for (const file of files) {
      const info = await FileSystem.getInfoAsync(`${cacheDir}${file}`);
      if (info.exists && info.size) {
        totalSize += info.size;
      }
    }

    return totalSize;
  },

  // Clear cache
  async clearCache(): Promise<void> {
    const cacheDir = FileSystem.cacheDirectory;
    if (!cacheDir) return;

    const files = await FileSystem.readDirectoryAsync(cacheDir);
    await Promise.all(
      files.map((file) =>
        FileSystem.deleteAsync(`${cacheDir}${file}`, { idempotent: true })
      )
    );
  },
};

// hooks/useFileDownload.ts
import { useState } from 'react';
import { files } from '@/lib/fileSystem';

export function useFileDownload() {
  const [progress, setProgress] = useState(0);
  const [downloading, setDownloading] = useState(false);

  const download = async (url: string, filename: string): Promise<string | null> => {
    setDownloading(true);
    setProgress(0);

    try {
      const localPath = `${files.documentDirectory}${filename}`;
      const uri = await files.downloadFile(url, localPath, setProgress);
      return uri;
    } catch (error) {
      console.error('Download failed:', error);
      return null;
    } finally {
      setDownloading(false);
    }
  };

  return { download, progress, downloading };
}
```

### Pattern 5: Haptic Feedback

```bash
npx expo install expo-haptics
```

```typescript
// lib/haptics.ts
import * as Haptics from 'expo-haptics';
import { Platform } from 'react-native';

export const haptics = {
  light() {
    if (Platform.OS === 'ios') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }
  },

  medium() {
    if (Platform.OS === 'ios') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }
  },

  heavy() {
    if (Platform.OS === 'ios') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    }
  },

  selection() {
    Haptics.selectionAsync();
  },

  success() {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  },

  warning() {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
  },

  error() {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
  },
};

// Usage in components
import { haptics } from '@/lib/haptics';

function Button({ onPress }: { onPress: () => void }) {
  const handlePress = () => {
    haptics.light();
    onPress();
  };

  return (
    <Pressable onPress={handlePress}>
      <Text>Press me</Text>
    </Pressable>
  );
}

// Success action
const handleSuccess = () => {
  haptics.success();
  // Show success UI
};
```

---

## React Native CLI Patterns

The following patterns are for **bare React Native** projects without Expo.

### CLI Pattern 1: Camera with Vision Camera

```bash
npm install react-native-vision-camera
npm install react-native-image-picker
cd ios && pod install
```

```typescript
// hooks/useVisionCamera.ts
import { useRef, useState } from 'react';
import {
  Camera,
  useCameraDevice,
  useCameraPermission,
  PhotoFile,
} from 'react-native-vision-camera';
import { Alert, Linking } from 'react-native';

export function useVisionCamera() {
  const cameraRef = useRef<Camera>(null);
  const [facing, setFacing] = useState<'back' | 'front'>('back');
  const device = useCameraDevice(facing);
  const { hasPermission, requestPermission } = useCameraPermission();

  const ensurePermission = async (): Promise<boolean> => {
    if (hasPermission) return true;

    const granted = await requestPermission();

    if (!granted) {
      Alert.alert(
        'Camera Permission',
        'Camera access is required. Please enable it in Settings.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Open Settings', onPress: () => Linking.openSettings() },
        ]
      );
      return false;
    }

    return true;
  };

  const takePicture = async (): Promise<PhotoFile | null> => {
    if (!cameraRef.current) return null;

    try {
      const photo = await cameraRef.current.takePhoto({
        qualityPrioritization: 'balanced',
        flash: 'off',
      });

      return photo;
    } catch (error) {
      console.error('Failed to take picture:', error);
      return null;
    }
  };

  const toggleFacing = () => {
    setFacing((current) => (current === 'back' ? 'front' : 'back'));
  };

  return {
    cameraRef,
    device,
    hasPermission,
    ensurePermission,
    takePicture,
    toggleFacing,
  };
}

// components/VisionCameraScreen.tsx
import { View, Pressable, StyleSheet } from 'react-native';
import { Camera } from 'react-native-vision-camera';
import { useVisionCamera } from '@/hooks/useVisionCamera';

export function VisionCameraScreen({ onCapture }: { onCapture: (path: string) => void }) {
  const { cameraRef, device, hasPermission, takePicture, toggleFacing } = useVisionCamera();

  if (!device || !hasPermission) {
    return <PermissionDeniedView />;
  }

  const handleCapture = async () => {
    const photo = await takePicture();
    if (photo) {
      onCapture(photo.path);
    }
  };

  return (
    <View style={styles.container}>
      <Camera
        ref={cameraRef}
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        photo={true}
      />
      <View style={styles.controls}>
        <Pressable onPress={toggleFacing} style={styles.button}>
          {/* Flip icon */}
        </Pressable>
        <Pressable onPress={handleCapture} style={styles.captureButton}>
          {/* Capture icon */}
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  controls: {
    position: 'absolute',
    bottom: 40,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 24,
  },
  button: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: 'rgba(255,255,255,0.3)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  captureButton: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: '#FFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
```

### CLI Pattern 2: Push Notifications with Notifee

```bash
npm install @notifee/react-native
npm install @react-native-firebase/app @react-native-firebase/messaging
cd ios && pod install
```

```typescript
// lib/notifications.ts
import notifee, {
  AndroidImportance,
  AndroidStyle,
  EventType,
} from '@notifee/react-native';
import messaging from '@react-native-firebase/messaging';

export const notifications = {
  // Initialize
  async init() {
    // Create Android channel
    await notifee.createChannel({
      id: 'default',
      name: 'Default Channel',
      importance: AndroidImportance.HIGH,
      vibration: true,
    });

    // Request permission (iOS)
    await notifee.requestPermission();

    // Handle FCM messages
    messaging().onMessage(async (remoteMessage) => {
      await this.displayNotification(
        remoteMessage.notification?.title || 'New Message',
        remoteMessage.notification?.body || '',
        remoteMessage.data
      );
    });

    // Handle background messages
    messaging().setBackgroundMessageHandler(async (remoteMessage) => {
      console.log('Background message:', remoteMessage);
    });
  },

  // Get FCM token
  async getToken(): Promise<string | null> {
    try {
      const token = await messaging().getToken();
      return token;
    } catch (error) {
      console.error('Failed to get FCM token:', error);
      return null;
    }
  },

  // Display local notification
  async displayNotification(
    title: string,
    body: string,
    data?: Record<string, any>
  ) {
    await notifee.displayNotification({
      title,
      body,
      data,
      android: {
        channelId: 'default',
        importance: AndroidImportance.HIGH,
        pressAction: { id: 'default' },
        style: body.length > 100
          ? { type: AndroidStyle.BIGTEXT, text: body }
          : undefined,
      },
      ios: {
        sound: 'default',
      },
    });
  },

  // Schedule notification
  async scheduleNotification(
    title: string,
    body: string,
    timestamp: number,
    data?: Record<string, any>
  ) {
    await notifee.createTriggerNotification(
      {
        title,
        body,
        data,
        android: { channelId: 'default' },
        ios: { sound: 'default' },
      },
      {
        type: notifee.TriggerType.TIMESTAMP,
        timestamp,
      }
    );
  },

  // Cancel all notifications
  async cancelAll() {
    await notifee.cancelAllNotifications();
  },

  // Set badge count
  async setBadge(count: number) {
    await notifee.setBadgeCount(count);
  },

  // Handle notification events
  onForegroundEvent(callback: (data: any) => void) {
    return notifee.onForegroundEvent(({ type, detail }) => {
      if (type === EventType.PRESS) {
        callback(detail.notification?.data);
      }
    });
  },
};

// hooks/useNotifications.ts
import { useEffect, useState } from 'react';
import { notifications } from '@/lib/notifications';

export function useNotifications() {
  const [token, setToken] = useState<string | null>(null);

  useEffect(() => {
    // Initialize notifications
    notifications.init();

    // Get FCM token
    notifications.getToken().then(setToken);

    // Handle foreground notification press
    const unsubscribe = notifications.onForegroundEvent((data) => {
      if (data?.screen) {
        // Navigate to screen
        navigation.navigate(data.screen, data.params);
      }
    });

    return unsubscribe;
  }, []);

  return { token };
}
```

### CLI Pattern 3: Location with Geolocation Service

```bash
npm install react-native-geolocation-service
npm install react-native-permissions
cd ios && pod install
```

```typescript
// lib/location.ts
import Geolocation, {
  GeoPosition,
  GeoError,
} from 'react-native-geolocation-service';
import { check, request, PERMISSIONS, RESULTS, openSettings } from 'react-native-permissions';
import { Platform, Alert } from 'react-native';

const LOCATION_PERMISSION = Platform.select({
  ios: PERMISSIONS.IOS.LOCATION_WHEN_IN_USE,
  android: PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION,
})!;

export const location = {
  async requestPermission(): Promise<boolean> {
    const status = await check(LOCATION_PERMISSION);

    if (status === RESULTS.GRANTED) return true;

    if (status === RESULTS.DENIED) {
      const result = await request(LOCATION_PERMISSION);
      return result === RESULTS.GRANTED;
    }

    if (status === RESULTS.BLOCKED) {
      Alert.alert(
        'Location Permission',
        'Location access is blocked. Please enable it in Settings.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Open Settings', onPress: () => openSettings() },
        ]
      );
      return false;
    }

    return false;
  },

  async getCurrentPosition(): Promise<GeoPosition | null> {
    const hasPermission = await this.requestPermission();
    if (!hasPermission) return null;

    return new Promise((resolve, reject) => {
      Geolocation.getCurrentPosition(
        (position) => resolve(position),
        (error) => {
          console.error('Location error:', error);
          resolve(null);
        },
        {
          enableHighAccuracy: true,
          timeout: 15000,
          maximumAge: 10000,
        }
      );
    });
  },

  watchPosition(
    onSuccess: (position: GeoPosition) => void,
    onError?: (error: GeoError) => void
  ): number {
    return Geolocation.watchPosition(
      onSuccess,
      onError || ((error) => console.error('Watch error:', error)),
      {
        enableHighAccuracy: true,
        distanceFilter: 10,
        interval: 5000,
        fastestInterval: 2000,
      }
    );
  },

  clearWatch(watchId: number) {
    Geolocation.clearWatch(watchId);
  },

  stopObserving() {
    Geolocation.stopObserving();
  },
};

// hooks/useLocation.ts
import { useState, useEffect, useCallback } from 'react';
import { location } from '@/lib/location';
import { GeoPosition } from 'react-native-geolocation-service';

interface LocationState {
  latitude: number;
  longitude: number;
  accuracy: number | null;
}

export function useLocation() {
  const [currentLocation, setCurrentLocation] = useState<LocationState | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const getCurrentLocation = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const position = await location.getCurrentPosition();

      if (position) {
        setCurrentLocation({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
        });
        return position;
      } else {
        setError('Failed to get location');
        return null;
      }
    } catch (err) {
      setError('Location error');
      return null;
    } finally {
      setLoading(false);
    }
  }, []);

  const watchLocation = useCallback((callback: (location: LocationState) => void) => {
    const watchId = location.watchPosition((position) => {
      const loc = {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
        accuracy: position.coords.accuracy,
      };
      setCurrentLocation(loc);
      callback(loc);
    });

    return () => location.clearWatch(watchId);
  }, []);

  return {
    location: currentLocation,
    loading,
    error,
    getCurrentLocation,
    watchLocation,
  };
}
```

### CLI Pattern 4: File System with RNFS

```bash
npm install react-native-fs
npm install react-native-document-picker
npm install react-native-share
cd ios && pod install
```

```typescript
// lib/fileSystem.ts
import RNFS from 'react-native-fs';
import DocumentPicker, { types } from 'react-native-document-picker';
import Share from 'react-native-share';

export const files = {
  // Directories
  get documentDir() {
    return RNFS.DocumentDirectoryPath;
  },

  get cacheDir() {
    return RNFS.CachesDirectoryPath;
  },

  get tempDir() {
    return RNFS.TemporaryDirectoryPath;
  },

  // Read file
  async readFile(path: string, encoding: string = 'utf8'): Promise<string> {
    return RNFS.readFile(path, encoding);
  },

  // Write file
  async writeFile(path: string, content: string, encoding: string = 'utf8'): Promise<void> {
    await RNFS.writeFile(path, content, encoding);
  },

  // Append to file
  async appendFile(path: string, content: string, encoding: string = 'utf8'): Promise<void> {
    await RNFS.appendFile(path, content, encoding);
  },

  // Delete file
  async deleteFile(path: string): Promise<void> {
    const exists = await RNFS.exists(path);
    if (exists) {
      await RNFS.unlink(path);
    }
  },

  // Check existence
  async exists(path: string): Promise<boolean> {
    return RNFS.exists(path);
  },

  // Get file info
  async stat(path: string) {
    return RNFS.stat(path);
  },

  // Create directory
  async mkdir(path: string): Promise<void> {
    await RNFS.mkdir(path);
  },

  // List directory
  async readDir(path: string) {
    return RNFS.readDir(path);
  },

  // Download file
  async downloadFile(
    url: string,
    destPath: string,
    onProgress?: (progress: number) => void
  ): Promise<string> {
    const { promise } = RNFS.downloadFile({
      fromUrl: url,
      toFile: destPath,
      progress: (res) => {
        const progress = res.bytesWritten / res.contentLength;
        onProgress?.(progress);
      },
      progressDivider: 1,
    });

    const result = await promise;

    if (result.statusCode === 200) {
      return destPath;
    }

    throw new Error(`Download failed with status ${result.statusCode}`);
  },

  // Upload file
  async uploadFile(
    url: string,
    filePath: string,
    options?: {
      fileName?: string;
      fileType?: string;
      fieldName?: string;
      headers?: Record<string, string>;
    }
  ) {
    const { promise } = RNFS.uploadFiles({
      toUrl: url,
      files: [
        {
          name: options?.fieldName || 'file',
          filename: options?.fileName || 'upload',
          filepath: filePath,
          filetype: options?.fileType || 'application/octet-stream',
        },
      ],
      method: 'POST',
      headers: options?.headers || {},
    });

    return promise;
  },

  // Pick document
  async pickDocument(allowMultiple = false) {
    try {
      const result = await DocumentPicker.pick({
        allowMultiSelection: allowMultiple,
        type: [types.allFiles],
        copyTo: 'cachesDirectory',
      });

      return allowMultiple ? result : result[0];
    } catch (err) {
      if (DocumentPicker.isCancel(err)) {
        return null;
      }
      throw err;
    }
  },

  // Share file
  async shareFile(filePath: string, mimeType?: string) {
    await Share.open({
      url: `file://${filePath}`,
      type: mimeType,
    });
  },

  // Copy file
  async copyFile(src: string, dest: string): Promise<void> {
    await RNFS.copyFile(src, dest);
  },

  // Move file
  async moveFile(src: string, dest: string): Promise<void> {
    await RNFS.moveFile(src, dest);
  },

  // Get free disk space
  async getFreeDiskSpace(): Promise<number> {
    return RNFS.getFSInfo().then((info) => info.freeSpace);
  },
};
```

### CLI Pattern 5: Permissions with react-native-permissions

```bash
npm install react-native-permissions
cd ios && pod install
```

```typescript
// lib/permissions.ts
import {
  check,
  request,
  requestMultiple,
  PERMISSIONS,
  RESULTS,
  openSettings,
  Permission,
} from 'react-native-permissions';
import { Platform, Alert } from 'react-native';

type PermissionType = 'camera' | 'location' | 'microphone' | 'photos' | 'notifications';

const PERMISSION_MAP: Record<PermissionType, { ios: Permission; android: Permission }> = {
  camera: {
    ios: PERMISSIONS.IOS.CAMERA,
    android: PERMISSIONS.ANDROID.CAMERA,
  },
  location: {
    ios: PERMISSIONS.IOS.LOCATION_WHEN_IN_USE,
    android: PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION,
  },
  microphone: {
    ios: PERMISSIONS.IOS.MICROPHONE,
    android: PERMISSIONS.ANDROID.RECORD_AUDIO,
  },
  photos: {
    ios: PERMISSIONS.IOS.PHOTO_LIBRARY,
    android: PERMISSIONS.ANDROID.READ_MEDIA_IMAGES,
  },
  notifications: {
    ios: PERMISSIONS.IOS.NOTIFICATIONS,
    android: PERMISSIONS.ANDROID.POST_NOTIFICATIONS,
  },
};

export const permissions = {
  async check(type: PermissionType): Promise<boolean> {
    const permission = Platform.select(PERMISSION_MAP[type])!;
    const result = await check(permission);
    return result === RESULTS.GRANTED;
  },

  async request(type: PermissionType, rationale?: string): Promise<boolean> {
    const permission = Platform.select(PERMISSION_MAP[type])!;
    const status = await check(permission);

    if (status === RESULTS.GRANTED) return true;

    if (status === RESULTS.BLOCKED) {
      this.showBlockedAlert(type);
      return false;
    }

    const result = await request(permission);
    return result === RESULTS.GRANTED;
  },

  async requestMultiple(types: PermissionType[]): Promise<Record<PermissionType, boolean>> {
    const permissionsToRequest = types.map((type) =>
      Platform.select(PERMISSION_MAP[type])!
    );

    const results = await requestMultiple(permissionsToRequest);

    return types.reduce((acc, type, index) => {
      const permission = permissionsToRequest[index];
      acc[type] = results[permission] === RESULTS.GRANTED;
      return acc;
    }, {} as Record<PermissionType, boolean>);
  },

  showBlockedAlert(type: PermissionType) {
    const titles: Record<PermissionType, string> = {
      camera: 'Camera',
      location: 'Location',
      microphone: 'Microphone',
      photos: 'Photos',
      notifications: 'Notifications',
    };

    Alert.alert(
      `${titles[type]} Permission`,
      `${titles[type]} access is blocked. Please enable it in Settings.`,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Open Settings', onPress: () => openSettings() },
      ]
    );
  },

  openSettings() {
    openSettings();
  },
};

// Usage
const hasCamera = await permissions.check('camera');
const granted = await permissions.request('camera');
```

---

## Best Practices

### Do's

- **Request permissions contextually** - Ask when the feature is needed
- **Handle permission denial gracefully** - Provide alternatives
- **Use background tasks sparingly** - Battery impact
- **Clean up subscriptions** - Prevent memory leaks
- **Cache when possible** - Reduce API calls

### Don'ts

- **Don't request all permissions at startup** - Users will deny
- **Don't ignore errors** - Always handle failures
- **Don't skip platform checks** - Some features are platform-specific
- **Don't forget to unsubscribe** - Location, notifications
- **Don't store sensitive data in file system** - Use SecureStore

## Resources

- [Expo SDK Documentation](https://docs.expo.dev/versions/latest/)
- [React Native Permissions](https://github.com/zoontek/react-native-permissions)
- [Expo Camera](https://docs.expo.dev/versions/latest/sdk/camera/)
- [Expo Notifications](https://docs.expo.dev/versions/latest/sdk/notifications/)
- [Expo Location](https://docs.expo.dev/versions/latest/sdk/location/)
