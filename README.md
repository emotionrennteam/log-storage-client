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

1. Open Visual Studio Code
2. Open any `*.dart` file
3. Hit F5 to start debugging
4. Download MinIO Server from https://min.io/download#/windows
5. Start Minio Server:
   ```bash
   mkdir data/
    ./minio.exe server data/
    ```
6. You can access the MinIO Browser on http://127.0.0.1:9000. The default credentials are:
   * User: `minioadmin`
   * Password: `minioadmin`

TODO: 
* Fix examples in https://github.com/xtyxtyx/minio-dart/blob/master/lib/src/minio.dart

## File Picker Workaround

* Follow the instructions on https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#--desktop-go-flutter:
   * Install Go
   * Install Hover: `GO111MODULE=on go get -u -a github.com/go-flutter-desktop/hover`
   * Hover requires the installation of GCC. For this purpose, [install Cygwin](https://sourceware.org/cygwin/install.html).
   * The gcc version of Cygwin somehow didn't work with Hover. Instead, I had to use [tdm-gcc](https://jmeubank.github.io/tdm-gcc/) as denoted [here on StackOverflow](https://stackoverflow.com/questions/44605108/any-ideas-how-to-solve-this-cygwin-go-build-error).
   * Excecute hover in Cygwin:
      ```bash
      hover init
      hover run
      hover build windows
      ```
   * Edit `./go/cmd/options.go`.
