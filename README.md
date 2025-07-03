
flutter run --flavor ko

flutter run --flavor ko --release

// aab 생성 명령어
flutter build appbundle --flavor ko --dart-define-from-file=env/ko.env

// xcode(앱스토어) 한국환경 ipa 생성 명령어
flutter build ipa --release --dart-define-from-file=env/ko.env