import 'package:flutter/material.dart';

import '../../../core/core_features/theme/presentation/utils/custom_colors.dart';
import '../../../core/presentation/helpers/localization_helper.dart';
import '../../../core/presentation/styles/styles.dart';
import '../../../gen/my_assets.dart';

/// A widget that displays a welcome message for the authentication screen.
///
/// This component creates a welcome header with the following elements:
/// - A welcome text that uses the primary theme color
/// - A hand wave image asset positioned at the end of the welcome text
/// - A sign-in instruction text below the welcome message
///
/// The component uses localized strings through the translation helper.
class WelcomeComponent extends StatelessWidget {
  const WelcomeComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                tr(context).welcome,
                style: TextStyles.f20(context).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Image.asset(
              MyAssets.ASSETS_IMAGES_LOGIN_HI_HAND_PNG,
              height: 44,
              width: 44,
              fit: BoxFit.contain,
            ),
          ],
        ),
        const SizedBox(
          height: Sizes.marginV12,
        ),
        Text(
          tr(context).signInToYourAccount,
          style: TextStyles.f16SemiBold(context)
              .copyWith(color: customColors(context).greyColor),
        ),
      ],
    );
  }
}
