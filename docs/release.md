# Release & Signing Guide — T2 Rental

This document explains how to generate a release signing keystore, configure release signing, build a universal release APK, verify the signature, install updates on client devices, and troubleshoot installation errors.

---

> [!CAUTION]
> **CRITICAL: BACK UP YOUR KEYSTORE AND PASSWORDS SECURELY OUTSIDE THIS REPOSITORY.**
>
> If you lose the keystore file (`.jks`) or its passwords:
> - You will **NEVER** be able to update an existing installation on any customer/staff phone without uninstalling the app first.
> - Uninstalling the app deletes all local SQLite database records and stored customer National ID photos.
> - Store backup copies of the keystore and passwords in a secure password manager or offline encrypted storage. **NEVER commit the keystore or `key.properties` to Git.**

---

## 1. Prerequisites

- Flutter SDK (stable) & Android SDK (minSdk 24).
- Java Development Kit (JDK 17+) with `keytool`.

---

## 2. Generating a Production Keystore

Run the following command in terminal (PowerShell or Bash) to generate a private signing key:

```powershell
keytool -genkey -v -keystore C:\Users\HCS\t2-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias t2_rental_key
```

You will be prompted for:
1. Keystore password (choose a strong password and save it).
2. Key password (press Enter to use the same password as keystore).
3. Organizational details (e.g., your name / organization: `Yonas Tigistu` / `T2 Rental`).
4. Confirmation (`yes`).

Store this `.jks` file in a secure location outside the repository (e.g. `C:\Users\HCS\t2-release-key.jks`).

---

## 3. Configuring `android/key.properties`

Create a file at `android/key.properties` (based on `android/key.properties.example`):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=t2_rental_key
storeFile=C:/Users/HCS/t2-release-key.jks
```

*Note on Windows paths:* In `storeFile`, use forward slashes `/` (e.g., `C:/Users/HCS/t2-release-key.jks`) or escape backslashes `C:\\Users\\HCS\\t2-release-key.jks`.

`android/key.properties` and all `*.jks` files are ignored by `.gitignore` and must never be committed.

---

## 4. Building the Universal Release APK

To produce a single universal release APK that can be installed on any supported Android phone:

```powershell
flutter build apk --release
```

- Output path: `build/app/outputs/flutter-apk/app-release.apk`
- The build produces a universal APK containing native code for all device architectures (`arm64-v8a`, `armeabi-v7a`, `x86_64`).

> [!NOTE]
> If `android/key.properties` is missing when attempting a release build, the build will fail with an explicit error message prompting you to create it. Debug builds (`flutter run`) continue to work without `key.properties`.

---

## 5. Bumping App Version for Updates

Android requires `versionCode` to increase for every new release to allow installing updates over existing versions:

Open `pubspec.yaml` and update the `version` field:

```yaml
version: 1.0.1+2
```

- **`1.0.1`** is `versionName` (visible to the user in Android Settings).
- **`2`** is `versionCode` (an integer that **must increase** with every release: 1, 2, 3...).

Always commit and tag version bumps before building the release APK.

---

## 6. Verifying the Signing Certificate

Before distributing the APK to a device, verify that it was signed with your release key (not a debug key):

### Using `keytool`:
```powershell
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

Look for:
- `Owner: CN=..., O=T2 Rental` (matches what you typed when creating the keystore).
- It should **not** say `CN=Android Debug, O=Android`.

### Using Android SDK `apksigner`:
```powershell
apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-release.apk
```

---

## 7. Installing on Devices & Updates

### First-Time Install:
1. Transfer `app-release.apk` to the phone (via USB cable, Google Drive, Telegram, or WhatsApp).
2. Open the file on the phone.
3. If prompted with **"Install unknown apps"**, tap **Settings** and enable **"Allow from this source"**.
4. If Android Play Protect shows **"Unrecognized app"** or **"Blocked by Play Protect"**, tap **"More details"** -> **"Install anyway"**. This warning is standard for apps distributed directly outside Google Play Store.

### Installing Updates Over Previous Releases:
1. **NEVER uninstall the previous version.** Uninstalling deletes the SQLite database containing active rentals, customer records, and ID photos.
2. Simply open the new `app-release.apk` on the phone.
3. Android will prompt: *"Do you want to update this app? Your existing data will not be lost."*
4. Tap **Update**.
5. Drift's automated migrations will migrate the database safely while preserving all data.

---

## 8. Installation Troubleshooting

| Issue / Error | Cause | Solution |
|---|---|---|
| **"App not installed: An existing package by the same name with a conflicting signature is already installed"** | The phone has a build signed with a different key (e.g. debug key vs release key, or a different release keystore). | Android blocks signature mismatches for security. If migrating from debug to release on a test device, back up data via Settings -> Backup & restore first, uninstall the debug version, install the release version, and restore the backup. Future updates signed with the same release key will update directly without uninstalling. |
| **"App not installed: The package appears to be corrupt" / Parse error** | APK download was incomplete or phone's Android version is below `minSdk 24` (Android 7.0). | Re-transfer the APK file to the device. Ensure the device runs Android 7.0 (Nougat) or newer. |
| **"Blocked by Play Protect"** | Google Play Protect does not recognize privately distributed sideloaded APKs. | Tap **"More details"** and select **"Install anyway"**. |
| **"Install blocked / Unknown sources"** | Android security settings prevent installing apps from file managers or browsers by default. | Go to Settings -> Apps -> Special app access -> Install unknown apps -> Enable for the app you used to open the APK (e.g. Files by Google or Chrome). |
| **"App not installed: The new package has an older version code"** | The `versionCode` in `pubspec.yaml` is equal to or lower than the currently installed version. | Increase the version code in `pubspec.yaml` (e.g. `version: 1.0.2+3`) and rebuild. |

