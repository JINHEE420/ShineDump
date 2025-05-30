import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core_features/theme/presentation/providers/current_app_theme_provider.dart';
import '../../core_features/theme/presentation/utils/app_theme.dart';
import '../helpers/theme_helper.dart';
import '../providers/device_info_providers.dart';
import '../utils/riverpod_framework.dart';
import '../widgets/status_bar_spacer.dart';

class FullScreenScaffold extends ConsumerStatefulWidget {
  const FullScreenScaffold({
    required this.body,
    this.hasStatusBarSpace = false,
    this.statusBarColor,
    this.darkOverlays,
    this.setOlderAndroidImmersiveMode = false,
    super.key,
  });

  final Widget body;
  final bool hasStatusBarSpace;
  final Color? statusBarColor;
  final bool? darkOverlays;
  final bool setOlderAndroidImmersiveMode;

  @override
  ConsumerState<FullScreenScaffold> createState() => _FullScreenScaffoldState();
}

class _FullScreenScaffoldState extends ConsumerState<FullScreenScaffold> {
  late final bool supportsEdgeToEdge;

  @override
  void initState() {
    super.initState();
    supportsEdgeToEdge = ref.read(androidDeviceInfoProvider).supportsEdgeToEdge;
    if (!supportsEdgeToEdge && widget.setOlderAndroidImmersiveMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  void dispose() {
    if (!supportsEdgeToEdge && widget.setOlderAndroidImmersiveMode) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(currentAppThemeModeProvider);
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.hasStatusBarSpace
          ? StatusBarSpacer(statusBarColor: widget.statusBarColor)
          : null,
      body: AnnotatedRegion(
        value: getFullScreenOverlayStyle(
          context,
          darkOverlays:
              widget.darkOverlays ?? currentTheme == AppThemeMode.light,
          supportsEdgeToEdge: supportsEdgeToEdge,
        ),
        child: widget.body,
      ),
    );
  }
}
