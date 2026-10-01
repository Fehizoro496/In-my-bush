/**
 * Data-access switch. Pages never import mocks or the API directly: they call
 * the functions in src/lib/data/*, which return mock data while
 * NEXT_PUBLIC_USE_MOCKS !== "false", and call the REST API otherwise.
 */
export const USE_MOCKS = process.env.NEXT_PUBLIC_USE_MOCKS !== "false";

/** Simulates network latency in mock mode (0 by default). */
export async function mock<T>(value: T, delayMs = 0): Promise<T> {
  if (delayMs > 0) await new Promise((r) => setTimeout(r, delayMs));
  return structuredClone(value);
}
