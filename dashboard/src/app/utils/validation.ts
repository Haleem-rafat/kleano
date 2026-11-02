import * as Yup from 'yup';

/**
 * Shared front-end rules. Messages are i18n keys (`validation.*`), translated by
 * FormMessage, so every form shows the same wording in English and Arabic.
 */
const M = {
  required: 'validation.required',
  number: 'validation.number',
  positive: 'validation.positive',
  min0: 'validation.min0',
  integer: 'validation.integer',
  percent: 'validation.percent',
  phone: 'validation.phone',
  digits: 'validation.digits',
  password: 'validation.password',
  url: 'validation.url',
  select: 'validation.select',
  selectOne: 'validation.selectOne',
  file: 'validation.file',
  maxLength: 'validation.maxLength',
};

/** '' and null from empty inputs become undefined so `required` catches them. */
const emptyToUndefined = (v: unknown, original: unknown) =>
  original === '' || original === null ? undefined : v;

export const v = {
  text: (max = 120) => Yup.string().trim().required(M.required).max(max, M.maxLength),
  optionalText: (max = 500) => Yup.string().trim().max(max, M.maxLength),
  number: () => Yup.number().transform(emptyToUndefined).typeError(M.number).required(M.required),
  price: () => v.number().min(0, M.min0),
  positive: () => v.number().moreThan(0, M.positive),
  count: () => v.number().integer(M.integer).min(0, M.min0),
  percent: () => v.number().min(0, M.min0).max(100, M.percent),
  optionalNumber: () =>
    Yup.number().transform(emptyToUndefined).typeError(M.number).min(0, M.min0).notRequired(),
  /** International number as typed in the phone field, e.g. +201012345678. */
  phone: () =>
    Yup.string()
      .trim()
      .required(M.required)
      .matches(/^\+?\d{9,15}$/, M.phone),
  digits: () =>
    Yup.string()
      .trim()
      .required(M.required)
      .matches(/^\d{5,20}$/, M.digits),
  password: () => Yup.string().required(M.required).min(8, M.password),
  url: () => Yup.string().trim().required(M.required).url(M.url),
  /** { en, ar } inputs: both languages required. */
  bilingual: () => Yup.object({ en: v.text(), ar: v.text() }).required(M.required),
  /** Single select stored as { label, value }. */
  option: () =>
    Yup.object({ value: Yup.string().required(M.select) })
      .nullable()
      .required(M.select),
  /** Single select stored as the raw value string. */
  choice: () => Yup.string().required(M.select),
  /** Multi select: at least one. */
  options: () => Yup.array().min(1, M.selectOne).required(M.selectOne),
  file: () => Yup.mixed().required(M.file),
  /** Any picker value: a string id, { value }, or a non-empty array. */
  picked: () =>
    Yup.mixed().test('picked', M.select, (val) => {
      if (Array.isArray(val)) return val.length > 0;
      if (val && typeof val === 'object') return !!(val as { value?: string }).value;
      return !!val;
    }),
};

// Default messages for rules written without one (e.g. `.min(1)` in older schemas).
Yup.setLocale({
  mixed: { required: M.required, notType: M.number, oneOf: M.select },
  string: { min: 'validation.tooShort', max: M.maxLength, url: M.url, matches: M.required },
  number: {
    min: 'validation.tooSmall',
    max: 'validation.tooBig',
    integer: M.integer,
    positive: M.positive,
  },
  array: { min: M.selectOne },
});
