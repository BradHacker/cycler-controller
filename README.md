# Cycler Controller

This app is developed to control Waste Management's Cycler robot.

## Prerequisites

- [Flutter](https://flutter.dev/)
- [Android Studio](https://developer.android.com/studio)
- [Xcode](https://developer.apple.com/xcode/) (Mac only, needed for ios development)

**Make sure to follow the installation instructions found [here](https://flutter.dev/docs/get-started/install) first before continuing**

## Setup

Run the following code to generate a keystore for your machine:

Mac / Linux
```
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Windows
```
keytool -genkey -v -keystore c:/Users/USER_NAME/key.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Create a file `<app-dir>/android/key.properties` that references your keystore from the previous step

```
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=key
storeFile=<location of the key store file, such as /Users/<user name>/key.jks>
```

## Installation

Plug in your device over USB (ensure USB debugging is enabled), then inside your projects directory run `flutter install`