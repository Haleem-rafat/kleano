import type { SVGProps } from 'react';

/** Store logos (lucide has no brand icons). Everything else uses lucide-react. */

export const AppleIcon = (props: SVGProps<SVGSVGElement>) => (
  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" {...props}>
    <path
      fill="currentColor"
      d="M16.4 12.6c0-2.5 2-3.6 2.1-3.7a4.6 4.6 0 0 0-3.6-2c-1.5-.2-3 .9-3.7.9-.8 0-2-.9-3.2-.8a4.8 4.8 0 0 0-4.1 2.5c-1.8 3-.5 7.6 1.3 10.1.8 1.2 1.8 2.6 3.1 2.5 1.3 0 1.7-.8 3.2-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.4a10 10 0 0 0 1.4-2.8 4.3 4.3 0 0 1-2.7-4.3ZM14 5.3A4.3 4.3 0 0 0 15 2a4.4 4.4 0 0 0-2.9 1.5 4.1 4.1 0 0 0-1 3.1A3.6 3.6 0 0 0 14 5.3Z"
    />
  </svg>
);

export const PlayIcon = (props: SVGProps<SVGSVGElement>) => (
  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" {...props}>
    <path
      fill="currentColor"
      d="M4.6 2.8 13.9 12l-9.3 9.2a1.5 1.5 0 0 1-.6-1.2V4a1.5 1.5 0 0 1 .6-1.2Zm10.7 7.8 2.5-2.5 3 1.7c1.1.6 1.1 2 0 2.6l-3 1.7-2.5-2.5L14.6 12Zm-1.4 2.8 2.4 2.4L6 21.5l7.9-8.1Zm0-2.8L6 2.5l10.3 5.7Z"
    />
  </svg>
);
