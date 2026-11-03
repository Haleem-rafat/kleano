'use client';

import { motion, useReducedMotion, useScroll, useTransform } from 'motion/react';
import { useRef } from 'react';
import { Phone } from '@/components/landing/phone';
import type { Dictionary } from '@/lib/content';
import bikerToday from '@/public/images/screens/biker-today.jpg';
import bookingOrder from '@/public/images/screens/booking-order.jpg';
import customerHome from '@/public/images/screens/customer-home.jpg';

/**
 * Three real screens: the customer app in the middle, the biker app and the booking screen behind
 * it. The side phones fan out and straighten as the page scrolls. On phones they peek in from the
 * edges (the hero clips them), so the page never scrolls sideways.
 */
export function HeroPhones({ screens }: { screens: Dictionary['screens'] }) {
  const ref = useRef<HTMLDivElement>(null);
  const still = useReducedMotion();
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start 0.9', 'center 0.3'] });
  const spread = useTransform(scrollYProgress, [0, 1], [still ? 1 : 0.45, 1]);
  const leftX = useTransform(spread, (v) => `${-62 * v}%`);
  const rightX = useTransform(spread, (v) => `${62 * v}%`);
  const leftRotate = useTransform(spread, (v) => -10 * v);
  const rightRotate = useTransform(spread, (v) => 10 * v);
  const y = useTransform(scrollYProgress, [0, 1], [still ? 36 : 70, 36]);

  return (
    // Left and right are physical in both languages, so the arrangement stays the same in Arabic.
    <div ref={ref} dir="ltr" className="relative mx-auto w-[240px] sm:w-[290px] lg:w-[310px]">
      <motion.div style={{ x: leftX, y, rotate: leftRotate }} className="absolute inset-x-0 top-0 origin-bottom">
        <Phone src={bikerToday} alt={screens.bikerToday} className="w-full" />
      </motion.div>
      <motion.div style={{ x: rightX, y, rotate: rightRotate }} className="absolute inset-x-0 top-0 origin-bottom">
        <Phone src={bookingOrder} alt={screens.bookingOrder} className="w-full" />
      </motion.div>
      <Phone src={customerHome} alt={screens.customerHome} priority className="relative w-full" />
    </div>
  );
}
