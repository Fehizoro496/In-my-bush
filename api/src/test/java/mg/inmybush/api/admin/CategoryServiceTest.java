package mg.inmybush.api.admin;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.Category;
import mg.inmybush.api.catalog.repository.CategoryRepository;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.catalog.service.CategoryService;
import mg.inmybush.api.common.ApiException;
import org.junit.jupiter.api.Test;

class CategoryServiceTest {
    CategoryRepository categories = mock(CategoryRepository.class);
    CategoryService service = new CategoryService(categories, mock(ProductRepository.class));

    Category category(String name, boolean active) {
        Category c = new Category(null, name, name.toLowerCase(), null, 1);
        c.setId(UUID.randomUUID());
        c.setActive(active);
        when(categories.findById(c.getId())).thenReturn(Optional.of(c));
        return c;
    }

    @Test void theCatalogueOnlyListsActiveCategories() {
        Category open = category("Épicerie", true);
        Category closed = category("Anciens", false);
        when(categories.findAllOrdered()).thenReturn(List.of(open, closed));
        assertEquals(List.of("Épicerie"), service.list().stream().map(c -> c.name()).toList());
    }

    @Test void sellersCannotUseADeactivatedCategory() {
        Category closed = category("Anciens", false);
        ApiException error = assertThrows(ApiException.class, () -> service.requireActive(closed.getId()));
        assertEquals("CATEGORY_INACTIVE", error.getCode());
        Category open = category("Épicerie", true);
        assertSame(open, service.requireActive(open.getId()));
    }
}
