import path from 'node:path';
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  images: { formats: ['image/avif', 'image/webp'] },
  // This folder is the project root (there is an unrelated package.json in the home folder).
  turbopack: { root: path.resolve(import.meta.dirname) },
  // Project rules live in kleano/CLAUDE.md; don't generate a separate AGENTS.md.
  agentRules: false,
};

export default nextConfig;
