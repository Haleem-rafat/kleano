const PREFIX = 'tabby-wltopup:';

/** Tabby checkout `order.reference_id` for wallet top-ups (not a Mongo ObjectId). */
export function buildTabbyWalletTopUpOrderReferenceId(
  userId: string,
  amountSar: number,
): string {
  const minor = Math.round(Number(amountSar.toFixed(2)) * 100);
  return `${PREFIX}${userId}:${minor}`;
}

export function parseTabbyWalletTopUpOrderReferenceId(
  ref: string,
): { userId: string; amountSar: number } | null {
  if (!ref?.startsWith(PREFIX)) return null;
  const rest = ref.slice(PREFIX.length);
  const lastColon = rest.lastIndexOf(':');
  if (lastColon <= 0 || lastColon === rest.length - 1) return null;
  const userId = rest.slice(0, lastColon);
  const minorStr = rest.slice(lastColon + 1);
  if (!/^\d+$/.test(minorStr)) return null;
  if (!/^[a-fA-F0-9]{24}$/.test(userId)) return null;
  const minor = parseInt(minorStr, 10);
  return { userId, amountSar: minor / 100 };
}
