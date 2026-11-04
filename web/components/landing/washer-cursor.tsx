'use client';

import { useEffect, useRef, type RefObject } from 'react';
import type { SprayState } from '@/components/landing/wash-scene';

/**
 * The pointer as a washer gun, inside one section only. It moves by writing styles directly, so
 * moving the mouse never re-renders React. Water is drawn on one canvas, and only while the pointer
 * is inside. On touch there is no gun: droplets burst from the finger instead.
 */

const NOZZLE: [number, number] = [58, 44]; // the nozzle sits this far from the point being sprayed
const DROPS = 44;

export function WasherCursor({ area, spray }: { area: RefObject<HTMLElement | null>; spray: RefObject<SprayState> }) {
  const gun = useRef<HTMLDivElement>(null);
  const canvas = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const host = area.current;
    const el = canvas.current;
    const gunEl = gun.current;
    const ctx = el?.getContext('2d');
    if (!host || !el || !gunEl || !ctx) return;

    let x = 0;
    let y = 0;
    let inside = false;
    let down = false;
    let touch = false;
    let overControl = false;
    let frame = 0;
    const drops = Array.from({ length: DROPS }, () => ({ x: 0, y: 0, vx: 0, vy: 0, life: 0 }));
    let nextDrop = 0;

    const resize = () => {
      el.width = host.clientWidth;
      el.height = host.clientHeight;
    };
    resize();
    const observer = new ResizeObserver(resize);
    observer.observe(host);

    const tick = () => {
      ctx.clearRect(0, 0, el.width, el.height);
      const spraying = !overControl && (touch ? down && spray.current.onCar : down || spray.current.onCar);
      const jitter = spraying ? Math.sin(performance.now() / 28) * 1.6 : 0;

      gunEl.style.opacity = inside && !touch && !overControl ? '1' : '0';
      gunEl.style.transform = `translate3d(${x + NOZZLE[0] + jitter}px, ${y + NOZZLE[1] + jitter}px, 0)`;

      if (spraying) {
        if (!touch) {
          // The jet from the nozzle to the point being sprayed.
          const g = ctx.createLinearGradient(x + NOZZLE[0], y + NOZZLE[1], x, y);
          g.addColorStop(0, 'rgba(235,245,255,0.95)');
          g.addColorStop(1, 'rgba(190,225,255,0.45)');
          ctx.strokeStyle = g;
          ctx.lineCap = 'round';
          ctx.lineWidth = 3.2;
          ctx.beginPath();
          ctx.moveTo(x + NOZZLE[0], y + NOZZLE[1]);
          ctx.lineTo(x, y);
          ctx.stroke();
        }
        for (let i = 0; i < 2; i++) {
          const d = drops[nextDrop];
          nextDrop = (nextDrop + 1) % DROPS;
          const angle = Math.random() * Math.PI * 2;
          const speed = 0.6 + Math.random() * 2.4;
          d.x = x;
          d.y = y;
          d.vx = Math.cos(angle) * speed;
          d.vy = Math.sin(angle) * speed - 1;
          d.life = 1;
        }
      }

      ctx.fillStyle = '#dcecff';
      let alive = false;
      for (const d of drops) {
        if (d.life <= 0) continue;
        alive = true;
        d.life -= 0.035;
        d.vy += 0.12;
        d.x += d.vx;
        d.y += d.vy;
        ctx.globalAlpha = Math.max(0, d.life);
        ctx.beginPath();
        ctx.arc(d.x, d.y, 1 + d.life * 1.5, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.globalAlpha = 1;

      frame = inside || down || alive ? requestAnimationFrame(tick) : 0;
    };
    const wake = () => {
      if (!frame) frame = requestAnimationFrame(tick);
    };

    const place = (e: PointerEvent) => {
      const box = host.getBoundingClientRect();
      x = e.clientX - box.left;
      y = e.clientY - box.top;
      touch = e.pointerType !== 'mouse';
      overControl = Boolean((e.target as Element | null)?.closest?.('a,button'));
      inside = true;
      wake();
    };
    const onDown = (e: PointerEvent) => {
      place(e);
      down = true;
    };
    const onUp = () => {
      down = false;
      if (touch) {
        inside = false;
        spray.current.onCar = false;
      }
    };
    const onLeave = () => {
      inside = false;
      spray.current.onCar = false;
    };

    host.addEventListener('pointermove', place, { passive: true });
    host.addEventListener('pointerdown', onDown, { passive: true });
    window.addEventListener('pointerup', onUp, { passive: true });
    window.addEventListener('pointercancel', onUp, { passive: true });
    host.addEventListener('pointerleave', onLeave, { passive: true });
    return () => {
      cancelAnimationFrame(frame);
      observer.disconnect();
      host.removeEventListener('pointermove', place);
      host.removeEventListener('pointerdown', onDown);
      window.removeEventListener('pointerup', onUp);
      window.removeEventListener('pointercancel', onUp);
      host.removeEventListener('pointerleave', onLeave);
    };
  }, [area, spray]);

  return (
    <>
      <canvas ref={canvas} aria-hidden="true" className="pointer-events-none absolute inset-0 z-20" />
      <div ref={gun} aria-hidden="true" className="pointer-events-none absolute top-0 left-0 z-30 opacity-0 will-change-transform">
        {/* A pressure-washer gun whose nozzle tip is this element's top-left corner. */}
        <svg width="132" height="112" viewBox="0 0 132 112" fill="none" className="drop-shadow-[0_6px_10px_rgba(0,0,0,0.45)]">
          <path d="M2 2 L58 42" stroke="#c7c4cf" strokeWidth="6" strokeLinecap="round" />
          <path d="M0 0 L9 3 L3 9 Z" fill="#f4f2f7" />
          <rect x="-8" y="-6" width="16" height="12" rx="3" transform="translate(30 22) rotate(35.5)" fill="#25222b" />
          <path d="M52 34 L100 54 Q108 58 104 66 L98 74 Q94 80 86 76 L44 54 Q38 50 42 42 L46 36 Q48 32 52 34 Z" fill="#6b3f80" />
          <path d="M56 40 L92 56" stroke="#b88cd0" strokeWidth="3" strokeLinecap="round" />
          <path d="M84 72 L74 104 Q72 110 66 108 L58 105 Q52 103 54 97 L64 64 Z" fill="#25222b" />
          <path d="M66 64 Q58 72 62 80" stroke="#f4f2f7" strokeWidth="4.5" strokeLinecap="round" />
          <path d="M104 62 Q122 70 126 96" stroke="#3a3840" strokeWidth="5" strokeLinecap="round" />
        </svg>
      </div>
    </>
  );
}
