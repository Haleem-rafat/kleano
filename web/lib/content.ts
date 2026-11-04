import type { Locale } from './i18n';

/**
 * All landing page copy, in one place. Every claim here must be true of the app today: no ratings,
 * customer counts, reviews or prices until real ones exist. The live catalogue still holds test
 * entries, so prices are shown in the app for the visitor's area rather than quoted here.
 */
const en = {
  meta: {
    title: 'Kleano | Your car, washed where it is parked',
    description: 'Book a car wash in about a minute. A Kleano biker comes to your car at home or at work, and you follow every stage live.',
  },
  brand: 'Kleano',
  langSwitch: 'العربية',
  theme: 'Switch light or dark mode',
  nav: {
    label: 'Sections',
    menu: 'Menu',
    services: 'Services',
    how: 'How it works',
    tracking: 'Tracking',
    bikers: 'Bikers',
    plans: 'Plans',
    faq: 'FAQ',
    signIn: 'Sign in',
    book: 'Book a wash',
  },
  hero: {
    eyebrow: 'A biker comes to you · Photos of every wash · Total before you pay',
    titleStart: 'Your car, washed',
    flip: ['where it is parked', 'at home', 'at work'],
    lead: 'No drive, no queue, no wait. Book in about a minute, and a Kleano biker comes to your car at the time you pick. Follow every stage live.',
    how: 'See how it works',
    get: 'Get the app',
  },
  screens: {
    customerHome: 'The Kleano app home screen on iPhone: your next wash, services and plans',
    bikerToday: 'The Kleano Biker app on iPhone: online switch and the biker\'s washes and rating',
    statusCard: 'The live wash status card in the Kleano app, showing the biker has arrived',
    bookingOrder: 'The Booking Order screen in the Kleano app: your car, the date and the free times',
    customerStatus: 'The Kleano app home screen with the live status of a wash',
    bikerOrders: 'The Orders screen in the Kleano Biker app with the wash progress button',
    bikerSchedule: 'The My Schedule screen in the Kleano Biker app',
    bikerEarnings: 'The Earnings screen in the Kleano Biker app',
    note: 'Real screens from the Kleano apps.',
  },
  wash: {
    label: 'Try it',
    title: 'Wash it yourself.',
    line: 'Move the gun over the car. A Kleano biker does the rest.',
    lineTouch: 'Drag your finger over the car.',
    cleaned: 'Cleaned',
    clean: 'Clean. Now book the real thing.',
    again: 'Wash again',
    sceneLabel: 'A playful 3D scene: a dirty car that you can wash with a pressure washer.',
    credit: 'Car model: Car Concept by Unity Fan and The Khronos Group, CC BY 4.0, recoloured and simplified.',
  },
  logos: {
    title: 'Whatever you drive',
    note: 'Independent service. Not affiliated with the brands shown.',
  },
  services: {
    label: 'Services',
    title: 'Every wash, done at your car',
    outside: { title: 'Outside wash', body: 'The outside of your car, washed where it is parked.', alt: 'A dark car covered in wash foam' },
    inside: { title: 'Inside clean', body: 'The inside of your car, cleaned by hand.', alt: 'A gloved hand cleaning a car dashboard with a brush' },
    extras: { title: 'Add the extras', body: 'Add what you want to your wash. You see the price of each one before you book.' },
    freshener: { title: 'Car freshener', body: 'Switch it on when you book, and your car comes back smelling fresh.' },
    places: { title: 'Your saved places', body: 'Save home and work once, and book the next wash in a tap.', chips: ['Home', 'Work'] },
    pay: { title: 'Pay your way', body: 'Kleano wallet, card or Apple Pay in the app. Kleano wallet on the website.' },
    from: 'Prices show for your area when you book.',
  },
  how: {
    label: 'How it works',
    title: 'Four steps to a clean car',
    steps: [
      { title: 'Choose your wash', body: 'Pick a service and any extras. The total updates as you go.', tag: 'Service' },
      { title: 'Your car and place', body: 'Your car and saved place are already filled in. Change them if you need to.', tag: 'Car and place' },
      { title: 'Pick a time', body: 'See the free times for the next 7 days. The first free one is already selected.', tag: 'Date and time' },
      { title: 'Pay and follow', body: 'Confirm, then follow your biker through each stage until your car is clean.', tag: 'Review and pay' },
    ],
  },
  tracking: {
    label: 'Live tracking',
    title: 'Watch your car get clean.',
    lead: 'The status updates as your biker moves through each stage, so you never have to wonder or call.',
    callouts: [
      { title: 'Photos before and after', body: 'The biker photographs your car before and after the wash. Both appear in your booking.' },
      { title: 'A biker you can reach', body: 'Once a biker accepts, you see their name and phone number.' },
      { title: 'On your Lock Screen', body: 'On iPhone, follow the wash from the Lock Screen and Dynamic Island without opening the app.' },
    ],
  },
  bikers: {
    label: 'For bikers',
    title: 'Wash cars with Kleano',
    points: ['Get wash requests near you, the moment they arrive.', 'See your working days and areas.', 'Follow your washes and earnings in one place.'],
    cta: 'Biker log in',
    photoAlt: 'A Kleano biker washing a white car',
    flowTitle: 'A biker\'s day in the app',
    steps: [
      { title: 'Go online', body: 'Switch on when you are ready to work. Your washes and rating are on the same screen.', tag: 'Today' },
      { title: 'Take the wash', body: 'See the car, the time and the address, update the wash progress, and call or message the customer.', tag: 'Orders' },
      { title: 'See your schedule', body: 'Your working days, times and areas in one list.', tag: 'My Schedule' },
      { title: 'Track your earnings', body: 'Today, weekends and all time, with your completed washes.', tag: 'Earnings' },
    ],
  },
  plans: {
    label: 'Plans',
    title: 'Wash once, or wash more and pay less',
    note: 'Prices depend on your area. You see them in the app and on the website before you pay.',
    items: [
      { name: 'Pay per wash', tag: '', body: 'Book when you need it.', points: ['Choose any service and extras', 'See the total before you pay', 'Use a promo code at checkout'], cta: 'Book a wash', href: 'book' },
      { name: 'Monthly plan', tag: 'For regular washes', body: 'Wash more, pay less.', points: ['Monthly plans for regular washes', 'Book any time your plan covers', 'Pick your plan in the Kleano app'], cta: 'Get the app', href: 'get' },
    ],
  },
  faq: {
    label: 'FAQ',
    title: 'Questions people ask',
    items: [
      { q: 'Where do you wash my car?', a: 'Where it is parked: at home, at work or any saved place. What is available, and the price, depend on the area. The app and the website show what you can book where you are.' },
      { q: 'How do I pay?', a: 'In the app: Kleano wallet, card or Apple Pay. On the website: Kleano wallet for now.' },
      { q: 'Can I book on the website?', a: 'Yes. Log in with your phone number and book in four steps. It is the same account as the app, so your cars, places and bookings are already there.' },
      { q: 'What are plans?', a: 'Monthly plans for regular washes. Pick a plan in the app and book any time it covers.' },
      { q: 'Do I get photos of the wash?', a: 'Yes. The biker takes photos before and after the wash, and they appear in your booking.' },
      { q: 'Can I cancel a booking?', a: 'Open the booking in My Bookings in the app and choose Cancel Booking.' },
    ],
  },
  cta: {
    title: 'Time to give your car the care it deserves.',
    body: 'About a minute to book. You see the total before you pay. A biker comes at the time you pick.',
    appStoreSmall: 'Download on the',
    playSmall: 'Get it on',
  },
  footer: {
    tagline: 'Car wash that comes to you.',
    product: 'Kleano',
    accounts: 'Log in',
    customer: 'Customer log in',
    biker: 'Biker log in',
    rights: 'Kleano',
  },
};

export type Dictionary = typeof en;

const ar: Dictionary = {
  meta: {
    title: 'كلينو | سيارتك تُغسل في مكان وقوفها',
    description: 'احجز غسيل سيارتك في دقيقة تقريبًا. يأتي كابتن كلينو إلى سيارتك في المنزل أو العمل، وتتابع كل مرحلة مباشرة.',
  },
  brand: 'كلينو',
  langSwitch: 'English',
  theme: 'التبديل بين الوضع الفاتح والداكن',
  nav: {
    label: 'الأقسام',
    menu: 'القائمة',
    services: 'الخدمات',
    how: 'كيف يعمل',
    tracking: 'التتبع',
    bikers: 'الكباتن',
    plans: 'الباقات',
    faq: 'الأسئلة',
    signIn: 'تسجيل الدخول',
    book: 'احجز غسلة',
  },
  hero: {
    eyebrow: 'الكابتن يأتي إليك · صور لكل غسلة · الإجمالي قبل الدفع',
    titleStart: 'سيارتك تُغسل',
    flip: ['في مكان وقوفها', 'في المنزل', 'في العمل'],
    lead: 'لا طريق ولا طابور ولا انتظار. احجز في دقيقة تقريبًا، وسيأتي كابتن كلينو إلى سيارتك في الوقت الذي تختاره. وتابع كل مرحلة مباشرة.',
    how: 'شاهد كيف يعمل',
    get: 'حمّل التطبيق',
  },
  screens: {
    customerHome: 'الشاشة الرئيسية لتطبيق كلينو على iPhone: غسلتك التالية والخدمات والباقات',
    bikerToday: 'تطبيق كلينو للكباتن على iPhone: زر الاتصال وغسلات الكابتن وتقييمه',
    statusCard: 'بطاقة حالة الغسيل المباشرة في تطبيق كلينو، وتظهر وصول الكابتن',
    bookingOrder: 'شاشة طلب الحجز في تطبيق كلينو: سيارتك والتاريخ والمواعيد المتاحة',
    customerStatus: 'الشاشة الرئيسية لتطبيق كلينو مع الحالة المباشرة للغسيل',
    bikerOrders: 'شاشة الطلبات في تطبيق كلينو للكباتن مع زر تقدم الغسيل',
    bikerSchedule: 'شاشة جدول العمل في تطبيق كلينو للكباتن',
    bikerEarnings: 'شاشة الأرباح في تطبيق كلينو للكباتن',
    note: 'شاشات حقيقية من تطبيقات كلينو.',
  },
  wash: {
    label: 'جرّبها',
    title: 'اغسلها بنفسك.',
    line: 'حرّك المسدس فوق السيارة، والباقي على كابتن كلينو.',
    lineTouch: 'اسحب إصبعك فوق السيارة.',
    cleaned: 'تم تنظيف',
    clean: 'أصبحت نظيفة. احجز غسلتك الآن.',
    again: 'اغسلها مرة أخرى',
    sceneLabel: 'مشهد ثلاثي الأبعاد للتجربة: سيارة متسخة يمكنك غسلها بمسدس الضغط.',
    credit: 'نموذج السيارة: Car Concept من Unity Fan وThe Khronos Group، برخصة CC BY 4.0، مع تعديل اللون والتبسيط.',
  },
  logos: {
    title: 'أيًا كانت سيارتك',
    note: 'خدمة مستقلة، ولا صلة لها بالعلامات التجارية المعروضة.',
  },
  services: {
    label: 'الخدمات',
    title: 'كل غسلة تتم عند سيارتك',
    outside: { title: 'غسيل خارجي', body: 'يُغسل الجزء الخارجي من سيارتك في مكان وقوفها.', alt: 'سيارة داكنة مغطاة برغوة الغسيل' },
    inside: { title: 'تنظيف داخلي', body: 'يُنظف الجزء الداخلي من سيارتك يدويًا.', alt: 'يد بقفاز تنظف تابلوه السيارة بفرشاة' },
    extras: { title: 'أضف الإضافات', body: 'أضف ما تريد إلى غسلتك. ترى سعر كل إضافة قبل الحجز.' },
    freshener: { title: 'معطر السيارة', body: 'فعّله عند الحجز لتعود سيارتك برائحة منعشة.' },
    places: { title: 'أماكنك المحفوظة', body: 'احفظ المنزل والعمل مرة واحدة، واحجز غسلتك التالية بلمسة.', chips: ['المنزل', 'العمل'] },
    pay: { title: 'ادفع بطريقتك', body: 'محفظة كلينو أو البطاقة أو Apple Pay في التطبيق. محفظة كلينو على الموقع.' },
    from: 'تظهر الأسعار حسب منطقتك عند الحجز.',
  },
  how: {
    label: 'كيف يعمل',
    title: 'أربع خطوات لسيارة نظيفة',
    steps: [
      { title: 'اختر غسلتك', body: 'اختر الخدمة وأي إضافات، ويتحدث الإجمالي أثناء اختيارك.', tag: 'الخدمة' },
      { title: 'سيارتك ومكانك', body: 'سيارتك ومكانك المحفوظ محددان مسبقًا، ويمكنك تغييرهما عند الحاجة.', tag: 'السيارة والمكان' },
      { title: 'اختر الموعد', body: 'شاهد المواعيد المتاحة خلال 7 أيام، وأول موعد متاح محدد مسبقًا.', tag: 'الموعد' },
      { title: 'ادفع وتابع', body: 'أكّد حجزك، ثم تابع الكابتن في كل مرحلة حتى تصبح سيارتك نظيفة.', tag: 'المراجعة والدفع' },
    ],
  },
  tracking: {
    label: 'التتبع المباشر',
    title: 'شاهد سيارتك وهي تصبح نظيفة.',
    lead: 'تتحدث الحالة مع كل مرحلة يمر بها الكابتن، فلا تحتاج إلى التخمين أو الاتصال.',
    callouts: [
      { title: 'صور قبل الغسيل وبعده', body: 'يصوّر الكابتن سيارتك قبل الغسيل وبعده، وتظهر الصور في حجزك.' },
      { title: 'كابتن يمكنك التواصل معه', body: 'عندما يقبل الكابتن الطلب ترى اسمه ورقم هاتفه.' },
      { title: 'على شاشة القفل', body: 'على iPhone، تابع الغسيل من شاشة القفل والجزيرة الديناميكية دون فتح التطبيق.' },
    ],
  },
  bikers: {
    label: 'للكباتن',
    title: 'اغسل السيارات مع كلينو',
    points: ['تصلك طلبات الغسيل القريبة منك فور وصولها.', 'شاهد أيام ومناطق عملك.', 'تابع غسلاتك وأرباحك في مكان واحد.'],
    cta: 'دخول الكباتن',
    photoAlt: 'كابتن كلينو يغسل سيارة بيضاء',
    flowTitle: 'يوم الكابتن في التطبيق',
    steps: [
      { title: 'ابدأ العمل', body: 'فعّل حالتك عندما تكون مستعدًا للعمل. غسلاتك وتقييمك على الشاشة نفسها.', tag: 'اليوم' },
      { title: 'نفّذ الغسلة', body: 'شاهد السيارة والوقت والعنوان، وحدّث تقدم الغسيل، واتصل بالعميل أو راسله.', tag: 'الطلبات' },
      { title: 'شاهد جدولك', body: 'أيام وأوقات ومناطق عملك في قائمة واحدة.', tag: 'جدول العمل' },
      { title: 'تابع أرباحك', body: 'اليوم وعطلات نهاية الأسبوع وكل الوقت، مع غسلاتك المكتملة.', tag: 'الأرباح' },
    ],
  },
  plans: {
    label: 'الباقات',
    title: 'اغسل مرة واحدة، أو اغسل أكثر وادفع أقل',
    note: 'تختلف الأسعار حسب منطقتك، وتراها في التطبيق والموقع قبل الدفع.',
    items: [
      { name: 'الدفع لكل غسلة', tag: '', body: 'احجز عندما تحتاج.', points: ['اختر أي خدمة وإضافات', 'شاهد الإجمالي قبل الدفع', 'استخدم كود الخصم عند الدفع'], cta: 'احجز غسلة', href: 'book' },
      { name: 'باقة شهرية', tag: 'للغسيل المنتظم', body: 'اغسل أكثر وادفع أقل.', points: ['باقات شهرية للغسيل المنتظم', 'احجز في أي وقت تشمله باقتك', 'اختر باقتك من تطبيق كلينو'], cta: 'حمّل التطبيق', href: 'get' },
    ],
  },
  faq: {
    label: 'الأسئلة',
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
    title: 'حان الوقت لتمنح سيارتك العناية التي تستحقها.',
    body: 'الحجز يأخذ دقيقة تقريبًا. ترى الإجمالي قبل الدفع. ويأتي الكابتن في الوقت الذي تختاره.',
    appStoreSmall: 'حمّل من',
    playSmall: 'احصل عليه من',
  },
  footer: {
    tagline: 'غسيل سيارات يأتي إليك.',
    product: 'كلينو',
    accounts: 'تسجيل الدخول',
    customer: 'دخول العملاء',
    biker: 'دخول الكباتن',
    rights: 'كلينو',
  },
};

const dictionaries: Record<Locale, Dictionary> = { en, ar };

export function getDictionary(locale: Locale): Dictionary {
  return dictionaries[locale];
}
