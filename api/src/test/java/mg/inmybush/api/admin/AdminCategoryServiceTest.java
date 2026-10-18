package mg.inmybush.api.admin;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.admin.dto.CategoryRequest;
import mg.inmybush.api.admin.service.AdminCategoryService;
import mg.inmybush.api.admin.service.AdminCategoryService.Direction;
import mg.inmybush.api.admin.service.AuditService;
import mg.inmybush.api.catalog.entity.Category;
import mg.inmybush.api.catalog.repository.CategoryRepository;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.ApiException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class AdminCategoryServiceTest {
    CategoryRepository categories = mock(CategoryRepository.class);
    ProductRepository products = mock(ProductRepository.class);
    AuditService audit = mock(AuditService.class);
    AdminCategoryService service = new AdminCategoryService(categories, products, audit);
    List<Category> all = new ArrayList<>();
    Category fruits = category(null, "Fruits & légumes", 1);
    Category epicerie = category(null, "Épicerie", 2);
    Category agrumes = category(fruits, "Agrumes", 1);

    Category category(Category parent, String name, int position) {
        Category c = new Category(parent, name, name.toLowerCase().replace(' ', '-'), null, position);
        c.setId(UUID.randomUUID());
        all.add(c);
        return c;
    }

    void productsIn(Category c, long count) {
        when(products.countAllByCategory()).thenReturn(List.of(new ProductRepository.CategoryCount() {
            public UUID getCategoryId() { return c.getId(); }
            public long getCnt() { return count; }
        }));
    }

    @BeforeEach void setUp() {
        when(categories.findAllOrdered()).thenAnswer(i -> List.copyOf(all));
        for (Category c : all) when(categories.findById(c.getId())).thenReturn(Optional.of(c));
        when(categories.save(any())).thenAnswer(i -> { Category c = i.getArgument(0); c.setId(UUID.randomUUID()); return c; });
    }

    @Test void createsAtTheEndOfItsSiblingsWithASlugFromTheName() {
        var created = service.create(new CategoryRequest("  Fruits secs ", "", "leaf", fruits.getId()));
        assertEquals("Fruits secs", created.name());
        assertEquals("fruits-secs", created.slug());
        assertEquals(fruits.getId(), created.parentId());
        assertEquals(2, created.position());
        assertTrue(created.active());
        verify(audit).record(eq("CATEGORY_CREATED"), eq("CATEGORY"), eq(created.id()), eq("Fruits secs"));
    }

    @Test void refusesATakenSlug() {
        when(categories.existsBySlug("epicerie")).thenReturn(true);
        var error = assertThrows(ApiException.class, () -> service.create(new CategoryRequest("Épicerie", null, null, null)));
        assertEquals(409, error.getStatus().value());
        verifyNoInteractions(audit);
    }

    @Test void keepsTwoLevelsAtMost() {
        assertThrows(ApiException.class, () -> service.create(new CategoryRequest("Citrons", null, null, agrumes.getId())));
        assertThrows(ApiException.class, () -> service.update(fruits.getId(), new CategoryRequest("Fruits", null, null, epicerie.getId())));
        assertThrows(ApiException.class, () -> service.update(epicerie.getId(), new CategoryRequest("Épicerie", null, null, epicerie.getId())));
    }

    @Test void asksWhereTheProductsGoBeforeDeactivating() {
        productsIn(epicerie, 3);
        var error = assertThrows(ApiException.class, () -> service.deactivate(epicerie.getId(), null));
        assertEquals("CATEGORY_HAS_PRODUCTS", error.getCode());
        assertTrue(epicerie.isActive());
        verify(products, never()).moveToCategory(any(), any());
    }

    @Test void movesTheProductsThenDeactivates() {
        productsIn(epicerie, 3);
        when(products.moveToCategory(epicerie.getId(), fruits)).thenReturn(3);
        var result = service.deactivate(epicerie.getId(), fruits.getId());
        assertFalse(result.active());
        verify(products).moveToCategory(epicerie.getId(), fruits);
        verify(audit).record("CATEGORY_DEACTIVATED", "CATEGORY", epicerie.getId(), "3 produit(s) déplacé(s) vers « Fruits & légumes »");
    }

    @Test void refusesToSendTheProductsToTheCategoryItselfOrAnInactiveOne() {
        productsIn(epicerie, 1);
        assertThrows(ApiException.class, () -> service.deactivate(epicerie.getId(), epicerie.getId()));
        agrumes.setActive(false);
        assertThrows(ApiException.class, () -> service.deactivate(epicerie.getId(), agrumes.getId()));
        assertTrue(epicerie.isActive());
    }

    @Test void deactivatesTheSubCategoriesFirst() {
        var error = assertThrows(ApiException.class, () -> service.deactivate(fruits.getId(), null));
        assertEquals("CATEGORY_HAS_CHILDREN", error.getCode());
        agrumes.setActive(false);
        assertFalse(service.deactivate(fruits.getId(), null).active());
    }

    @Test void reactivatesTheParentFirst() {
        agrumes.setActive(false);
        fruits.setActive(false);
        assertThrows(ApiException.class, () -> service.reactivate(agrumes.getId()));
        fruits.setActive(true);
        assertTrue(service.reactivate(agrumes.getId()).active());
    }

    @Test void swapsWithTheNeighbourAndStaysAtTheEdges() {
        service.move(epicerie.getId(), Direction.UP);
        assertEquals(1, epicerie.getPosition());
        assertEquals(2, fruits.getPosition());
        service.move(epicerie.getId(), Direction.UP);
        assertEquals(1, epicerie.getPosition());
        assertEquals(1, agrumes.getPosition());
    }

    @Test void listsEachSubCategoryUnderItsParent() {
        Category ble = category(epicerie, "Riz", 1);
        when(categories.findAllOrdered()).thenReturn(List.of(fruits, agrumes, epicerie, ble));
        assertEquals(List.of("Fruits & légumes", "Agrumes", "Épicerie", "Riz"), service.list().stream().map(c -> c.name()).toList());
    }
}
