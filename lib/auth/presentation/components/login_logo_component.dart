import 'package:flutter/material.dart';

import '../../../core/presentation/styles/styles.dart';
import '../../../gen/my_assets.dart';

/// A widget that displays the application logo in the login screen.
///
/// This component is designed to be used within login-related screens
/// to consistently present the app's branding. It displays the app logo
/// with full width coverage and adds standard vertical spacing below it.
///
/// Example usage:
/// ```dart
/// Column(
///   children: [
///     const LoginLogoComponent(),
///     // Other login form elements
///   ],
/// )
/// ```
class LoginLogoComponent extends StatelessWidget {
  /// Creates a login logo component.
  ///
  /// The component displays the app logo and adds standard spacing below it.
  const LoginLogoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          MyAssets.ASSETS_IMAGES_CORE_APP_LOGO_PNG,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const SizedBox(
          height: Sizes.marginV12,
        ),
      ],
    );
  }
}
