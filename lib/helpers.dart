import 'package:intl_phone_field/countries.dart';

bool isNumeric(String s) => s.isNotEmpty && int.tryParse(s.replaceAll("+", "")) != null;

String removeDiacritics(String str) {
  var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

extension CountryExtensions on List<Country> {

  /// Searches for countries that match the given search string.
  ///
  /// This method takes a search string as input and returns a list of 
  /// [Country] objects that match the search criteria. The search is 
  /// typically performed on the country's name or dialCode if the search starts with
  /// a '+' character, remove the '+' character and search for the dialCode.
  /// if the search starts with a digit, search for the dialCode.

  List<Country> stringSearch(String search) {
    search = removeDiacritics(search.toLowerCase());
    if(search == '+') return this;
    return where(
      (country) => isNumeric(search) && search.startsWith("+")
          ? country.dialCode.contains(search.substring(1))
         : isNumeric(search) && !search.startsWith("+")
          ? country.dialCode.contains(search)
          : removeDiacritics(country.name.replaceAll("+", "").toLowerCase()).contains(search) ||
              country.nameTranslations.values
                  .any((element) => removeDiacritics(element.toLowerCase()).contains(search)),
    ).toList();
  }
}
