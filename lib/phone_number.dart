import 'countries.dart';

class NumberTooLongException implements Exception {}

class NumberTooShortException implements Exception {}

class InvalidCharactersException implements Exception {}

class PhoneNumber {
  String countryISOCode;
  String countryCode;
  String number;

  PhoneNumber({
    required this.countryISOCode,
    required this.countryCode,
    required this.number,
  });

  factory PhoneNumber.fromCompleteNumber({required String completeNumber}) {
    if (completeNumber == "") {
      return PhoneNumber(countryISOCode: "", countryCode: "", number: "");
    }

    try {
      Country country = getCountry(completeNumber);
      String number;
      if (completeNumber.startsWith('+')) {
        number = completeNumber.substring(1 + country.dialCode.length + country.regionCode.length);
      } else {
        number = completeNumber.substring(country.dialCode.length + country.regionCode.length);
      }
      return PhoneNumber(
          countryISOCode: country.code, countryCode: country.dialCode + country.regionCode, number: number);
    } on InvalidCharactersException {
      rethrow;
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      return PhoneNumber(countryISOCode: "", countryCode: "", number: "");
    }
  }

  bool isValidNumber() {
    Country country = getCountry(completeNumber);
    if (number.length < country.minLength) {
      throw NumberTooShortException();
    }

    if (number.length > country.maxLength) {
      throw NumberTooLongException();
    }
    return true;
  }

  String get completeNumber {
    return countryCode + number;
  }

  static Country getCountry(String phoneNumber) {
    if (phoneNumber == "") {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^[+0-9]*[0-9]*$');

    if (!validPhoneNumber.hasMatch(phoneNumber)) {
      throw InvalidCharactersException();
    }

    if (phoneNumber.startsWith('+')) {
      return countries
          .firstWhere((country) => phoneNumber.substring(1).startsWith(country.dialCode + country.regionCode));
    }
    return countries.firstWhere((country) => phoneNumber.startsWith(country.dialCode + country.regionCode));
  }

  /// Splits a phone number into country code and the actual number.
  ///
  /// This method takes a complete phone number and a list of countries,
  /// and attempts to split the phone number into its country code and the actual number.
  /// If the phone number starts with a country code that matches one of the countries in the list,
  /// it returns a map containing the country code and the actual number.
  /// If no matching country code is found, it returns an empty country code and the original phone number.
  ///
  /// Example:
  /// ```dart
  /// final result = PhoneNumber.splitPhoneNumber("+12124567890", countries);
  /// print(result); // { 'countryCode': '+1', 'number': '2124567890' }
  /// ```
  ///
  /// - [phoneNumber]: The complete phone number to be split.
  /// - [countries]: The list of countries to check against.
  ///
  /// Returns a map with 'countryCode' and 'number' keys.
  static Map<String, String> splitPhoneNumber(String phoneNumber, List<Country> countries) {
    for (var country in countries) {
      if (phoneNumber.startsWith('+${country.dialCode}')) {
        return {
          'countryCode': '+${country.dialCode}',
          'number': phoneNumber.substring(country.dialCode.length + 1)
        };
      }
    }
    return {'countryCode': '', 'number': phoneNumber};
  }

  @override
  String toString() => 'PhoneNumber(countryISOCode: $countryISOCode, countryCode: $countryCode, number: $number)';
}
