import 'package:flutter/material.dart';

import '../../../../core/presentation/screens/full_screen_scaffold.dart';
import '../../../../core/presentation/styles/styles.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../utils/style.dart';
import '../../providers/auth_state_provider.dart';

/// ProfileScreen displays the user's profile information retrieved from the auth state.
///
/// This screen shows the authenticated user's personal information including:
/// - Name
/// - Vehicle number
/// - Phone number
///
/// The screen uses [authStateProvider] to access and display the current user's profile data.
/// It monitors authentication state changes and updates the UI accordingly.
///
/// The UI consists of:
/// - An AppBar with a title and back navigation button
/// - A styled container with profile information fields
/// - Each field is displayed with a title and corresponding value
///
/// This screen is part of the authentication flow and provides users with
/// a way to verify their current profile information is correct.
class ProfileScreen extends StatefulHookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final listenable = ValueNotifier<bool?>(null);

    ref.listen(
      authStateProvider.select((user) => user),
      (_, isAuthenticated) {
        print('isAuthenticated');
        print(isAuthenticated);
        listenable.value = isAuthenticated.isSome();
      },
    );

    final profile = ref.watch(authStateProvider.select((v) => v)).toNullable();

    return FullScreenScaffold(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            '서류',
            style: gpsTextStyle(
              weight: FontWeight.w900,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Sizes.screenPaddingV16,
                    horizontal: Sizes.screenPaddingH28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 5,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.1), // shadow color
                              //color: Colors.black.withValues(alpha: 0.1), 이렇게 수정해도 똑같음.
                              blurRadius: 10, // blur radius
                              spreadRadius: 2, // spread of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitle('이름'),
                            _buildValue(profile?.name),
                            _buildTitle('차량 번호'),
                            _buildValue(profile?.vehicleNumber),
                            _buildTitle('전화번호'),
                            _buildValue(profile?.phoneNumber),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildValue(String? value) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade50,
      ),
      child: Text(
        value ?? '',
        style: gpsTextStyle(weight: FontWeight.w500, fontSize: 19),
      ),
    );
  }

  Container _buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),
      child: Text(
        title,
        style: gpsTextStyle(weight: FontWeight.w700, fontSize: 18),
      ),
    );
  }
}
