package mg.inmybush.api.catalog.service;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import mg.inmybush.api.catalog.dto.CategoryResponse;
import mg.inmybush.api.catalog.entity.Category;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.catalog.repository.CategoryRepository;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CategoryService {

    private final CategoryRepository categories;
    private final ProductRepository products;

    public CategoryService(CategoryRepository categories, ProductRepository products) {
        this.categories = categories;
        this.products = products;
    }

    /** Flat list ordered by position, with the number of visible products (parents include their children). */
    @Transactional(readOnly = true)
    public List<CategoryResponse> list() {
        List<Category> all = categories.findAllOrdered();
        Map<UUID, Long> direct = new HashMap<>();
        products.countByCategory(ProductStatus.PUBLISHED).forEach(c -> direct.put(c.getCategoryId(), c.getCnt()));
        Map<UUID, Long> total = new HashMap<>(direct);
        for (Category c : all) {
            if (c.getParent() != null) {
                total.merge(c.getParent().getId(), direct.getOrDefault(c.getId(), 0L), Long::sum);
            }
        }
        return all.stream()
            .map(c -> new CategoryResponse(c.getId(), c.getParent() == null ? null : c.getParent().getId(), c.getName(),
                c.getSlug(), c.getIcon(), c.getPosition(), total.getOrDefault(c.getId(), 0L)))
            .toList();
    }

    @Transactional(readOnly = true)
    public Category require(UUID id) {
        return categories.findById(id).orElseThrow(() -> NotFoundException.of("Catégorie", id));
    }

    /** The category and all its descendants, for filtering. */
    @Transactional(readOnly = true)
    public Set<UUID> idsWithDescendants(String slug) {
        Category root = categories.findBySlug(slug).orElseThrow(() -> NotFoundException.of("Catégorie", slug));
        List<Category> all = categories.findAllOrdered();
        Set<UUID> ids = new HashSet<>();
        ids.add(root.getId());
        boolean added = true;
        while (added) {
            added = false;
            for (Category c : all) {
                if (c.getParent() != null && ids.contains(c.getParent().getId()) && ids.add(c.getId())) {
                    added = true;
                }
            }
        }
        return ids;
    }
}
