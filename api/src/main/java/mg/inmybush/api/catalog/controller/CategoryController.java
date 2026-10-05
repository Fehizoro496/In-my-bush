package mg.inmybush.api.catalog.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import mg.inmybush.api.catalog.dto.CategoryResponse;
import mg.inmybush.api.catalog.service.CategoryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/categories")
@Tag(name = "Catalogue")
@SecurityRequirements
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    @Operation(summary = "Catégories (liste à plat, parentId pour l'arborescence) avec nombre de produits")
    public List<CategoryResponse> list() {
        return categoryService.list();
    }
}
