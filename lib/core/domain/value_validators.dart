import 'package:flutter/material.dart';

import '../presentation/helpers/localization_helper.dart';

/// A utility class that provides form field validation methods.
///
/// This class contains static methods that return validation functions for
/// common form fields such as email, password, mobile number, and name.
/// These validation methods can be directly used with Flutter's form fields.
///
/// Example usage:
/// ```dart
/// TextFormField(
///   decoration: InputDecoration(labelText: 'Email'),
///   validator: ValueValidators.validateEmail(context),
/// )
/// ```
class ValueValidators {
  /// Validates email addresses using a regular expression pattern.
  ///
  /// Returns a validator function that checks if the input:
  /// - Is not empty
  /// - Matches standard email format (user@domain.com)
  ///
  /// Returns an error message if validation fails, null otherwise.
  static FormFieldValidator<String?> validateEmail(BuildContext context) {
    const patternEmail = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
    return (value) {
      if (value!.isEmpty) {
        return tr(context).thisFieldIsEmpty;
      } else if (!checkPattern(pattern: patternEmail, value: value)) {
        return tr(context).pleaseEnterValidEmail;
      } else {
        return null;
      }
    };
  }

  /// Validates login password.
  ///
  /// Returns a validator function that only checks if the password is not empty.
  /// For more complex password validation, see other validation methods.
  ///
  /// Returns an error message if validation fails, null otherwise.
  static FormFieldValidator<String?> validateLoginPassword(
      BuildContext context) {
    return (value) {
      if (value!.isEmpty) {
        return tr(context).thisFieldIsEmpty;
      } else {
        return null;
      }
    };
  }

  /// Validates mobile number format.
  ///
  /// Returns a validator function that checks if the input:
  /// - Is not empty
  /// - Follows a valid mobile number format (10-15 digits)
  /// - Handles international formats with + prefix
  /// - Supports both Arabic and English numerals
  ///
  /// Returns an error message if validation fails, null otherwise.
  static FormFieldValidator<String?> validateMobileNumber(
      BuildContext context) {
    const patternMobileNumber = r'^(?:[+0]9)?[0-9|٩|٠|١|٢|٣|٤|٥|٦|٧|٨]{10,15}$';
    return (value) {
      value = value?.trim();
      if (value!.isEmpty) {
        return tr(context).thisFieldIsEmpty;
      } else if (value.contains('+') &&
          value.contains(RegExp('[0-9]|٩|٠|١|٢|٣|٤|٥|٦|٧|٨')) &&
          !value.contains(RegExp('[a-zA-Z]')) &&
          !value.contains(RegExp('[ء-ي]'))) {
        return tr(context).pleaseEnterValidNumber;
      } else if (!value.contains(RegExp('[a-zA-Z]')) &&
          value.contains(RegExp('[0-9]|٩|٠|١|٢|٣|٤|٥|٦|٧|٨')) &&
          !value.contains('+') &&
          !value.contains(RegExp('[ء-ي]'))) {
        if (!checkPattern(pattern: patternMobileNumber, value: value)) {
          return tr(context).pleaseEnterValidNumber;
        }
      }
      return null;
    };
  }

  /// Validates name format.
  ///
  /// Returns a validator function that checks if the input:
  /// - Is not empty
  /// - Has at least 2 characters
  /// - Has at most 30 characters
  /// - Contains only valid name characters (letters in English or Arabic, spaces, commas, periods, hyphens)
  ///
  /// Returns an error message if validation fails, null otherwise.
  static FormFieldValidator<String?> validateName(BuildContext context) {
    //english name: r'^[a-zA-Z,.\-]+$'
    //arabic name: r'^[\u0621-\u064A\040]+$'
    //english and arabic names
    const patternName = r'^[\u0621-\u064A\040\a-zA-Z,.\-]+$';
    return (value) {
      if (value!.isEmpty) {
        return tr(context).thisFieldIsEmpty;
      } else if (value.length < 2) {
        return tr(context).nameMustBeAtLeast2Letters;
      } else if (value.length > 30) {
        return tr(context).nameMustBeAtMost30Letters;
      } else if (!checkPattern(pattern: patternName, value: value)) {
        return tr(context).pleaseEnterValidName;
      } else {
        return null;
      }
    };
  }

  /// Checks if a string contains only numeric characters (positive or negative integers).
  ///
  /// Returns true if the string is a valid integer, false otherwise.
  static bool isNumeric(String str) {
    const patternInteger = r'^-?[0-9]+$';
    return checkPattern(pattern: patternInteger, value: str);
  }

  /// Checks if a string contains only positive numeric characters (greater than zero).
  ///
  /// Returns true if the string is a valid positive integer, false otherwise.
  static bool isNumericPositive(String str) {
    const patternPositiveInteger = r'^[1-9]\d*$';
    return checkPattern(pattern: patternPositiveInteger, value: str);
  }

  /// Utility method to check if a string matches a given regular expression pattern.
  ///
  /// Parameters:
  /// - [pattern]: The regular expression pattern to check against
  /// - [value]: The string value to validate
  ///
  /// Returns true if the value matches the pattern, false otherwise.
  static bool checkPattern({required String pattern, required String value}) {
    final regularCheck = RegExp(pattern);
    return regularCheck.hasMatch(value);
  }
}
