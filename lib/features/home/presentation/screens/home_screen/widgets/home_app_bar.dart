import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../../../../auth/presentation/providers/sign_in_provider.dart';
import '../../../../../../auth/presentation/screens/profile_screen/profile_screen.dart';
import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/widgets/app_dialog.dart';
import '../../../../../../core/presentation/widgets/custom_elevated_button.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../utils/constant.dart';
import '../../../../../../utils/style.dart';
import '../../../providers/trip_provider/trip_provider.dart';

/// A custom [AppBar] widget for the home screen.
///
/// Displays a profile button and a logout button (conditionally).
/// The profile button navigates to the profile screen, while the logout button
/// allows the user to log out of the application.
class HomeAppBar extends AppBar {
  /// Creates a [HomeAppBar].
  ///
  /// Requires a [WidgetRef] to access Riverpod providers.
  HomeAppBar({
    required WidgetRef ref,
    super.key,
  }) : super(
          leading: const SizedBox(),
          centerTitle: true,
          title: const _ProfileButton(),
          actions: [
            if (ref.watch(
              tripManagerProvider.select((s) => s.toNullable()?.trip == null),
            ))
              const _LogoutButton(),
          ],
        );
}

/// A button widget that displays the user's profile information.
///
/// When pressed, it navigates to the profile screen.
class _ProfileButton extends ConsumerWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(authStateProvider.select((s) => s.toNullable()));

    return SizedBox(
      width: 175,
      child: CustomElevatedButton(
        onPressed: () => _navigateToProfile(context),
        borderColor: const Color(0xFFE5E5E5).withOpacity(.5),
        buttonColor: Colors.white,
        borderRadius: BorderRadius.circular(60),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        child: _buildButtonContent(driver?.name ?? ''),
      ),
    );
  }

  /// Builds the content of the profile button, including the user's name.
  Widget _buildButtonContent(String? userName) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Assets.icons.icUser.image(width: 35),
          Expanded(
            child: Text(
              userName ?? '',
              style: gpsTextStyle(
                weight: FontWeight.w500,
                fontSize: 16,
                lineHeight: 19.2,
                color: const Color(0xFF352555),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to the profile screen.
  Future<void> _navigateToProfile(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }
}

/// A button widget that displays a logout option.
///
/// When pressed, it shows a confirmation dialog for logging out.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: defaultPadding),
      alignment: Alignment.center,
      height: 80,
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Text(
          tr(context).logout,
          style: gpsTextStyle(
            weight: FontWeight.w900,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Displays a confirmation dialog for logging out.
  void _showLogoutDialog(BuildContext context) {
    AppDialog.showDialog(
      context,
      const _LogoutDialog(),
      maxHeight: 210,
    );
  }
}

/// A dialog widget that confirms the user's intent to log out.
///
/// Provides "Yes" and "No" options for the user.
class _LogoutDialog extends ConsumerWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context).logoutTitle,
            style: gpsTextStyle(
              weight: FontWeight.w700,
              fontSize: 20,
              lineHeight: 21,
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: 45,
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Text(tr(context).logoutConfirmation),
          ),
          Row(
            children: [
              Expanded(
                child: _buildNoButton(context),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: _buildYesButton(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the "No" button for the logout dialog.
  Widget _buildNoButton(BuildContext context) {
    return CustomElevatedButton(
      buttonColor: Colors.white,
      borderColor: Colors.grey,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      onPressed: () => context.pop(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Assets.icons.icCloseSquare.image(width: 20),
          Text(
            tr(context).no,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Yes" button for the logout dialog.
  Widget _buildYesButton(BuildContext context, WidgetRef ref) {
    return CustomElevatedButton(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      onPressed: () async {
        context.pop();
        await ref.read(signInStateProvider.notifier).signout();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Assets.icons.icChecked.image(width: 20),
          Text(
            tr(context).yes,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
