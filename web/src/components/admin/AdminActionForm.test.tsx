import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it, vi } from "vitest";

vi.mock("@/lib/admin/actions", () => ({ adminMutation: vi.fn() }));
const { AdminActionForm } = await import("./AdminActionForm");
const actions = [{ value: "suspend", label: "Suspendre" }, { value: "ban", label: "Bannir" }];

describe("AdminActionForm", () => {
  it("shows the reason field next to the buttons", () => {
    const html = renderToStaticMarkup(<AdminActionForm id="x" reason actions={actions} />);
    expect(html).toContain("<textarea");
    expect(html).toContain('type="submit"');
  });

  it("keeps a table row on one line in compact mode: the reason is asked in a dialog", () => {
    const html = renderToStaticMarkup(<AdminActionForm compact id="x" reason actions={actions} />);
    expect(html).not.toContain("<textarea");
    expect(html).not.toContain('type="submit"');
    expect(html).toContain("Suspendre");
    expect(html).toContain("Bannir");
  });
});
