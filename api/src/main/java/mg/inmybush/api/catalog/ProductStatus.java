package mg.inmybush.api.catalog;

/** DRAFT → PENDING_REVIEW → PUBLISHED | REJECTED (with reason); ARCHIVED when the seller withdraws it. */
public enum ProductStatus {
    DRAFT, PENDING_REVIEW, PUBLISHED, REJECTED, ARCHIVED
}
