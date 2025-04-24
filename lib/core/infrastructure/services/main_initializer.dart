part of '../../../main.dart';

Future<ProviderContainer> _mainInitializer() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  _setupLogger();
  await _initFirebase();

  final container = ProviderContainer(observers: [
    ProviderLogger(),
    ProviderCrashlytics()
  ]); // (ProviderContainer) 앱 전체 상태 관리 (Riverpod)

  // Warming-up androidDeviceInfoProvider to be used synchronously at AppTheme to setup the navigation bar
  // behavior for older Android versions without flickering (of the navigation bar) when app starts.

  // Riverpod 상태 관리 컨테이너 생성, 상태 변경 로깅 및 오류 기록을 위한 관찰자(observer) 설정
  await container.read(androidDeviceInfoProvider.future).suppressError();
  // Warming-up sharedPrefsAsyncProvider to be used synchronously at theme/locale. Not warming-up this
  // at splashServicesWarmup as theme/locale is used early at SplashScreen (avoid theme/locale flickering).

  // device_info_plus와 SharedPreferences 데이터를 미리 로드해 두어 앱 초기에 깜빡이거나 깨어나는 현상(flickering)을 줄임
  await container.read(sharedPrefsAsyncProvider.future).suppressError();

  // This Prevent closing native splash screen until we finish warming-up custom splash images.
  // App layout will be built but not displayed.
  // Splash 화면 제어
  widgetsBinding.deferFirstFrame();
  widgetsBinding.addPostFrameCallback((_) async {
    // Run any function you want to wait for before showing app layout.
    final BuildContext context = widgetsBinding.rootElement!;
    await _precacheAssets(context);

    // When the native splash screen is fullscreen, iOS will not automatically show the notification
    // bar when the app loads. To show it, setEnabledSystemUIMode has to be explicitly set:
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode
          .edgeToEdge, // https://github.com/flutter/flutter/issues/105714
    );

    // Closes splash screen, and show the app layout.
    widgetsBinding.allowFirstFrame();
  });

  // init PIP

  return container;
}

// Dart logging 패키지를 기반으로 로그 필터링/컬러 출력 등을 구성함
void _setupLogger() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord r) {
    if (r.loggerName.isEmpty) {
      loggerOnDataCallback()?.call(r);
    }
  });
}

Future<void> _initFirebase() async {
  // 향후 Firebase Messaging 등 사용 시 활성화 예정
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // // Set the background messaging handler early on, as a named top-level function
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// SplashScreen에 필요한 이미지들 먼저 메모리에 올려 깜빡임 제거
Future<void> _precacheAssets(BuildContext context) async {
  await <Future<void>>[
    SplashScreen.precacheAssets(context),
  ].wait.suppressError();
}

/// This provided handler must be a top-level function.
/// It works outside the scope of the app in its own isolate.
/// More details: https://firebase.google.com/docs/cloud-messaging/flutter/receive#background_messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    /* RemoteMessage */ message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  /*await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/
  log('Handling a background message ${message.messageId}');
}
