import Image, { type StaticImageData } from 'next/image';
import { cn } from '@/lib/utils';

/** A real app screenshot in a phone frame drawn in CSS. The screenshots are iPhone 18 Pro captures. */
export function Phone({ src, alt, className, priority = false }: { src: StaticImageData; alt: string; className?: string; priority?: boolean }) {
  return (
    <div className={cn('relative w-[280px] rounded-[46px] border border-border bg-[#26232a] p-2 shadow-2xl sm:w-[310px]', className)}>
      <div className="relative overflow-hidden rounded-[38px]">
        <Image src={src} alt={alt} priority={priority} placeholder="blur" sizes="(max-width: 640px) 280px, 310px" className="h-auto w-full" />
        <span aria-hidden="true" className="absolute start-1/2 top-[1.1%] h-[3.4%] w-[32%] -translate-x-1/2 rounded-full bg-black rtl:translate-x-1/2" />
      </div>
    </div>
  );
}
