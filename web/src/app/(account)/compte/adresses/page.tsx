import type { Metadata } from "next";
import { AddressesView } from "@/components/account/AddressesView";
import { getAddresses } from "@/lib/data/account";

export const metadata: Metadata = { title: "Mes adresses" };

export default async function AddressesPage() {
  const addresses = await getAddresses();
  return <AddressesView addresses={addresses} />;
}
