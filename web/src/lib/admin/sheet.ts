import "server-only";
import { notFound } from "next/navigation";
import { ApiError } from "@/lib/api/client";

/** A backoffice sheet, or the not-found page when the API knows no such id. */
export async function sheetOrNotFound<T>(load: Promise<T>): Promise<T> {
  try {
    return await load;
  } catch (error) {
    if (error instanceof ApiError && (error.status === 404 || error.status === 400)) notFound();
    throw error;
  }
}
