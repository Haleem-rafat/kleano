import { ScrollStory, type StoryShot } from '@/components/landing/scroll-story';
import { Section, SectionHead } from '@/components/landing/shared';
import type { Dictionary } from '@/lib/content';
import bookingOrder from '@/public/images/screens/booking-order.jpg';
import customerHome from '@/public/images/screens/customer-home.jpg';
import customerStatus from '@/public/images/screens/customer-status.jpg';

/** The customer's four booking steps, told on real app screens as you scroll. */
export function HowItWorks({ t, screens }: { t: Dictionary['how']; screens: Dictionary['screens'] }) {
  const shots: StoryShot[] = [
    { src: customerHome, alt: screens.customerHome, tap: [19, 58], pan: [0, 20] }, // press a service
    { src: bookingOrder, alt: screens.bookingOrder, tap: [30, 20], pan: [0, 6] }, // press your car
    { src: bookingOrder, alt: screens.bookingOrder, tap: [42, 58], pan: [8, 22] }, // press a free time
    { src: customerStatus, alt: screens.customerStatus, tap: [50, 28], pan: [0, 12] }, // follow the wash
  ];
  return (
    <Section id="how" className="border-y bg-card/40" pinned>
      <SectionHead number="02" label={t.label} title={t.title} />
      <ScrollStory steps={t.steps} shots={shots} />
    </Section>
  );
}
