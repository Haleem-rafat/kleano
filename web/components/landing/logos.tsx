import { Label, ScrollIn } from '@/components/landing/shared';
import { InfiniteMovingCards } from '@/components/ui/infinite-moving-cards';
import type { Dictionary } from '@/lib/content';

/** A sample of the app's own car-brand list (backend/src/vehicles/vehiclesBrands.json), as plain text. */
const BRANDS = ['Toyota', 'Hyundai', 'Kia', 'Nissan', 'Honda', 'Lexus', 'BMW', 'Mercedes-Benz', 'Audi', 'Chevrolet', 'Ford', 'GMC', 'Mazda', 'Volkswagen'];

export function Logos({ t }: { t: Dictionary['logos'] }) {
  return (
    <section aria-label={t.title} className="border-y py-10">
      <ScrollIn className="mx-auto grid max-w-6xl justify-items-center gap-6 px-4 md:px-8">
        <Label>{t.title}</Label>
        <InfiniteMovingCards
          className="w-full"
          items={BRANDS.map((brand) => ({ key: brand, content: <span className="font-display text-xl font-medium whitespace-nowrap text-muted-foreground md:text-2xl">{brand}</span> }))}
        />
        <p className="text-xs text-muted-foreground">{t.note}</p>
      </ScrollIn>
    </section>
  );
}
