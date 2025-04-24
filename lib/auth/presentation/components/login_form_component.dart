import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/presentation/styles/styles.dart';
import '../../../core/presentation/utils/riverpod_framework.dart';
import '../../../core/presentation/widgets/custom_elevated_button.dart';
import '../../../gen/assets.gen.dart';
import '../../domain/sign_in_with_vehicle_info.dart';
import '../providers/sign_in_provider.dart';

/// A form component that handles user login with vehicle information.
///
/// This widget provides a login form with fields for name, vehicle number, and phone number.
/// It handles validation of input fields and submits the form data to the sign-in provider.
///
/// Features:
/// - Validates name and vehicle number for non-empty values
/// - Validates phone number format (must be 10-15 digits)
/// - Auto-populates fields if user data is available
/// - Submits validated data to authentication provider
///
/// Usage:
/// ```dart
/// LoginFormComponent()
/// ```
class LoginFormComponent extends HookConsumerWidget {
  const LoginFormComponent({super.key});

  /// Validates if the phone number input meets required format.
  ///
  /// Returns:
  /// - An error message if the value is empty or not 10-15 digits
  /// - null if validation passes
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '필수 입력 값입니다';
    }
    // Regular expression for a valid phone number (10 digits)
    final phoneRegex = RegExp(r'^\d$');

    // Regular expression for a phone number with country code (e.g., +1 123 456 7890)
    // final phoneRegex = RegExp(r'^\+?[0-9]{1,3}?[0-9]{8,12}$');
    final a = phoneRegex.hasMatch(value);
    if (a || (value.length) < 10 || (value.length) > 15) {
      return '숫자 10~15자리로 입력해주세요';
    }

    return null;
  }

  /// Validates if the input field is not empty.
  ///
  /// Returns:
  /// - An error message if the value is empty
  /// - null if validation passes
  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return '필수 입력 값입니다';
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginFormKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: '');
    final vehicleNumberController = useTextEditingController(text: '');
    final phoneNumberController = useTextEditingController(text: '');
    final signInProvider = ref.read(signInStateProvider.notifier);
    useEffect(
      () {
        signInProvider.loadDataDriver().then((v) {
          if (v != null) {
            nameController.text = v.name;
            vehicleNumberController.text = v.vehicleNumber;
            phoneNumberController.text = v.phoneNumber;
          }
        });
        return null;
      },
      [],
    );

    Future<void> signIn() async {
      if (loginFormKey.currentState!.validate()) {
        final params = SignInWithVehicleInfo(
          name: nameController.text,
          vehicleNumber: vehicleNumberController.text,
          phoneNumber: phoneNumberController.text,
        );
        await signInProvider.signIn(params);
      }
    }

    return Form(
      key: loginFormKey,
      child: Column(
        children: [
          TextFormField(
            key: const ValueKey('name'),
            controller: nameController,
            validator: _validate,
            decoration: InputDecoration(
              // hintText: tr(context).email,
              hintText: '이름',
              prefixIcon: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: (Theme.of(context)
                              .inputDecorationTheme
                              .contentPadding
                              ?.horizontal ??
                          50) /
                      2,
                ),
                child: Assets.images.login.imgUser.image(height: 20, width: 20),
              ),
              suffixIconConstraints: const BoxConstraints(),
            ),
            // validator: SignInWithEmail.validateEmail(context),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(
            height: Sizes.marginV24,
          ),
          TextFormField(
            key: const ValueKey('vehicle_number'),
            validator: _validate,
            controller: vehicleNumberController,
            decoration: InputDecoration(
              // hintText: tr(context).password,
              hintText: '차량 번호',
              prefixIcon: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: (Theme.of(context)
                              .inputDecorationTheme
                              .contentPadding
                              ?.horizontal ??
                          50) /
                      2,
                ),
                child:
                    Assets.images.login.imgVehicle.image(height: 20, width: 20),
              ),
              suffixIconConstraints: const BoxConstraints(),
            ),
            textInputAction: TextInputAction.go,
            // obscureText: true,
            onFieldSubmitted:
                ref.isLoading(signInStateProvider) ? null : (_) => signIn(),
          ),
          const SizedBox(
            height: Sizes.marginV24,
          ),
          TextFormField(
            key: const ValueKey('phone_number'),
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*$')),
            ],

            decoration: InputDecoration(
              hintText: '전화번호',
              // hintText: tr(context).password,
              prefixIcon: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: (Theme.of(context)
                              .inputDecorationTheme
                              .contentPadding
                              ?.horizontal ??
                          50) /
                      2,
                ),
                child:
                    Assets.images.login.imgPhone.image(height: 20, width: 20),
              ),
              suffixIconConstraints: const BoxConstraints(),
            ),
            validator: _validatePhoneNumber,
            textInputAction: TextInputAction.go,
            // obscureText: true,
            onFieldSubmitted:
                ref.isLoading(signInStateProvider) ? null : (_) => signIn(),
          ),
          const SizedBox(
            height: Sizes.marginV40,
          ),
          CustomElevatedButton(
            onPressed: (ref.isLoading(signInStateProvider)) ? null : signIn,
            buttonColor: const Color(0xFF1E386D),
            child: Text(
              // tr(context).signIn.toUpperCase(),
              '로그인',
              style: TextStyles.coloredElevatedButton(context),
            ),
          ),
        ],
      ),
    );
  }
}
