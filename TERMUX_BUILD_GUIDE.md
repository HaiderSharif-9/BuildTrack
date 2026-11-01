# Build BuildTrack APK on Android Phone using Termux

## Prerequisites
- **Termux** app installed from F-Droid or Google Play
- **Storage access permission** for Termux
- **~2-3 GB free space** on phone
- **USB cable** to transfer APK to computer (or email yourself)

## Step-by-Step Build Instructions

### 1. Update Termux
```bash
pkg update && pkg upgrade -y
```

### 2. Install Required Tools
```bash
pkg install -y git openjdk-17 wget
```

### 3. Install Flutter
```bash
mkdir -p ~/dev
cd ~/dev
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter-linux-arm64-release.tar.xz
tar xf flutter-linux-arm64-release.tar.xz
export PATH=$PATH:~/dev/flutter/bin
flutter precache
```

### 4. Verify Installation
```bash
flutter doctor
dart --version
```

### 5. Clone BuildTrack Repository
```bash
cd ~/dev
git clone https://github.com/HaiderSharif-9/BuildTrack.git
cd BuildTrack
```

### 6. Install Dependencies
```bash
flutter pub get
```

### 7. Analyze & Test (Optional, verify everything works)
```bash
flutter analyze
flutter test
```

### 8. Build APK
```bash
# Debug APK (faster)
flutter build apk --debug

# OR Release APK (production, optimized)
flutter build apk --release
```

### 9. Find Your APK
```bash
# APK location:
ls -la build/app/outputs/flutter-apk/

# Copy to accessible location:
cp build/app/outputs/flutter-apk/app-release.apk ~/storage/downloads/
# Or:
cp build/app/outputs/flutter-apk/app-debug.apk ~/storage/downloads/
```

### 10. Transfer APK to Computer
```bash
# Email yourself:
# Go to ~/storage/downloads/ and email the APK

# OR use USB cable:
# Connect phone to computer, find APK in storage/downloads/
```

## Troubleshooting

**"Flutter not found":**
```bash
export PATH=$PATH:~/dev/flutter/bin
# Add to ~/.bashrc for permanent:
echo "export PATH=\$PATH:~/dev/flutter/bin" >> ~/.bashrc
source ~/.bashrc
```

**"Java not found":**
```bash
pkg install -y openjdk-17
```

**"Out of storage":**
- Clear Termux cache: `pkg clean`
- Remove old downloads: `rm -rf ~/downloads/*`
- Build on external SD card if available

**Build fails with "SDK version":**
- Just run: `flutter build apk --debug` (debug version is more compatible)

## Expected Output
After ~10-15 minutes, you'll have:
```
✓ build/app/outputs/flutter-apk/app-debug.apk      (if debug build)
✓ build/app/outputs/flutter-apk/app-release.apk    (if release build)
```

## Next Steps
1. Download APK to your computer
2. Install on phone: `adb install app-release.apk`
3. Test the app
4. Done!

---

**Questions?** All source code and documentation: https://github.com/HaiderSharif-9/BuildTrack
