package mg.inmybush.api.catalog.dto;

import java.util.List;
import java.util.UUID;

/** Search-as-you-type: a few products, categories and shops matching the prefix. */
public record SuggestionsResponse(List<Item> products, List<Item> categories, List<Item> shops) {

    public record Item(UUID id, String slug, String label, String imageUrl) {
    }

    public static SuggestionsResponse empty() {
        return new SuggestionsResponse(List.of(), List.of(), List.of());
    }
}
