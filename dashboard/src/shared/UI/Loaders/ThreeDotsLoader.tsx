/** Placeholder rows over the area that is loading, so nothing jumps. */
export default function ThreeDotsLoader() {
  return (
    <div
      className="min-h-64 absolute inset-x-0 top-0 z-10 w-full animate-pulse space-y-3 bg-background py-2 motion-reduce:animate-none"
      aria-busy="true">
      {[0, 1, 2, 3, 4].map((row) => (
        <div key={row} className="h-11 rounded-lg bg-slate-200/60" />
      ))}
    </div>
  );
}
