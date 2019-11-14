# flutter_journal_demo
A simple cross-platform Flutter app 

Configured currently for Mobile build (because of Firebase dependencies)

To run a web build:
  1) Uncomment targeted lines in 'FirebaseWrapper.dart'
  2) Uncomment 'firebase: ^6.0.0' in 'pubspec.yaml'
  3) Run 'flutter pub get'
  
To return to running a mobile build:
  1) Comment targeted lines in 'FirebaseWrapper.dart'
  2) Comment 'firebase: ^6.0.0' in 'pubspec.yaml'
  3) Run 'flutter pub get
