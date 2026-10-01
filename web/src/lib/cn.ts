import { twMerge } from "tailwind-merge";

type ClassValue = string | boolean | null | undefined | number | bigint;

/** Joins class names and resolves Tailwind conflicts (the last class wins). */
export function cn(...classes: ClassValue[]): string {
  return twMerge(classes.filter((c) => typeof c === "string" && c).join(" "));
}
