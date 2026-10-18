package mg.inmybush.api.admin.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import mg.inmybush.api.admin.dto.AdminCategoryResponse;
import mg.inmybush.api.admin.dto.CategoryRequest;
import mg.inmybush.api.catalog.entity.Category;
import mg.inmybush.api.catalog.repository.CategoryRepository;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.Slugs;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Categories of the catalogue as the backoffice manages them: two levels at most, ordered among their
 * siblings, withdrawn instead of deleted once their products have been moved to another category.
 */
@Service
public class AdminCategoryService {

    public enum Direction { UP, DOWN }

    private final CategoryRepository categories;
    private final ProductRepository products;
    private final AuditService audit;

    public AdminCategoryService(CategoryRepository categories, ProductRepository products, AuditService audit) {
        this.categories = categories;
        this.products = products;
        this.audit = audit;
    }

    /** Every category, each top-level one followed by its sub-categories, in display order. */
    @Transactional(readOnly = true)
    public List<AdminCategoryResponse> list() {
        Map<UUID, Long> counts = new HashMap<>();
        products.countAllByCategory().forEach(c -> counts.put(c.getCategoryId(), c.getCnt()));
        List<Category> all = categories.findAllOrdered();
        List<AdminCategoryResponse> result = new ArrayList<>();
        for (Category top : all) {
            if (top.getParent() != null) continue;
            result.add(AdminCategoryResponse.from(top, counts.getOrDefault(top.getId(), 0L)));
            for (Category child : all) {
                if (child.getParent() != null && child.getParent().getId().equals(top.getId())) {
                    result.add(AdminCategoryResponse.from(child, counts.getOrDefault(child.getId(), 0L)));
                }
            }
        }
        return result;
    }

    @Transactional
    public AdminCategoryResponse create(CategoryRequest req) {
        Category parent = parentFor(null, req.parentId());
        String slug = availableSlug(req, null);
        int position = siblings(parent).stream().mapToInt(Category::getPosition).max().orElse(0) + 1;
        Category category = categories.save(new Category(parent, req.name().trim(), slug, blankToNull(req.icon()), position));
        audit.record("CATEGORY_CREATED", "CATEGORY", category.getId(), category.getName());
        return AdminCategoryResponse.from(category, 0);
    }

    @Transactional
    public AdminCategoryResponse update(UUID id, CategoryRequest req) {
        Category category = require(id);
        Category parent = parentFor(category, req.parentId());
        if (!sameCategory(parent, category.getParent())) {
            category.setPosition(siblings(parent).stream().mapToInt(Category::getPosition).max().orElse(0) + 1);
            category.setParent(parent);
        }
        category.setName(req.name().trim());
        category.setSlug(availableSlug(req, id));
        category.setIcon(blankToNull(req.icon()));
        audit.record("CATEGORY_UPDATED", "CATEGORY", id, category.getName());
        return AdminCategoryResponse.from(category, productCount(id));
    }

    /** Swaps the category with its previous or next sibling. */
    @Transactional
    public void move(UUID id, Direction direction) {
        Category category = require(id);
        List<Category> siblings = siblings(category.getParent());
        for (int i = 0; i < siblings.size(); i++) siblings.get(i).setPosition(i + 1);
        int index = siblings.indexOf(category);
        int other = direction == Direction.UP ? index - 1 : index + 1;
        if (other < 0 || other >= siblings.size()) return;
        Category neighbour = siblings.get(other);
        int position = category.getPosition();
        category.setPosition(neighbour.getPosition());
        neighbour.setPosition(position);
        audit.record("CATEGORY_MOVED", "CATEGORY", id, direction == Direction.UP ? "Monter" : "Descendre");
    }

    /**
     * Withdraws a category from the catalogue. Its products, whatever their status, first go to
     * {@code replacementId}, which is required as soon as there is one.
     */
    @Transactional
    public AdminCategoryResponse deactivate(UUID id, UUID replacementId) {
        Category category = require(id);
        if (!category.isActive()) return AdminCategoryResponse.from(category, productCount(id));
        if (categories.findAllOrdered().stream().anyMatch(c -> c.isActive() && sameCategory(c.getParent(), category))) {
            throw new ConflictException("CATEGORY_HAS_CHILDREN", "Désactivez d'abord les sous-catégories de « " + category.getName() + " ».");
        }
        long count = productCount(id);
        String reason = null;
        if (count > 0) {
            if (replacementId == null) {
                throw new ConflictException("CATEGORY_HAS_PRODUCTS",
                    count + " produit(s) sont rattachés à cette catégorie : choisissez la catégorie qui les reçoit.");
            }
            Category replacement = require(replacementId);
            if (replacement.getId().equals(id) || !replacement.isActive()) {
                throw new BadRequestException("Choisissez une autre catégorie active pour recevoir les produits.");
            }
            int moved = products.moveToCategory(id, replacement);
            reason = moved + " produit(s) déplacé(s) vers « " + replacement.getName() + " »";
        }
        category.setActive(false);
        audit.record("CATEGORY_DEACTIVATED", "CATEGORY", id, reason);
        return AdminCategoryResponse.from(category, 0);
    }

    @Transactional
    public AdminCategoryResponse reactivate(UUID id) {
        Category category = require(id);
        if (category.getParent() != null && !category.getParent().isActive()) {
            throw new ConflictException("CATEGORY_PARENT_INACTIVE", "Réactivez d'abord « " + category.getParent().getName() + " ».");
        }
        category.setActive(true);
        audit.record("CATEGORY_REACTIVATED", "CATEGORY", id, null);
        return AdminCategoryResponse.from(category, productCount(id));
    }

    // ------------------------------------------------------------------ helpers

    private Category require(UUID id) {
        return categories.findById(id).orElseThrow(() -> NotFoundException.of("Catégorie", id));
    }

    /** The parent asked for {@code category} (null when creating), checked to keep two levels at most. */
    private Category parentFor(Category category, UUID parentId) {
        if (parentId == null) return null;
        Category parent = require(parentId);
        if (category != null && parent.getId().equals(category.getId())) {
            throw new BadRequestException("Une catégorie ne peut pas être sa propre catégorie parente.");
        }
        if (parent.getParent() != null) {
            throw new BadRequestException("La catégorie parente doit être une catégorie principale.");
        }
        if (!parent.isActive()) {
            throw new BadRequestException("La catégorie parente est désactivée.");
        }
        if (category != null && categories.findAllOrdered().stream().anyMatch(c -> sameCategory(c.getParent(), category))) {
            throw new BadRequestException("Une catégorie qui a des sous-catégories ne peut pas devenir une sous-catégorie.");
        }
        return parent;
    }

    private String availableSlug(CategoryRequest req, UUID id) {
        String slug = Slugs.slugify(req.slug() == null || req.slug().isBlank() ? req.name() : req.slug());
        boolean taken = id == null ? categories.existsBySlug(slug) : categories.existsBySlugAndIdNot(slug, id);
        if (taken) throw new ConflictException("CATEGORY_SLUG_TAKEN", "Le lien « " + slug + " » est déjà utilisé par une autre catégorie.");
        return slug;
    }

    private List<Category> siblings(Category parent) {
        return categories.findAllOrdered().stream()
            .filter(c -> sameCategory(c.getParent(), parent))
            .sorted(Comparator.comparingInt(Category::getPosition).thenComparing(Category::getName))
            .collect(java.util.stream.Collectors.toCollection(ArrayList::new));
    }

    private long productCount(UUID id) {
        return products.countAllByCategory().stream().filter(c -> c.getCategoryId().equals(id))
            .mapToLong(c -> c.getCnt()).sum();
    }

    private static boolean sameCategory(Category a, Category b) {
        return Objects.equals(a == null ? null : a.getId(), b == null ? null : b.getId());
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
