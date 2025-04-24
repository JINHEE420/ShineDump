import 'package:flutter/material.dart';

import '../../../../core/presentation/screens/full_screen_scaffold.dart';
import '../../../../core/presentation/styles/styles.dart';
import '../../../../gen/my_assets.dart';
import '../../components/login_content_component.dart';
import '../../components/login_logo_component.dart';

/// A sign-in screen implementation optimized for medium-sized devices such as tablets.
///
/// This widget creates a horizontally split layout with:
/// - A logo section on the left side (2/5 of the width)
/// - A login content section on the right side (3/5 of the width)
///
/// The screen uses a custom background image and is designed to be part of a
/// responsive UI system where different layouts are used based on screen size.
class SignInScreenMedium extends StatelessWidget {
  /// Creates a sign-in screen for medium-sized devices.
  const SignInScreenMedium({super.key});

  @override

  /// Builds the sign-in screen layout with a row arrangement of logo and login content.
  ///
  /// The layout uses [FullScreenScaffold] with a custom background image and
  /// horizontally arranges the [LoginLogoComponent] and [LoginContentComponent]
  /// with appropriate flex values for medium-sized displays.
  Widget build(BuildContext context) {
    return FullScreenScaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    MyAssets.ASSETS_IMAGES_LOGIN_LOGIN_BACKGROUND_PNG,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Sizes.screenPaddingV16,
                  horizontal: Sizes.screenPaddingH28,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: LoginLogoComponent(),
                    ),
                    SizedBox(
                      width: Sizes.marginH16,
                    ),
                    Flexible(
                      flex: 3,
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
