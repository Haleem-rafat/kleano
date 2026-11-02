import { useLocation } from 'react-router-dom';
import { PageSkeleton } from './Skeleton';

/** Route fallback: picks the skeleton that matches the page being opened. */
export default function RouteSkeleton() {
  const { pathname } = useLocation();
  const parts = pathname.split('/').filter(Boolean);
  const kind =
    parts[1] === 'dashboard'
      ? 'dashboard'
      : ['terms-and-conditions', 'contact-info', 'pointes', 'profile'].includes(parts[1])
      ? 'form'
      : parts.length > 2
      ? 'details'
      : 'list';
  return <PageSkeleton kind={kind} />;
}
