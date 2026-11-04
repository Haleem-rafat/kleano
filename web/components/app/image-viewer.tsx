'use client';

import { ChevronLeft, ChevronRight, X } from 'lucide-react';
import { Dialog as DialogPrimitive } from 'radix-ui';
import { useState, type ReactNode } from 'react';
import type { AppDictionary } from '@/lib/app-dictionary';
import { cn } from '@/lib/utils';

export type ViewerImage = { src: string; alt: string };

/** Any photo at full size: arrows between photos, click to zoom, Esc or the backdrop to close. */
export function ImageViewer({ images, start = 0, t, onClose }: { images: ViewerImage[]; start?: number; t: AppDictionary; onClose: () => void }) {
  const [index, setIndex] = useState(start);
  const [zoomed, setZoomed] = useState(false);
  const image = images[index];
  const go = (step: number) => {
    setZoomed(false);
    setIndex((i) => (i + step + images.length) % images.length);
  };
  const round = 'grid size-11 place-items-center rounded-full bg-white/15 text-white backdrop-blur-md transition hover:bg-white/25';
  return (
    <DialogPrimitive.Root open onOpenChange={(open) => !open && onClose()}>
      <DialogPrimitive.Portal>
        <DialogPrimitive.Overlay className="fixed inset-0 z-[60] bg-black/90" />
        <DialogPrimitive.Content
          aria-describedby={undefined}
          onKeyDown={(e) => {
            if (images.length < 2) return;
            if (e.key === 'ArrowRight') go(1);
            if (e.key === 'ArrowLeft') go(-1);
          }}
          className="fixed inset-0 z-[60] grid grid-rows-[auto_minmax(0,1fr)] outline-none"
        >
          <div className="flex items-center justify-between gap-3 p-3 text-white">
            <DialogPrimitive.Title className="min-w-0 truncate text-sm font-medium">{image.alt}</DialogPrimitive.Title>
            <DialogPrimitive.Close aria-label={t.terms.close} className={round}>
              <X className="size-5" aria-hidden="true" />
            </DialogPrimitive.Close>
          </div>
          <div
            className={cn('relative min-h-0', zoomed ? 'overflow-auto' : 'grid place-items-center overflow-hidden px-3 pb-3')}
            onClick={(e) => {
              if (e.target === e.currentTarget) onClose();
            }}
          >
            {/* eslint-disable-next-line @next/next/no-img-element -- photos come from the backend's storage */}
            <img
              src={image.src}
              alt={image.alt}
              onClick={() => setZoomed((z) => !z)}
              className={cn(zoomed ? 'max-w-none cursor-zoom-out' : 'max-h-full max-w-full cursor-zoom-in rounded-lg object-contain')}
            />
            {images.length > 1 ? (
              <div dir="ltr" className="pointer-events-none fixed inset-x-3 top-1/2 flex -translate-y-1/2 justify-between">
                <button type="button" aria-label={t.progress.previous} onClick={() => go(-1)} className={cn(round, 'pointer-events-auto')}>
                  <ChevronLeft className="size-6" aria-hidden="true" />
                </button>
                <button type="button" aria-label={t.progress.next} onClick={() => go(1)} className={cn(round, 'pointer-events-auto')}>
                  <ChevronRight className="size-6" aria-hidden="true" />
                </button>
              </div>
            ) : null}
          </div>
        </DialogPrimitive.Content>
      </DialogPrimitive.Portal>
    </DialogPrimitive.Root>
  );
}

/** A photo you can press to see big. `children` replaces the plain picture when it needs its own look. */
export function ZoomImage({ src, alt, t, className, children }: { src: string; alt: string; t: AppDictionary; className?: string; children?: ReactNode }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" aria-label={`${t.progress.viewPhoto}: ${alt}`} onClick={() => setOpen(true)} className="block shrink-0 cursor-zoom-in overflow-hidden rounded-[inherit] transition hover:opacity-90">
        {children ?? (
          // eslint-disable-next-line @next/next/no-img-element -- photos come from the backend's storage
          <img src={src} alt="" loading="lazy" className={className} />
        )}
      </button>
      {open ? <ImageViewer images={[{ src, alt }]} t={t} onClose={() => setOpen(false)} /> : null}
    </>
  );
}
