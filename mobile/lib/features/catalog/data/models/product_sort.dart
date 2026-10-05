
/// Sort order of the catalogue (`sort` query parameter).
enum ProductSort {
  relevance('relevance', 'Pertinence'),
  newest('newest', 'Nouveautés'),
  priceAsc('price_asc', 'Prix croissant'),
  priceDesc('price_desc', 'Prix décroissant'),
  rating('rating', 'Mieux notés');

  const ProductSort(this.apiName, this.label);

  final String apiName;
  final String label;
}
