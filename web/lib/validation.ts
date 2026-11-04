import { z } from 'zod';
import type { AppDictionary } from './app-dictionary';
import { toAsciiDigits } from './phone';

/** Same rules as customer-app/lib/utilties/validator.dart, with the app's own messages. */

const NOT_ALPHABET = /[!@#$%^&*(),.؟؛?":{}|<>0-9،]/;
const EMAIL = /^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+/;

export const nameRule = (t: AppDictionary) =>
  z
    .string()
    .trim()
    .min(1, t.rules.requiredName)
    .refine((v) => !NOT_ALPHABET.test(v), t.rules.alphabetOnly)
    .refine((v) => v.length >= 3, t.rules.nameLength);

/** Optional, as in the app: empty is fine, anything else must look like an email. */
export const emailRule = (t: AppDictionary) =>
  z
    .string()
    .trim()
    .refine((v) => !v || EMAIL.test(v), t.rules.invalidEmail);

export const phoneRule = (t: AppDictionary) =>
  z
    .string()
    .transform((v) => toAsciiDigits(v).trim())
    .pipe(z.string().min(1, t.rules.requiredPhone).min(9, t.rules.phoneLength));

/** The app only asks that brand, model and plate are filled in (edit_vehicles_screen.dart _save). */
export const vehicleSchema = (t: AppDictionary) =>
  z.object({
    brand: z.string().min(1, t.cars.incomplete),
    model: z.string().min(1, t.cars.incomplete),
    plateNumber: z.string().min(1, t.cars.incomplete),
    color: z.string(),
  });
export type VehicleForm = z.input<ReturnType<typeof vehicleSchema>>;

export const signupSchema = (t: AppDictionary) =>
  z.object({
    userName: nameRule(t),
    email: emailRule(t),
    phone: phoneRule(t),
    accepted: z.boolean().refine(Boolean, t.signup.acceptFirst),
  });
export type SignupForm = z.input<ReturnType<typeof signupSchema>>;
