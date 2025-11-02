class Validators {
  static String? emailValidator(String? val) {
    if (val != null && val.trim().isEmpty) {
      return 'Please input email';
    } else if (val != null &&
        !val.trim().contains(
          RegExp(
            r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)",
            caseSensitive: false,
          ),
        )) {
      return 'Input a valid email!';
    } else {
      return null;
    }
  }

  static String? emptyValidator(String? val) {
    if (val != null && val.trim().isEmpty) {
      return 'Field cannot be empty';
    } else {
      return null;
    }
  }

  static String? integerValidator(String? val) {
    if (val != null && val.trim().isEmpty) {
      return 'Field cannot be empty';
    } else if (val != null && !RegExp(r'^[0-9]+$').hasMatch(val)) {
      return 'Input a valid number';
    } else {
      return null;
    }
  }

  static String? integerWithRangeValidator(String? val, int min, int max) {
    if (val != null && val.trim().isEmpty) {
      return 'Field cannot be empty';
    } else if (val != null && !RegExp(r'^[0-9]+$').hasMatch(val)) {
      return 'Input a valid number';
    } else if (val != null && int.tryParse(val) != null) {
      final intValue = int.parse(val);
      if (intValue < min || intValue > max) {
        return 'Input a number between $min and $max';
      }
    }
    return null;
  }

  static String? integerWithRangeValidatorCanBeEmpty(
    String? val,
    int min,
    int max,
  ) {
    if (val == null) return null;
    if (val.trim().isEmpty) return null;
    if (val.trim().isEmpty) {
      return 'Field cannot be empty';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
      return 'Input a valid number';
    } else if (int.tryParse(val) != null) {
      final intValue = int.parse(val);
      if (intValue < min || intValue > max) {
        return 'Input a number between $min and $max';
      }
    }
    return null;
  }

  static String? integerValidatorCanBeEmpty(String? val) {
    if (val == null) return null;
    if (val.trim().isEmpty) return null;
    if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
      return 'Input a valid number';
    } else {
      return null;
    }
  }

  static String? resetCodeValidator(String? val) {
    if (val != null && val.trim().isEmpty) {
      return 'Field cannot be empty';
    } else if (val != null) {
      // Strip the dash for validation (formatted as XXX-XXX)
      final digitsOnly = val.replaceAll('-', '').trim();
      if (digitsOnly.length != 6) {
        return 'Code must be 6 characters';
      }
    }
    return null;
  }

  static String? ddmmyyyyValidator(String? val) {
    if (val != null && val.trim().isEmpty) {
      return 'Please input date';
    } else if (val != null &&
        !RegExp(
          r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}$',
        ).hasMatch(val)) {
      return 'Input a valid date in DD/MM/YYYY format';
    } else {
      return null;
    }
  }

  static String? requiredAgeValidator(String? val, int requiredAge) {
    if (val != null && val.trim().isEmpty) {
      return 'Please input date';
    } else {
      try {
        final parts = val!.split('/');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final birthDate = DateTime(year, month, day);
        final currentDate = DateTime.now();

        int age = currentDate.year - birthDate.year;
        if (currentDate.month < birthDate.month ||
            (currentDate.month == birthDate.month &&
                currentDate.day < birthDate.day)) {
          age--;
        }

        if (age < requiredAge) {
          return 'You need to be at least $requiredAge years old to use Contree';
        }
      } catch (e) {
        return 'Input a valid date in DD/MM/YYYY format';
      }
    }
    return null;
  }

  static String? phoneNumberValidator(String? val) {
    if (val != null && val.trim().isEmpty) {
      return 'Please input phone number';
    } else if (val != null && !RegExp(r'^\+?[0-9]{10,11}$').hasMatch(val)) {
      return 'Input a valid phone number';
    } else {
      return null;
    }
  }

  static String? passwordValidator(String? val) {
    // at least 6 characters, uppercase, lower case, and special character
    if (val != null && val.trim().isEmpty) {
      return 'Please input password';
    } else if (val != null &&
        !RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&#^()_+\-=\[\]{};:"\\|,.<>\/?])[A-Za-z\d@$!%*?&#^()_+\-=\[\]{};:"\\|,.<>\/?]{6,}$',
        ).hasMatch(val)) {
      return 'Password must be at least 6 characters,\ninclude uppercase, lowercase, number\nand special character';
    } else {
      return null;
    }
  }

  static String? numberOfDigitsValidator(String? val, int requiredLength) {
    if (val != null && val.trim().isEmpty) {
      return 'Field cannot be empty';
    } else if (val != null && val.trim().length != requiredLength) {
      return 'Input must be $requiredLength digits';
    } else {
      return null;
    }
  }
}
