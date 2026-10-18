import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it } from "vitest";
import { USER_STATUS } from "@/lib/admin/labels";
import { AdminTag } from "./AdminTag";

describe("AdminTag", () => {
  it("shows the French label in the colour of the status", () => {
    const html = renderToStaticMarkup(<AdminTag tags={USER_STATUS} value="BANNED" />);
    expect(html).toContain("Banni");
    expect(html).toContain("bg-danger-bg");
  });
});
