"use client";

import { useSyncExternalStore } from "react";

const subscribe = () => () => {};

/** false during SSR and hydration, true afterwards (safe for portals). */
export function useIsClient(): boolean {
  return useSyncExternalStore(
    subscribe,
    () => true,
    () => false,
  );
}
