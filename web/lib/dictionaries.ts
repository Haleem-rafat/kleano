import type { Locale } from './i18n';

const en = {
  meta: {
    title: 'Kleano | Your car, washed where it is parked',
    description:
      'Book a car wash from your phone. A Kleano biker comes to your car, at home or at work, and you follow every stage live.',
  },
  nav: { how: 'How it works', services: 'Services', tracking: 'Live tracking', bikers: 'For bikers', faq: 'Questions', sections: 'Sections', menu: 'Menu' },
  langSwitch: 'العربية',
  theme: 'Switch light or dark mode',
  hero: {
    eyebrow: 'Car wash that comes to you',
    title: "Your car needs a wash every week. You don't have the hour it takes.",
    lead: 'Not the will, not the money: the hour. The drive to a car wash, the queue, the wait. Kleano brings the wash to where your car is parked.',
    ctaBook: 'Book a wash',
    ctaApp: 'Get the app',
    ctaFacts: ['About a minute to book', 'You see the total before you pay', 'A biker comes at the time you pick'],
    soon: 'Soon',
    trust: ['We come to you', 'Photos of every wash', 'Wallet, card or Apple Pay'],
    photoAlt: 'A Kleano biker washing a white car',
  },
  status: {
    island: { title: 'Washing your car', stage: '3 of 4' },
  },
  value: {
    lead: 'Your car, washed where it is parked.',
    intro: 'Kleano changes three things about keeping your car clean:',
    outcomes: [
      { name: 'Your time', detail: 'No drive and no queue. A biker washes your car at home or at work while you get on with your day.' },
      { name: 'Your peace of mind', detail: 'Follow each stage live, from on the way to done, and get photos of your car before and after the wash.' },
      { name: 'Your money', detail: 'See the total before you book. Monthly plans cost less per wash, and you can pay from your Kleano wallet.' },
    ],
  },
  credibility: {
    heading: 'What every Kleano wash comes with',
    facts: [
      { claim: 'Photos before and after', detail: 'The biker photographs your car before and after the wash, and both appear in your booking.' },
      { claim: 'A biker you can reach', detail: 'Once a biker accepts, you see their name and phone number in the booking.' },
      { claim: 'The price up front', detail: 'Service, extras and any promo code add up to one total that you see before you pay.' },
    ],
    // Marked place for a real founder or company note; renders only when filled in.
    operatorNote: '',
  },
  faq: {
    title: 'Questions people ask',
    items: [
      { q: 'Where do you wash my car?', a: 'Where it is parked: at home, at work or any saved place. What is available, and the price, depend on the area; the app and the website show what you can book where you are.' },
      { q: 'How do I pay?', a: 'In the app: Kleano wallet, card or Apple Pay. On the website: Kleano wallet for now.' },
      { q: 'Can I book on the website?', a: 'Yes. Log in with your phone number and book in four steps. It is the same account as the app, so your cars, places and bookings are already there.' },
      { q: 'What are plans?', a: 'Monthly plans for regular washes. Pick a plan in the app and book any time it covers.' },
      { q: 'Do I get photos of the wash?', a: 'Yes. The biker takes photos before and after the wash, and they appear in your booking.' },
      { q: 'Can I cancel a booking?', a: 'Open the booking in My Bookings in the app and choose Cancel Booking.' },
    ],
  },
  cta: {
    title: 'Book your first wash',
    body: 'Log in with your phone number, choose a wash, your car, the place and a time. A Kleano biker comes to your car.',
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
    tabCustomers: 'For customers',
    tabBikers: 'For bikers',
  },
  get: {
    title: 'Get Kleano on your phone',
    body: 'Available for iPhone and Android, and you can book on the website too.',
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
  nav: { how: 'كيف يعمل', services: 'الخدمات', tracking: 'التتبع المباشر', bikers: 'للسائقين', faq: 'الأسئلة', sections: 'الأقسام', menu: 'القائمة' },
  langSwitch: 'English',
  theme: 'التبديل بين الوضع الفاتح والداكن',
  hero: {
    eyebrow: 'غسيل سيارات يأتي إليك',
    title: 'سيارتك تحتاج غسيلًا كل أسبوع، وأنت لا تملك الساعة التي يأخذها.',
    lead: 'ليست المشكلة في الرغبة ولا في المال، بل في الساعة: الطريق إلى المغسلة، والطابور، والانتظار. كلينو يجلب الغسيل إلى مكان وقوف سيارتك.',
    ctaBook: 'احجز غسلة',
    ctaApp: 'حمّل التطبيق',
    ctaFacts: ['الحجز يأخذ دقيقة تقريبًا', 'ترى الإجمالي قبل الدفع', 'يأتي الكابتن في الوقت الذي تختاره'],
    soon: 'قريبًا',
    trust: ['نأتي إليك', 'صور لكل غسلة', 'المحفظة أو البطاقة أو Apple Pay'],
    photoAlt: 'سائق كلينو يغسل سيارة بيضاء',
  },
  status: {
    island: { title: 'يتم غسيل سيارتك', stage: '٣ من ٤' },
  },
  value: {
    lead: 'سيارتك تُغسل في مكان وقوفها.',
    intro: 'كلينو يغيّر ثلاثة أشياء في الحفاظ على نظافة سيارتك:',
    outcomes: [
      { name: 'وقتك', detail: 'لا طريق ولا طابور. يغسل الكابتن سيارتك في المنزل أو العمل بينما تكمل يومك.' },
      { name: 'راحة بالك', detail: 'تابع كل مرحلة مباشرة من الطريق حتى الانتهاء، واحصل على صور سيارتك قبل الغسيل وبعده.' },
      { name: 'مالك', detail: 'ترى الإجمالي قبل الحجز. الباقات الشهرية أقل تكلفة للغسلة، ويمكنك الدفع من محفظة كلينو.' },
    ],
  },
  credibility: {
    heading: 'ما تحصل عليه مع كل غسلة من كلينو',
    facts: [
      { claim: 'صور قبل الغسيل وبعده', detail: 'يصوّر الكابتن سيارتك قبل الغسيل وبعده، وتظهر الصور في حجزك.' },
      { claim: 'كابتن يمكنك التواصل معه', detail: 'عندما يقبل الكابتن الطلب ترى اسمه ورقم هاتفه في الحجز.' },
      { claim: 'السعر قبل الدفع', detail: 'الخدمة والإضافات وكود الخصم تُجمع في إجمالي واحد تراه قبل الدفع.' },
    ],
    operatorNote: '',
  },
  faq: {
    title: 'أسئلة شائعة',
    items: [
      { q: 'أين تغسلون سيارتي؟', a: 'في مكان وقوفها: المنزل أو العمل أو أي مكان محفوظ. الخدمات المتاحة وأسعارها تختلف حسب المنطقة، ويعرض لك التطبيق والموقع ما يمكنك حجزه حيث أنت.' },
      { q: 'كيف أدفع؟', a: 'في التطبيق: محفظة كلينو أو البطاقة أو Apple Pay. على الموقع: محفظة كلينو حاليًا.' },
      { q: 'هل يمكنني الحجز من الموقع؟', a: 'نعم. سجّل الدخول برقم هاتفك واحجز في أربع خطوات. هو نفس حساب التطبيق، فسياراتك وأماكنك وحجوزاتك موجودة بالفعل.' },
      { q: 'ما هي الباقات؟', a: 'باقات شهرية للغسيل المنتظم. اختر باقتك من التطبيق واحجز في أي وقت تشمله.' },
      { q: 'هل أحصل على صور للغسيل؟', a: 'نعم. يلتقط الكابتن صورًا قبل الغسيل وبعده، وتظهر في حجزك.' },
      { q: 'هل يمكنني إلغاء الحجز؟', a: 'افتح الحجز من حجوزاتي في التطبيق واختر إلغاء الطلب.' },
    ],
  },
  cta: {
    title: 'احجز غسلتك الأولى',
    body: 'سجّل الدخول برقم هاتفك، واختر الغسلة وسيارتك والمكان والموعد، وسيأتي كابتن كلينو إلى سيارتك.',
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
    tabCustomers: 'للعملاء',
    tabBikers: 'للسائقين',
  },
  get: {
    title: 'حمّل كلينو على هاتفك',
    body: 'متاح على iPhone وAndroid، ويمكنك الحجز من الموقع أيضًا.',
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
