import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/core_features/locale/presentation/providers/current_app_locale_provider.dart';
import 'core/core_features/locale/presentation/utils/app_locale.dart';
import 'core/core_features/theme/presentation/providers/current_app_theme_provider.dart';
import 'core/infrastructure/services/local_notifications_service.dart';
import 'core/presentation/providers/device_info_providers.dart';
import 'core/presentation/routing/app_router.dart';
import 'core/presentation/routing/navigation_service.dart';
import 'core/presentation/utils/riverpod_framework.dart';
import 'core/presentation/utils/scroll_behaviors.dart';

class MyApp extends StatefulHookConsumerWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

//aa
class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.read(backgroundTaskServiceProvider).stopLocationTracking();
      ref.read(localNotificationsServiceProvider).initialization();
      _initializeAudio();
    });
  }

  Future<void> _initializeAudio() async {
    // Configure audio session for background playback
    try {
      // Set global configuration for AudioPlayer
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );
      debugPrint('Audio configuration initialized for background play');
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  bool get isVietnamese =>
      kDebugMode && const String.fromEnvironment('LANGUAGE') == 'vn';

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    useOnPlatformBrightnessChange((previous, current) {
      ref.read(platformBrightnessProvider.notifier).update((_) => current);
    });
    final supportsEdgeToEdge =
        ref.watch(androidDeviceInfoProvider).supportsEdgeToEdge;
    final themeMode = ref.watch(currentAppThemeModeProvider);
    final locale = ref.watch(currentAppLocaleProvider);

    return MaterialApp.router(
      routerConfig: router,
      restorationScopeId: 'app',
      builder: (_, child) {
        return ScrollConfiguration(
          behavior: MainScrollBehavior(),
          child: GestureDetector(
            onTap: NavigationService.removeFocus,
            child: child,
          ),
        );
      },
      title: 'GPS Tracking',
      debugShowCheckedModeBanner: false,
      color: Theme.of(context).colorScheme.primary,
      theme: themeMode.getThemeData(
        locale.fontFamily,
        supportsEdgeToEdge: supportsEdgeToEdge,
      ),
      // locale: Locale(locale.code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale:
          Locale(isVietnamese ? AppLocale.english.code : AppLocale.korean.code),
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
