import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'app.dart';
import 'core/infrastructure/local/shared_preferences_facade.dart';
import 'core/infrastructure/services/logger.dart';
import 'core/presentation/extensions/future_extensions.dart';
import 'core/presentation/providers/device_info_providers.dart';
import 'core/presentation/providers/provider_observers.dart';
import 'core/presentation/screens/splash_screen/splash_screen.dart';
import 'core/presentation/utils/riverpod_framework.dart';
import 'features/home/infrastructure/data_sources/gps_local_data_source.dart';
import 'firebase_options.dart';
import 'pip_home_page.dart';

part 'core/infrastructure/services/main_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reset to default orientations 화면 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  //이 코드는 Flutter 앱에서 Flutter 프레임워크 외부에서 발생하는 비동기 오류를 Firebase Crashlytics로 전송하기 위한 설정입니다
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // SQLite 등 로컬 DB를 초기화해서 GPS 데이터를 저장할 수 있도록 준비
  await GpsLocalDatabase.ensureInitialized();

  final container = await _mainInitializer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: !Platform.isAndroid
          ? const MyApp() // iOS 앱 실행
          : const PiPSwitcher(
              // Android에서 PiP 지원
              childWhenDisabled: MyApp(), // PiP 비활성: 기본 앱
              childWhenEnabled: PiPHomePage(
                // PiP 활성: 작은 화면 전용 위젯
                width: 250,
                height: 500,
              ),
            ),
    ),
  );
}
