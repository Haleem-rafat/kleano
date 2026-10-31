/// Country code added to a number saved without one (Egypt is the main market).
const String defaultCountryCode = '20';

/// The digits `wa.me` expects: country code + national number, no `+`.
///
/// Customer phones are stored as `+<country><national>` (`+201202939672`,
/// `+966533720654`), so a number that already carries its country code is kept
/// as it is; only a bare local number (`01202939672`) gets [defaultCountryCode].
String whatsAppNumber(String phone) {
  final String raw = phone.trim();
  final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (raw.startsWith('+')) return digits;
  if (digits.startsWith('00')) return digits.substring(2);
  // Local numbers are at most 10 digits after the trunk 0 (Egypt: 10, KSA: 9).
  final String national = digits.replaceFirst(RegExp(r'^0+'), '');
  if (national.length > 10) return national;
  return '$defaultCountryCode$national';
}
