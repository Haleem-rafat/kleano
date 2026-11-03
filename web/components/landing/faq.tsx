import { Section, SectionHead } from '@/components/landing/shared';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import type { Dictionary } from '@/lib/content';

export function Faq({ t }: { t: Dictionary['faq'] }) {
  return (
    <Section id="faq" className="border-t">
      <SectionHead number="06" label={t.label} title={t.title} center />
      <Accordion type="single" collapsible className="mx-auto w-full max-w-3xl">
        {t.items.map((item) => (
          <AccordionItem key={item.q} value={item.q}>
            <AccordionTrigger className="py-5 text-start text-lg font-medium">{item.q}</AccordionTrigger>
            <AccordionContent className="text-base text-pretty text-muted-foreground">{item.a}</AccordionContent>
          </AccordionItem>
        ))}
      </Accordion>
    </Section>
  );
}
