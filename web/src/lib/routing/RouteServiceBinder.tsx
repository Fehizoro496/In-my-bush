"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { routeService } from "./route.service";

/** Gives routeService the Next.js router. Mounted once, in the root layout. */
export function RouteServiceBinder() {
  const router = useRouter();
  useEffect(() => {
    routeService.bind(router);
    return () => routeService.bind(null);
  }, [router]);
  return null;
}
