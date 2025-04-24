import 'package:flutter/material.dart';

import '../../../../../../core/presentation/styles/styles.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../utils/constant.dart';

/// A widget that represents an action panel with an optional title, subtitle,
/// icon, and a callback function for user interaction.
///
/// The `ActionPanel` is a customizable container that displays a title,
/// subtitle, and an optional icon. It also supports a callback function
/// that is triggered when the panel is tapped.
///
/// Example usage:
/// ```dart
/// ActionPanel(
///   title: 'Settings',
///   subTitle: 'Manage your preferences',
///   icon: Icon(Icons.settings),
///   callback: () {
///     print('Panel tapped');
///   },
/// )
/// ```
class ActionPanel extends StatelessWidget {
  /// Creates an [ActionPanel].
  ///
  /// The [enable] parameter defaults to `true` if not provided.
  const ActionPanel({
    super.key,
    this.title,
    this.subTitle,
    this.icon,
    this.callback,
    this.enable = true,
  });

  /// The title text displayed in the panel.
  final String? title;

  /// The subtitle text displayed below the title.
  final String? subTitle;

  /// An optional icon displayed at the start of the panel.
  final Widget? icon;

  /// A callback function triggered when the panel is tapped.
  final VoidCallback? callback;

  /// Whether the panel is enabled or not. Defaults to `true`.
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // shadow color
              blurRadius: 10, // blur radius
              spreadRadius: 2, // spread of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding * 1.5,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: icon,
                  ),
                  const SizedBox(width: 30),
                ],
                const SizedBox(width: Sizes.marginH4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 20.4 / 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (subTitle != null)
                        Text(
                          subTitle ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 20.4 / 15,
                            color: Colors.grey[500],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24, // Constrain the forward icon size
                  height: 24,
                  child: Assets.icons.icForward.image(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
