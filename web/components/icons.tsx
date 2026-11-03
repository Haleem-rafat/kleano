import type { ReactNode, SVGProps } from 'react';

type IconProps = SVGProps<SVGSVGElement>;

function Icon({ children, ...props }: IconProps & { children: ReactNode }) {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" {...props}>
      {children}
    </svg>
  );
}

const line = { fill: 'none', stroke: 'currentColor', strokeWidth: 2, strokeLinecap: 'round', strokeLinejoin: 'round' } as const;

export const SunIcon = (p: IconProps) => (
  <Icon {...p}>
    <g {...line}>
      <circle cx="12" cy="12" r="4" />
      <path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
    </g>
  </Icon>
);
export const MoonIcon = (p: IconProps) => (
  <Icon {...p}>
    <path {...line} d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5Z" />
  </Icon>
);
export const GlobeIcon = (p: IconProps) => (
  <Icon {...p}>
    <g {...line}>
      <circle cx="12" cy="12" r="9" />
      <path d="M3 12h18M12 3c2.5 2.6 3.8 5.6 3.8 9s-1.3 6.4-3.8 9c-2.5-2.6-3.8-5.6-3.8-9S9.5 5.6 12 3Z" />
    </g>
  </Icon>
);
export const CheckIcon = (p: IconProps) => (
  <Icon {...p}>
    <path {...line} strokeWidth={2.4} d="m5 12.5 4.5 4.5L19 7.5" />
  </Icon>
);
export const PinIcon = (p: IconProps) => (
  <Icon {...p}>
    <g {...line}>
      <path d="M12 21s7-6.2 7-11.5A7 7 0 0 0 5 9.5C5 14.8 12 21 12 21Z" />
      <circle cx="12" cy="9.5" r="2.5" />
    </g>
  </Icon>
);
export const BikeIcon = (p: IconProps) => (
  <Icon {...p}>
    <g {...line}>
      <circle cx="5.5" cy="16.5" r="3.5" />
      <circle cx="18.5" cy="16.5" r="3.5" />
      <path d="M5.5 16.5 9 9h5l4.5 7.5M14 9l-2-3H9.5M12 16.5 14 9" />
    </g>
  </Icon>
);
export const DropIcon = (p: IconProps) => (
  <Icon {...p}>
    <path {...line} d="M12 3s6 6.4 6 11a6 6 0 0 1-12 0c0-4.6 6-11 6-11Z" />
  </Icon>
);
export const CameraIcon = (p: IconProps) => (
  <Icon {...p}>
    <g {...line}>
      <path d="M4 8h3l2-3h6l2 3h3v11H4Z" />
      <circle cx="12" cy="13" r="3.5" />
    </g>
  </Icon>
);
export const WalletIcon = (p: IconProps) => (
  <Icon {...p}>
    <g {...line}>
      <path d="M4 7h14a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a1 1 0 0 1-1-1V7Zm0 0 11-3v3" />
      <circle cx="16" cy="13.5" r="1.2" fill="currentColor" />
    </g>
  </Icon>
);
export const CardIcon = (p: IconProps) => (
  <Icon {...p}>
    <g {...line}>
      <rect x="3" y="5.5" width="18" height="13" rx="2" />
      <path d="M3 10h18M7 15h3" />
    </g>
  </Icon>
);
export const AppleIcon = (p: IconProps) => (
  <Icon {...p}>
    <path
      fill="currentColor"
      d="M16.4 12.6c0-2.5 2-3.6 2.1-3.7a4.6 4.6 0 0 0-3.6-2c-1.5-.2-3 .9-3.7.9-.8 0-2-.9-3.2-.8a4.8 4.8 0 0 0-4.1 2.5c-1.8 3-.5 7.6 1.3 10.1.8 1.2 1.8 2.6 3.1 2.5 1.3 0 1.7-.8 3.2-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.4a10 10 0 0 0 1.4-2.8 4.3 4.3 0 0 1-2.7-4.3ZM14 5.3A4.3 4.3 0 0 0 15 2a4.4 4.4 0 0 0-2.9 1.5 4.1 4.1 0 0 0-1 3.1A3.6 3.6 0 0 0 14 5.3Z"
    />
  </Icon>
);
export const PlayIcon = (p: IconProps) => (
  <Icon {...p}>
    <path
      fill="currentColor"
      d="M4.6 2.8 13.9 12l-9.3 9.2a1.5 1.5 0 0 1-.6-1.2V4a1.5 1.5 0 0 1 .6-1.2Zm10.7 7.8 2.5-2.5 3 1.7c1.1.6 1.1 2 0 2.6l-3 1.7-2.5-2.5L14.6 12Zm-1.4 2.8 2.4 2.4L6 21.5l7.9-8.1Zm0-2.8L6 2.5l10.3 5.7Z"
    />
  </Icon>
);
export const WebIcon = (p: IconProps) => (
  <Icon {...p}>
    <g {...line}>
      <rect x="3" y="4" width="18" height="16" rx="2.5" />
      <path d="M3 9h18" />
    </g>
    <circle cx="6.5" cy="6.5" r=".8" fill="currentColor" />
    <circle cx="9" cy="6.5" r=".8" fill="currentColor" />
  </Icon>
);
export const ArrowIcon = (p: IconProps) => (
  <Icon {...p}>
    <path {...line} strokeWidth={2.2} d="M5 12h14m-6-6 6 6-6 6" />
  </Icon>
);
