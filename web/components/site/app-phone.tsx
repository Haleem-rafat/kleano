'use client';

import Image, { type StaticImageData } from 'next/image';
import { useState } from 'react';
import { IPhone17ProMax } from '@/components/ui/apple-iphone-17-pro';

/** iPhone 17 Pro proportions (71.5 × 149.6 mm) at the frame's design height. */
const PHONE_H = 700;
const PHONE_W = (PHONE_H * 71.5) / 149.6;

type IslandStatus = {
  title: string;
  stage: string;
  progress: number;
};

/**
 * A real app screenshot in Cult UI's iPhone 17 Pro frame. With `island`, the Dynamic Island
 * opens to show the wash status, like the app's Live Activity; tapping it opens and closes it.
 */
export function AppPhone({
  screen,
  alt,
  island,
  scale,
  priority = false,
}: {
  screen: StaticImageData;
  alt: string;
  island?: IslandStatus;
  /** The frame is drawn at its design size (700px tall) and scaled, so the island keeps its proportions. */
  scale: number;
  priority?: boolean;
}) {
  const [open, setOpen] = useState(Boolean(island));

  return (
    <div className="relative" style={{ width: PHONE_W * scale, height: PHONE_H * scale }}>
      <div
        className="absolute top-0 left-0 origin-top-left"
        style={{ width: PHONE_W, height: PHONE_H, transform: `scale(${scale})` }}
      >
        <IPhone17ProMax
          height={`${PHONE_H}px`}
          showStatusBar={false}
          showHomeIndicator={false}
          dynamicIslandSize={open ? 'expanded' : 'default'}
          onDynamicIslandTap={() => island && setOpen((v) => !v)}
          onScreenTap={() => undefined}
          className="p-0"
          dynamicIslandContent={
            island ? (
              <div className="flex w-full items-center gap-3 px-1" dir="auto">
                <span className="relative flex size-2.5 shrink-0">
                  <span className="absolute inline-flex size-full animate-ping rounded-full bg-success opacity-60 motion-reduce:animate-none" />
                  <span className="relative inline-flex size-2.5 rounded-full bg-success" />
                </span>
                <div className="grid min-w-0 flex-1 gap-1.5">
                  <div className="flex items-baseline justify-between gap-2 text-sm leading-none">
                    <b className="truncate font-semibold">{island.title}</b>
                    <span className="shrink-0 text-white/60">{island.stage}</span>
                  </div>
                  <div className="h-1 overflow-hidden rounded-full bg-white/20">
                    <div className="h-full rounded-full bg-island-accent" style={{ width: `${island.progress}%` }} />
                  </div>
                </div>
              </div>
            ) : undefined
          }
        >
          <Image src={screen} alt={alt} fill priority={priority} placeholder="blur" sizes="340px" className="object-cover" />
        </IPhone17ProMax>
      </div>
    </div>
  );
}
