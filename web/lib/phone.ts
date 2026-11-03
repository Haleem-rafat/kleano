/**
 * Phone numbers in the one format the backend matches: `+<country><national>`, e.g. +201202939672.
 * Port of customer-app/lib/utilties/phone_number.dart (buildInternationalPhone).
 */

/** Egypt is the main market (AppConstants.defaultDialCode). */
export const defaultDialCode = '+20';

/** Arabic-Indic (٠-٩) and Persian (۰-۹) digits as ASCII 0-9. */
export function toAsciiDigits(input: string): string {
  return input.replace(/[٠-٩۰-۹]/g, (c) => {
    const code = c.charCodeAt(0);
    return String(code >= 0x06f0 ? code - 0x06f0 : code - 0x0660);
  });
}

const digitsOnly = (s: string) => s.replace(/\D/g, '');

/** What the phone field keeps while typing: digits only, no leading trunk zeros. */
export function cleanPhoneInput(input: string): string {
  return digitsOnly(toAsciiDigits(input)).replace(/^0+/, '');
}

export function buildInternationalPhone(input: string, dialCode = defaultDialCode): string {
  const raw = toAsciiDigits(input).trim();
  const dial = digitsOnly(dialCode);
  if (raw.startsWith('+')) return `+${digitsOnly(raw)}`;
  if (raw.startsWith('00')) return `+${digitsOnly(raw.slice(2))}`;
  const digits = digitsOnly(raw);
  // Country code typed without "+": an Egyptian mobile is 10 digits after the code.
  if (dial === '20' && digits.startsWith('20') && digits.length === 12) return `+${digits}`;
  return `+${dial}${digits.replace(/^0+/, '')}`;
}

/** Egyptian mobiles: +20 then 1, then 9 more digits. Other countries: 8 to 15 digits. */
export function isPlausiblePhone(international: string): boolean {
  if (international.startsWith('+20')) return /^\+201[0125]\d{8}$/.test(international);
  return /^\+\d{8,15}$/.test(international);
}
