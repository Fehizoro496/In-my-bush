import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it } from "vitest";
import { Table, THead, Th } from "./Table";

const markup = (fill?: boolean) => renderToStaticMarkup(<Table fill={fill}><THead><Th>Nom</Th></THead><tbody /></Table>);

describe("Table", () => {
  it("keeps a plain table at its minimum width", () => {
    expect(markup()).toContain("min-width:720px");
    expect(markup()).not.toContain("overflow-hidden");
  });

  it("never scrolls a filling table on large screens", () => {
    const html = markup(true);
    expect(html).toContain("flex-1");
    expect(html).toContain("lg:overflow-hidden");
    expect(html).toContain("lg:min-w-0");
    expect(html).toContain("lg:[&amp;_td]:whitespace-nowrap");
    expect(html).not.toContain("overflow-y-auto");
  });
});
