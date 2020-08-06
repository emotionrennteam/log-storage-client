# emotion

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Flutter on Windows

1. Installations:

   1. Git

   2. VSCode

   3. Flutter: https://medium.com/flutter-community/flutter-for-desktop-create-and-run-a-desktop-application-ebeb1604f1e0, https://github.com/flutter/flutter/wiki/Desktop-shells

      1. Download Flutter Dev channel (Windows) [1.20.0-2.0.pre](https://storage.googleapis.com/flutter_infra/releases/dev/windows/flutter_windows_1.20.0-2.0.pre-dev.zip)
      2. Unzip, add to PATH https://flutter.dev/docs/get-started/install/windows

      ```bash
      flutter channel master
      flutter upgrade
      flutter doctor
      # follow all instructions provided by Flutter Doctor (no need to install Android Studio though)
      flutter create emotion
      cd emotion
      flutter create --platforms=windows .
      flutter run
      ```

## Debugging

1. Start per command line:
   ```bash
   cd $PROJECT_DIR
   flutter run
   ```
2. Stop the app
3. Open Visual Studio Code
4. Open any `*.dart` file
5. Hit F5 to start debugging
6. Download MinIO Server from https://min.io/download#/windows
7. Start Minio Server:
   ```bash
   mkdir data/
    ./minio.exe server data/
    ```
8. You can access the MinIO Browser on http://127.0.0.1:9000.







TODO: 
* Fix examples in https://github.com/xtyxtyx/minio-dart/blob/master/lib/src/minio.dart
