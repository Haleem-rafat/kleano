import { PageSkeleton } from '@UI/Skeleton/Skeleton';

/** App start: the shell (sidebar + page) as a skeleton instead of a spinner. */
const SuspenseLoader = () => (
  <div className="flex min-h-screen bg-background" aria-busy aria-label="Loading">
    <aside className="hidden w-60 shrink-0 flex-col gap-6 bg-sidebar px-5 py-5 md:flex">
      <span className="block h-8 w-24 animate-pulse rounded-md bg-white/10" />
      {[4, 3, 5, 4].map((n, g) => (
        <div key={g} className="space-y-3">
          <span className="block h-2.5 w-16 animate-pulse rounded bg-white/10" />
          {Array.from({ length: n }).map((_, i) => (
            <span key={i} className="block h-4 w-36 animate-pulse rounded bg-white/10" />
          ))}
        </div>
      ))}
    </aside>
    <div className="flex-1">
      <div className="h-14 border-b border-border bg-card" />
      <div className="p-4 sm:p-6">
        <PageSkeleton kind="list" />
      </div>
    </div>
  </div>
);

export default SuspenseLoader;
