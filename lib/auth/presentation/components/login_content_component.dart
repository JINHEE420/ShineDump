import 'package:flutter/material.dart';

import '../../../core/presentation/styles/styles.dart';
import 'login_form_component.dart';

/// A widget that displays the main content for the login screen.
///
/// This component serves as a container for login-related UI elements,
/// constraining them to a maximum width for better presentation across
/// different screen sizes. It includes:
///
/// * A vertical spacing element (SizedBox)
/// * The [LoginFormComponent] which contains the actual login form fields
///
/// The content is centered and constrained to [Sizes.maxWidth360] to ensure
/// a consistent layout on various devices.
class LoginContentComponent extends StatelessWidget {
  const LoginContentComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: Sizes.maxWidth360,
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: Sizes.marginV32,
          ),
          LoginFormComponent(),
        ],
      ),
    );
  }
}
