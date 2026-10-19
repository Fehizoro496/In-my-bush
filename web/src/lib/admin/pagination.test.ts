import { describe, expect, it } from "vitest";
import { DEFAULT_PAGE_SIZE, MAX_ROWS, MIN_ROWS, fittingRows, pageOf, pageRange, pagerQuery, parsePage, parsePageSize, parseRows, rowsCookie } from "./pagination";

describe("backoffice pagination", () => {
  it("only accepts the listed page sizes", () => {
    expect(parsePageSize("25")).toBe(25);
    expect(parsePageSize("50")).toBe(50);
    expect(parsePageSize(undefined)).toBe(DEFAULT_PAGE_SIZE);
    expect(parsePageSize("5000")).toBe(DEFAULT_PAGE_SIZE);
    expect(parsePageSize("abc")).toBe(DEFAULT_PAGE_SIZE);
  });

  it("reads the remembered rows of a table within bounds", () => {
    expect(parseRows("7")).toBe(7);
    expect(parseRows(String(MIN_ROWS))).toBe(MIN_ROWS);
    expect(parseRows(String(MAX_ROWS))).toBe(MAX_ROWS);
    expect(parseRows(undefined)).toBe(DEFAULT_PAGE_SIZE);
    expect(parseRows("2")).toBe(DEFAULT_PAGE_SIZE);
    expect(parseRows("51")).toBe(DEFAULT_PAGE_SIZE);
    expect(parseRows("7.5")).toBe(DEFAULT_PAGE_SIZE);
    expect(rowsCookie("users")).toBe("imb_rows_users");
  });

  it("counts the rows that fit on screen", () => {
    expect(fittingRows(560, 56)).toBe(10);
    expect(fittingRows(559, 56)).toBe(9);
    expect(fittingRows(100, 56)).toBe(MIN_ROWS);
    expect(fittingRows(10000, 40)).toBe(MAX_ROWS);
    expect(fittingRows(500, 0)).toBe(MIN_ROWS);
  });

  it("reads a 1-based page and falls back to the first", () => {
    expect(parsePage("3")).toBe(3);
    expect(parsePage("2.9")).toBe(2);
    expect(parsePage(undefined)).toBe(1);
    expect(parsePage("0")).toBe(1);
    expect(parsePage("-4")).toBe(1);
    expect(parsePage("x")).toBe(1);
  });

  it("cuts one page out of a whole list", () => {
    const all = [1, 2, 3, 4, 5, 6, 7];
    expect(pageOf(all, 1, 3)).toEqual({ items: [1, 2, 3], page: 0, size: 3, totalItems: 7, totalPages: 3 });
    expect(pageOf(all, 3, 3).items).toEqual([7]);
    expect(pageOf(all, 9, 3).page).toBe(2);
    expect(pageOf([], 1, 3)).toEqual({ items: [], page: 0, size: 3, totalItems: 0, totalPages: 1 });
  });

  it("gives the rows shown on a page", () => {
    expect(pageRange(0, 10, 10)).toEqual({ from: 1, to: 10 });
    expect(pageRange(1, 10, 4)).toEqual({ from: 11, to: 14 });
    expect(pageRange(2, 25, 25)).toEqual({ from: 51, to: 75 });
    expect(pageRange(0, 10, 0)).toBeNull();
  });

  it("keeps filters in page links and leaves defaults out", () => {
    expect(pagerQuery({ status: "OPEN" }, DEFAULT_PAGE_SIZE, 1)).toEqual({ status: "OPEN", size: undefined, page: undefined });
    expect(pagerQuery({ q: "Hery", role: "SELLER" }, 25, 3)).toEqual({ q: "Hery", role: "SELLER", size: 25, page: 3 });
  });
});
