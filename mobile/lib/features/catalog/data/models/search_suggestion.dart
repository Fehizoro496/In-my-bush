import '../../../../core/utils/json.dart';

/// Search suggestion row.
class SearchSuggestion {
  const SearchSuggestion({required this.text, required this.meta, this.icon = 'search', this.categorySlug});

  /// `GET /search/suggestions` → `{ products, categories, shops }`, each a
  /// list of `{ id, slug, label, imageUrl }`.
  static List<SearchSuggestion> listFromJson(JsonMap json) => [
        ...readList(json['products'], (e) => SearchSuggestion(text: readString(e['label']), meta: 'Produit')),
        ...readList(
          json['categories'],
          (e) => SearchSuggestion(
            text: readString(e['label']),
            meta: 'Catégorie',
            icon: 'layers',
            categorySlug: readStringOrNull(e['slug']),
          ),
        ),
        ...readList(json['shops'], (e) => SearchSuggestion(text: readString(e['label']), meta: 'Producteur', icon: 'store')),
      ];

  final String text;
  final String meta;
  final String icon;
  final String? categorySlug;
}
