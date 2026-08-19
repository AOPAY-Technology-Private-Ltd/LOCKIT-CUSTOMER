class Validators {
  static String? validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number or email';
    }

    String input = value.trim();

    final phoneRegExp = RegExp(r'^[6-9]\d{9}$');

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (phoneRegExp.hasMatch(input) || emailRegExp.hasMatch(input)) {
      return null;
    }

    return 'Enter a valid 10-digit mobile number or email';
  }
}