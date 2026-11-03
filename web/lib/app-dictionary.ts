import type { Locale } from './i18n';

/**
 * Words for the customer and biker web apps. Taken from the apps' own translations
 * (customer-app/assets/i18n, biker-app/assets/i18n) so the web says the same things.
 */
const en = {
  brand: 'Kleano',
  backToSite: 'Kleano home',
  customer: {
    title: 'Welcome back',
    subtitle: 'Enter your phone number to continue',
    phone: 'Phone number',
    continue: 'Continue',
    codeTitle: 'Enter the code',
    codeSubtitle: 'We sent a 6-digit code to',
    verify: 'Verify',
    resend: 'Resend code',
    resendIn: 'Resend code in',
    changePhone: 'Change phone number',
    codeLength: 'The code has 6 numbers',
    noAccount: "Don't have an account? Sign up in the Kleano app.",
  },
  biker: {
    title: 'Welcome back',
    subtitle: 'Log in to start receiving wash requests',
    userName: 'User name',
    password: 'Password',
    showPassword: 'Show password',
    hidePassword: 'Hide password',
    login: 'Login',
    forgot: 'Forgot your password? Reset it in the Kleano Biker app.',
    minPassword: 'Use at least 8 characters',
  },
  nav: {
    home: 'Home',
    bookings: 'Bookings',
    vehicles: 'My cars',
    profile: 'Account',
    orders: 'Orders',
    schedule: 'My Schedule',
    earnings: 'Earnings',
    logout: 'Log out',
    menu: 'Menu',
  },
  soon: 'This screen is coming next.',
};

export type AppDictionary = typeof en;

const ar: AppDictionary = {
  brand: 'كلينو',
  backToSite: 'الصفحة الرئيسية لكلينو',
  customer: {
    title: 'مرحبًا بعودتك',
    subtitle: 'أدخل رقم جوالك للمتابعة',
    phone: 'رقم الهاتف',
    continue: 'استمر',
    codeTitle: 'أدخل الرمز',
    codeSubtitle: 'أرسلنا رمزًا من 6 أرقام إلى',
    verify: 'تأكيد',
    resend: 'أعد إرسال الرمز',
    resendIn: 'إعادة الإرسال بعد',
    changePhone: 'غير رقم الهاتف',
    codeLength: 'يجب أن يحتوي الرمز على 6 أرقام',
    noAccount: 'ليس لديك حساب؟ أنشئ حسابك من تطبيق كلينو.',
  },
  biker: {
    title: 'مرحبًا بعودتك',
    subtitle: 'سجّل الدخول لتبدأ استقبال طلبات الغسيل',
    userName: 'اسم المستخدم',
    password: 'كلمة المرور',
    showPassword: 'إظهار كلمة المرور',
    hidePassword: 'إخفاء كلمة المرور',
    login: 'تسجيل الدخول',
    forgot: 'نسيت كلمة المرور؟ أعد تعيينها من تطبيق كلينو للسائقين.',
    minPassword: 'استخدم 8 أحرف على الأقل',
  },
  nav: {
    home: 'الرئيسية',
    bookings: 'الحجوزات',
    vehicles: 'سياراتي',
    profile: 'الحساب',
    orders: 'الطلبات',
    schedule: 'جدول العمل',
    earnings: 'الأرباح',
    logout: 'تسجيل الخروج',
    menu: 'القائمة',
  },
  soon: 'هذه الشاشة قادمة قريبًا.',
};

export function getAppDictionary(locale: Locale): AppDictionary {
  return locale === 'ar' ? ar : en;
}
