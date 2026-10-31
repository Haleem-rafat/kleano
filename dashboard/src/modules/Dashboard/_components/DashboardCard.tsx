import { ReactNode } from 'react';
import { Link } from 'react-router-dom';

interface IDashboardCardProps {
  title: string;
  count?: number;
  icon: ReactNode;
  to: string;
}

/** One headline number; opens the page behind it. */
const DashboardCard = ({ title, count, icon, to }: IDashboardCardProps) => (
  <Link
    to={to}
    className="group rounded-xl border border-slate-200 bg-white p-5 transition-colors hover:border-primary/40 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary">
    <div className="flex items-center justify-between gap-3">
      <span className="text-[13px] font-medium capitalize text-slate-500">{title}</span>
      <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-brandTint text-primary">
        {icon}
      </span>
    </div>
    {count === undefined ? (
      <div className="mt-2 h-8 w-20 animate-pulse rounded-md bg-slate-200/70 motion-reduce:animate-none" />
    ) : (
      <p className="mt-2 text-[28px] font-semibold leading-8 tracking-tight tabular-nums text-slate-900">
        {count.toLocaleString()}
      </p>
    )}
  </Link>
);

export default DashboardCard;
