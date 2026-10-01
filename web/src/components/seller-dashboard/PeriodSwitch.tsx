"use client";

import { TabList } from "@/components/ui/Tabs";

/** Period segmented control ("7 jours · 30 jours · 12 mois"). */
export function PeriodSwitch({ options, defaultValue }: { options: string[]; defaultValue: string }) {
  return (
    <TabList
      variant="segmented"
      size="sm"
      label="Période"
      defaultValue={defaultValue}
      items={options.map((o) => ({ value: o, label: o }))}
      className="rounded-[10px] p-[3px]"
    />
  );
}
