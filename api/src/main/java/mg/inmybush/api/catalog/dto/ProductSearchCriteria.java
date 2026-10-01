package mg.inmybush.api.catalog.dto;

/**
 * Public catalogue filters.
 *
 * @param q        free text on name, description and shop name
 * @param category category slug (children included)
 * @param region   origin region or shop region/city
 * @param shop     shop slug
 * @param sort     newest | price_asc | price_desc | rating | popular
 */
public record ProductSearchCriteria(String q, String category, String region, Long minPrice, Long maxPrice, Boolean inStock,
                                    String shop, String sort) {
}
