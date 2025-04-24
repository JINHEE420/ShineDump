import 'package:flutter/material.dart';

import '../../../../../core/presentation/utils/riverpod_framework.dart';
import 'home_screen_compact.dart';

/// A [StatefulHookConsumerWidget] that represents the main home screen of the app.
///
/// This widget uses Riverpod for state management and delegates its UI to
/// [HomeScreenCompact], which provides a compact version of the home screen layout.
class HomeScreen extends StatefulHookConsumerWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

/// The state class for [HomeScreen].
///
/// This class builds the UI by rendering the [HomeScreenCompact] widget.
class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const HomeScreenCompact();
  }
}
