import type { StatusTone } from "@/components/ui/Badge";

/** French label and colour of each backoffice value shown as a tag. Unknown values keep their code. */
export type Tag = { label: string; tone: StatusTone };

export const USER_STATUS: Record<string, Tag> = {
  ACTIVE: { label: "Actif", tone: "done" },
  SUSPENDED: { label: "Suspendu", tone: "warning" },
  BANNED: { label: "Banni", tone: "danger" },
};

export const ROLE: Record<string, Tag> = {
  BUYER: { label: "Acheteur", tone: "neutral" },
  SELLER: { label: "Vendeur", tone: "info" },
  ADMIN: { label: "Administrateur", tone: "success" },
};

export const PRODUCT_STATUS: Record<string, Tag> = {
  PENDING_REVIEW: { label: "À valider", tone: "warning" },
  PUBLISHED: { label: "Publié", tone: "done" },
  REJECTED: { label: "Refusé", tone: "danger" },
  DRAFT: { label: "Brouillon", tone: "neutral" },
  ARCHIVED: { label: "Archivé", tone: "neutral" },
};

export const CATEGORY_STATE: Record<string, Tag> = {
  ACTIVE: { label: "Active", tone: "done" },
  INACTIVE: { label: "Désactivée", tone: "neutral" },
};

export const ORDER_STATUS: Record<string, Tag> = {
  PENDING_CONFIRMATION: { label: "À confirmer", tone: "warning" },
  ACCEPTED: { label: "Acceptée", tone: "info" },
  PREPARED: { label: "Préparée", tone: "info" },
  IN_DELIVERY: { label: "En livraison", tone: "info" },
  DELIVERED: { label: "Livrée", tone: "done" },
  REFUSED: { label: "Refusée", tone: "danger" },
  CANCELLED: { label: "Annulée", tone: "neutral" },
};

export const PAYMENT_STATUS: Record<string, Tag> = {
  PENDING: { label: "En attente", tone: "warning" },
  HELD: { label: "En séquestre", tone: "info" },
  RELEASED: { label: "Versé au vendeur", tone: "done" },
  REFUNDED: { label: "Remboursé", tone: "neutral" },
  FAILED: { label: "Échoué", tone: "danger" },
};

export const AUDIT_ACTION: Record<string, Tag> = {
  USER_SUSPENDED: { label: "Compte suspendu", tone: "warning" },
  USER_BANNED: { label: "Compte banni", tone: "danger" },
  USER_REACTIVATED: { label: "Compte réactivé", tone: "done" },
  PRODUCT_APPROVED: { label: "Produit approuvé", tone: "done" },
  PRODUCT_REJECTED: { label: "Produit refusé", tone: "danger" },
  REPORT_RESOLVED: { label: "Signalement résolu", tone: "done" },
  REPORT_DISMISSED: { label: "Signalement classé", tone: "neutral" },
  REPORT_IN_REVIEW: { label: "Signalement en cours", tone: "info" },
  SETTINGS_UPDATED: { label: "Réglages modifiés", tone: "info" },
  CATEGORY_CREATED: { label: "Catégorie créée", tone: "done" },
  CATEGORY_UPDATED: { label: "Catégorie modifiée", tone: "info" },
  CATEGORY_MOVED: { label: "Catégorie déplacée", tone: "info" },
  CATEGORY_DEACTIVATED: { label: "Catégorie désactivée", tone: "warning" },
  CATEGORY_REACTIVATED: { label: "Catégorie réactivée", tone: "done" },
};

export const TARGET_TYPE: Record<string, string> = { USER: "Compte", PRODUCT: "Produit", REPORT: "Signalement", ORDER: "Commande", SHOP: "Boutique", PLATFORM: "Plateforme", CATEGORY: "Catégorie" };

export const tagOf = (tags: Record<string, Tag>, value: string): Tag => tags[value] ?? { label: value, tone: "neutral" };
