import type { Metadata } from "next";
import { PageHeader } from "@/components/layout/Container";
import { BuyerOrderList } from "@/components/orders/BuyerOrderList";
import { Icon } from "@/components/ui/Icon";
import { Select } from "@/components/ui/Form";
import { getMyOrders } from "@/lib/data/account";

export const metadata: Metadata = { title: "Mes commandes" };

export default async function AccountOrdersPage() {
  const orders = await getMyOrders();
  return (
    <>
      <PageHeader
        title="Mes commandes"
        subtitle="14 commandes depuis 2024"
        actions={
          <>
            <label className="flex h-11 w-full items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong bg-white px-3 text-[14px] text-muted sm:w-[280px]">
              <Icon name="search" size={17} />
              <span className="sr-only">Rechercher une commande</span>
              <input placeholder="N° de commande, produit…" className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none" />
            </label>
            <Select
              aria-label="Période"
              size="sm"
              className="h-11 w-[190px] font-semibold"
              options={[
                { value: "6m", label: "6 derniers mois" },
                { value: "12m", label: "12 derniers mois" },
                { value: "all", label: "Depuis le début" },
              ]}
            />
          </>
        }
      />
      <BuyerOrderList orders={orders} />
    </>
  );
}
