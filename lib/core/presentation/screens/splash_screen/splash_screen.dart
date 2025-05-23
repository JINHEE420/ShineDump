import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../gen/my_assets.dart';
import '../../hooks/fade_in_controller_hook.dart';
import '../../providers/splash_providers.dart';
import '../../routing/app_router.dart';
import '../../utils/riverpod_framework.dart';
import '../../widgets/responsive_widgets/responsive_layouts.dart';
import 'splash_screen_compact.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

// 앱 시작 시 스플래시 이미지를 메모리에 미리 올려둬서 실제 화면에 띄울 때 로딩 지연 없이 바로 보여주도록 합니다.
  static Future<void> precacheAssets(BuildContext context) async {
    await precacheImage(
        const AssetImage(MyAssets.ASSETS_IMAGES_CORE_CUSTOM_SPLASH_PNG),
        context);
  }

  static const setOlderAndroidImmersiveMode = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWarmedUp = !ref.isLoading(splashServicesWarmupProvider);
    if (isWarmedUp) {
      ref.listen<AsyncValue<String>>(
        splashTargetProvider, // 다음 화면 경로 결정(splashTargetProvider) → GoRouter로 이동
        (prevState, newState) {
          late String nextRoute;
          newState.whenOrNull(
            data: (next) => nextRoute = next,
            error: (e, st) => nextRoute = const NoInternetRoute().location,
          );
          context.go(nextRoute);
        },
      );
    }

    final fadeController = useFadeInController();

    return WindowClassLayout(
      compact: (_) => OrientationLayout(
        portrait: (_) => SplashScreenCompact(
          fadeInController: fadeController,
        ),
      ),
    );
  }
}
