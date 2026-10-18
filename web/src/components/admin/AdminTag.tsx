import { StatusPill } from "@/components/ui/Badge";
import { tagOf, type Tag } from "@/lib/admin/labels";

/** Coloured tag of a status, role or action of the backoffice. */
export function AdminTag({ tags, value }: { tags: Record<string, Tag>; value: string }) {
  const tag = tagOf(tags, value);
  return <StatusPill tone={tag.tone} size="sm">{tag.label}</StatusPill>;
}
