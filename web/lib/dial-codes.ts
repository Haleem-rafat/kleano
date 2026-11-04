/**
 * Countries for the phone field's code picker. The app shows a full picker with +20 first; on the
 * web the markets that matter come first, and the names come from the browser's own translations.
 */
export const dialCodes = [
  { region: 'EG', code: '+20' },
  { region: 'SA', code: '+966' },
  { region: 'AE', code: '+971' },
  { region: 'KW', code: '+965' },
  { region: 'QA', code: '+974' },
  { region: 'BH', code: '+973' },
  { region: 'OM', code: '+968' },
  { region: 'JO', code: '+962' },
  { region: 'LB', code: '+961' },
  { region: 'IQ', code: '+964' },
  { region: 'SD', code: '+249' },
  { region: 'YE', code: '+967' },
  { region: 'SY', code: '+963' },
  { region: 'PS', code: '+970' },
  { region: 'MA', code: '+212' },
  { region: 'TN', code: '+216' },
  { region: 'DZ', code: '+213' },
  { region: 'LY', code: '+218' },
  { region: 'PK', code: '+92' },
  { region: 'IN', code: '+91' },
  { region: 'GB', code: '+44' },
  { region: 'US', code: '+1' },
];

export const isDialCode = (value: unknown): value is string => dialCodes.some((d) => d.code === value);

export function dialOptions(locale: string) {
  const names = new Intl.DisplayNames([locale], { type: 'region' });
  return dialCodes.map((d) => ({ value: d.code, label: names.of(d.region) ?? d.region, hint: d.code }));
}
