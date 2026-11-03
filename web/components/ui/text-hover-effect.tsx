'use client';

import { motion } from 'motion/react';
import { useId, useRef, useState } from 'react';

/** Aceternity Text Hover Effect, Kleano version: a large outlined word that lights up purple under the pointer. */
export const TextHoverEffect = ({ text }: { text: string }) => {
  const svgRef = useRef<SVGSVGElement>(null);
  const [hovered, setHovered] = useState(false);
  const [mask, setMask] = useState({ cx: '50%', cy: '50%' });
  const id = useId();
  const textClass = 'fill-transparent font-sans text-[64px] font-bold';

  return (
    <svg
      ref={svgRef}
      width="100%"
      viewBox="0 0 300 80"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      onMouseMove={(e) => {
        const box = svgRef.current?.getBoundingClientRect();
        if (box) setMask({ cx: `${((e.clientX - box.left) / box.width) * 100}%`, cy: `${((e.clientY - box.top) / box.height) * 100}%` });
      }}
      className="select-none"
    >
      <defs>
        <radialGradient id={`${id}-mask-fill`} gradientUnits="userSpaceOnUse" r="22%" cx={mask.cx} cy={mask.cy}>
          <stop offset="0%" stopColor="white" />
          <stop offset="100%" stopColor="black" />
        </radialGradient>
        <mask id={`${id}-mask`}>
          <rect x="0" y="0" width="100%" height="100%" fill={`url(#${id}-mask-fill)`} />
        </mask>
      </defs>
      <motion.text
        x="50%"
        y="50%"
        textAnchor="middle"
        dominantBaseline="middle"
        strokeWidth="0.4"
        className={`${textClass} stroke-border`}
        initial={{ strokeDashoffset: 1000, strokeDasharray: 1000 }}
        whileInView={{ strokeDashoffset: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 3, ease: 'easeInOut' }}
      >
        {text}
      </motion.text>
      {hovered ? (
        <text x="50%" y="50%" textAnchor="middle" dominantBaseline="middle" strokeWidth="0.6" mask={`url(#${id}-mask)`} className={`${textClass} stroke-primary`}>
          {text}
        </text>
      ) : null}
    </svg>
  );
};
