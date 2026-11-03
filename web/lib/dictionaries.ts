import type { Locale } from './i18n';

const en = {
  meta: {
    title: 'Kleano | Your car, washed where it is parked',
    description:
      'Book a car wash from your phone. A Kleano biker comes to your car, at home or at work, and you follow every stage live.',
  },
  nav: { how: 'How it works', services: 'Services', tracking: 'Live tracking', bikers: 'For bikers', sections: 'Sections' },
  langSwitch: 'العربية',
  theme: 'Switch light or dark mode',
  hero: {
    eyebrow: 'Car wash that comes to you',
    title: 'Your car, washed where it is parked.',
    lead: 'Choose a wash, pick a time and share your location. A Kleano biker comes to your car, at home or at work.',
    ctaApp: 'Get the app',
    ctaWeb: 'Book on the web',
    soon: 'Soon',
    trust: ['We come to you', 'Photos of every wash', 'Wallet, card or Apple Pay'],
    photoAlt: 'A Kleano biker washing a white car',
  },
  status: {
    title: 'Your car is being washed',
    live: 'Live',
    stages: ['Booked', 'On the way', 'Washing', 'Done'],
    note: 'Example of the live status in the app',
    label: 'Example wash status: booked, on the way, washing now, done next',
  },
  how: {
    eyebrow: 'How it works',
    title: 'Three steps to a clean car',
    steps: [
      { title: 'Choose your wash', body: 'Outside, inside, or add the extras you want. You see the total before you book.' },
      { title: 'Pick a time and place', body: 'Select your car, a time that suits you, and the address where it is parked.' },
      { title: 'Follow your biker', body: 'Track each stage, from on the way to finished, and see photos of your wash.' },
    ],
  },
  services: {
    eyebrow: 'Services',
    title: 'Every wash, done at your car',
    outside: { title: 'Outside wash', body: 'Foam, rinse and dry for the body, wheels and glass.', alt: 'A dark car covered in wash foam' },
    inside: { title: 'Inside clean', body: 'Dashboard, seats and mats cleaned by hand.', alt: 'A gloved hand cleaning a car dashboard with a brush' },
    extras: { title: 'Add the extras', body: 'Build the wash you want. Prices show in the app for your area.' },
    addons: ['Polish', 'Tyre shine', 'Air freshener', 'Engine bay'],
  },
  tracking: {
    eyebrow: 'Live tracking',
    title: 'Know where your wash is, every minute',
    lead: 'The app updates as your biker moves through each stage. On iPhone you can follow it from the Lock Screen.',
    steps: [
      { title: 'Booked', body: 'Your time and place are confirmed.' },
      { title: 'On the way', body: 'See your biker head to your car.' },
      { title: 'Washing', body: 'Your car is being washed.' },
      { title: 'Done', body: 'Photos of your wash land in the app.' },
    ],
    photos: ['Outside', 'Inside'],
  },
  plans: {
    eyebrow: 'Plans',
    title: 'Wash more, pay less',
    body: 'Monthly plans for regular washes. Pick a plan in the app and book any time it covers.',
    payTitle: 'Pay your way',
    pay: ['Kleano wallet', 'Card', 'Apple Pay'],
  },
  bikers: {
    eyebrow: 'For bikers',
    title: 'Wash cars with Kleano',
    points: [
      'Get wash requests near you, the moment they arrive.',
      'Set the days and areas you work.',
      'Follow your washes and earnings in one place.',
    ],
    cta: 'Join as a biker',
    photoAlt: 'A biker holding a phone to accept a wash request',
  },
  get: {
    title: 'Get Kleano on your phone',
    body: 'Available for iPhone and Android. Booking on the web is coming soon.',
    appStoreSmall: 'Download on the',
    playSmall: 'Get it on',
    web: 'Kleano on the web',
  },
  footer: '© Kleano · Car wash at your doorstep',
};

export type Dictionary = typeof en;

const ar: Dictionary = {
  meta: {
    title: 'كلينو | سيارتك تُغسل في مكان وقوفها',
    description: 'احجز غسيل سيارتك من هاتفك. يأتي سائق كلينو إلى سيارتك في المنزل أو العمل، وتتابع كل مرحلة مباشرة.',
  },
  nav: { how: 'كيف يعمل', services: 'الخدمات', tracking: 'التتبع المباشر', bikers: 'للسائقين', sections: 'الأقسام' },
  langSwitch: 'English',
  theme: 'التبديل بين الوضع الفاتح والداكن',
  hero: {
    eyebrow: 'غسيل سيارات يأتي إليك',
    title: 'سيارتك تُغسل في مكان وقوفها.',
    lead: 'اختر الغسلة وحدد الوقت وشارك موقعك، وسيأتي سائق كلينو إلى سيارتك في المنزل أو العمل.',
    ctaApp: 'حمّل التطبيق',
    ctaWeb: 'احجز من الموقع',
    soon: 'قريبًا',
    trust: ['نأتي إليك', 'صور لكل غسلة', 'المحفظة أو البطاقة أو Apple Pay'],
    photoAlt: 'سائق كلينو يغسل سيارة بيضاء',
  },
  status: {
    title: 'يتم غسيل سيارتك الآن',
    live: 'مباشر',
    stages: ['تم الحجز', 'في الطريق', 'الغسيل', 'تم'],
    note: 'مثال على حالة الغسيل المباشرة في التطبيق',
    label: 'مثال لحالة الغسيل: تم الحجز، في الطريق، الغسيل الآن، ثم تم',
  },
  how: {
    eyebrow: 'كيف يعمل',
    title: 'ثلاث خطوات لسيارة نظيفة',
    steps: [
      { title: 'اختر الغسلة', body: 'خارجية أو داخلية، مع الإضافات التي تريدها. ترى الإجمالي قبل الحجز.' },
      { title: 'حدد الوقت والمكان', body: 'اختر سيارتك والوقت المناسب والعنوان الذي تقف فيه.' },
      { title: 'تابع السائق', body: 'تابع كل مرحلة من الطريق حتى الانتهاء، وشاهد صور غسلتك.' },
    ],
  },
  services: {
    eyebrow: 'الخدمات',
    title: 'كل غسلة تتم عند سيارتك',
    outside: { title: 'غسيل خارجي', body: 'رغوة وشطف وتجفيف للهيكل والجنوط والزجاج.', alt: 'سيارة داكنة مغطاة برغوة الغسيل' },
    inside: { title: 'تنظيف داخلي', body: 'تنظيف التابلوه والمقاعد والدواسات يدويًا.', alt: 'يد بقفاز تنظف تابلوه السيارة بفرشاة' },
    extras: { title: 'أضف الإضافات', body: 'اصنع الغسلة التي تريدها. تظهر الأسعار في التطبيق حسب منطقتك.' },
    addons: ['تلميع', 'تلميع الإطارات', 'معطر', 'تنظيف المحرك'],
  },
  tracking: {
    eyebrow: 'التتبع المباشر',
    title: 'اعرف أين وصلت غسلتك في كل دقيقة',
    lead: 'يتحدث التطبيق مع كل مرحلة يمر بها السائق. على iPhone يمكنك متابعتها من شاشة القفل.',
    steps: [
      { title: 'تم الحجز', body: 'تم تأكيد الوقت والمكان.' },
      { title: 'في الطريق', body: 'شاهد السائق وهو في طريقه إلى سيارتك.' },
      { title: 'الغسيل', body: 'يتم غسيل سيارتك الآن.' },
      { title: 'تم', body: 'تصلك صور غسلتك في التطبيق.' },
    ],
    photos: ['الخارج', 'الداخل'],
  },
  plans: {
    eyebrow: 'الباقات',
    title: 'اغسل أكثر وادفع أقل',
    body: 'باقات شهرية للغسيل المنتظم. اختر باقتك من التطبيق واحجز في أي وقت تشمله.',
    payTitle: 'ادفع بطريقتك',
    pay: ['محفظة كلينو', 'البطاقة', 'Apple Pay'],
  },
  bikers: {
    eyebrow: 'للسائقين',
    title: 'اغسل السيارات مع كلينو',
    points: ['تصلك طلبات الغسيل القريبة منك فور وصولها.', 'حدد أيام ومناطق عملك.', 'تابع غسلاتك وأرباحك في مكان واحد.'],
    cta: 'انضم كسائق',
    photoAlt: 'سائق يحمل هاتفًا لقبول طلب غسيل',
  },
  get: {
    title: 'حمّل كلينو على هاتفك',
    body: 'متاح على iPhone وAndroid. الحجز من الموقع قريبًا.',
    appStoreSmall: 'حمّل من',
    playSmall: 'احصل عليه من',
    web: 'كلينو على الويب',
  },
  footer: '© كلينو · غسيل السيارات عند بابك',
};

const dictionaries: Record<Locale, Dictionary> = { en, ar };

export function getDictionary(locale: Locale): Dictionary {
  return dictionaries[locale];
}
