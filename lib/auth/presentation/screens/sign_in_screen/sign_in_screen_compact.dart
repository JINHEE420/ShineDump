import 'package:flutter/material.dart';

import '../../../../core/presentation/screens/full_screen_scaffold.dart';
import '../../../../core/presentation/styles/styles.dart';
import '../../components/login_content_component.dart';
import '../../components/login_logo_component.dart';

/// A compact version of the sign-in screen designed for smaller screens or portrait mode.
///
/// This widget creates a scrollable sign-in interface with:
/// - A logo component at the top ([LoginLogoComponent])
/// - A content component below that contains the sign-in form ([LoginContentComponent])
///
/// The screen uses a [FullScreenScaffold] with [CustomScrollView] to ensure
/// the content is scrollable when needed, while maintaining a clean white background.
/// Consistent padding and spacing are applied according to the app's design system.
class SignInScreenCompact extends StatelessWidget {
  const SignInScreenCompact({super.key});

  @override
  Widget build(BuildContext context) {
    return const FullScreenScaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Sizes.screenPaddingV16,
                  horizontal: Sizes.screenPaddingH28,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: Sizes.marginV24,
                    ),
                    SizedBox(
                      height: Sizes.marginV24,
                    ),
                    Flexible(
                      child: LoginLogoComponent(),
                    ),
                    SizedBox(
                      height: Sizes.marginV12,
                    ),
                    Flexible(
                      flex: 2,
                      child: LoginContentComponent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
