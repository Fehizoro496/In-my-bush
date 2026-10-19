import Link from "next/link";
import type { ReportTarget } from "@/lib/api/admin-contract";
import { PRODUCT_STATUS, REPORT_TARGET, SHOP_STATUS, USER_STATUS, type Tag } from "@/lib/admin/labels";
import { ROUTES, withQuery } from "@/lib/routing/routes";
import type { ReportTargetType } from "@/lib/types";
import { AdminTag } from "./AdminTag";

const STATUS_TAGS: Partial<Record<ReportTargetType, Record<string, Tag>>> = { PRODUCT: PRODUCT_STATUS, SHOP: SHOP_STATUS, USER: USER_STATUS };

/** The reported content, with the links that lead to the decisions the moderator can take on it. */
export function AdminReportTarget({ type, target: t }: { type: ReportTargetType; target: ReportTarget }) {
  const tags = STATUS_TAGS[type];
  return <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5">
    <h2 className="font-bold">{REPORT_TARGET[type] ?? type} signalé</h2>
    {!t.found ? <p className="m-0 text-muted">Ce contenu a été supprimé depuis le signalement.</p> : <>
      <p className="m-0 flex flex-wrap items-center gap-2"><b>{t.title}</b>{tags && t.status && <AdminTag tags={tags} value={t.status} />}</p>
      {t.excerpt && <blockquote className="m-0 whitespace-pre-wrap border-l-4 border-line pl-3">{t.excerpt}</blockquote>}
      <ul className="m-0 flex list-none flex-wrap gap-x-5 gap-y-2 p-0 text-[14px]">
        {type === "PRODUCT" && t.shopId && t.title &&
          <li><Link href={withQuery(ROUTES.adminProducts, { shopId: t.shopId, q: t.title, status: "ALL" })}>Modérer le produit</Link></li>}
        {t.productSlug && <li><Link href={ROUTES.product(t.productSlug)} target="_blank">Voir la fiche publique</Link></li>}
        {t.userId && <li><Link href={ROUTES.adminUser(t.userId)}>Compte : {t.userName ?? "inconnu"}</Link></li>}
        {t.shopId && <li><Link href={ROUTES.adminShop(t.shopId)}>Boutique : {t.shopName}</Link></li>}
      </ul>
    </>}
  </section>;
}
