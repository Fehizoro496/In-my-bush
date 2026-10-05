package mg.inmybush.api.catalog.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.catalog.entity.Category;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CategoryRepository extends JpaRepository<Category, UUID> {

    Optional<Category> findBySlug(String slug);

    @Query("select c from Category c left join fetch c.parent order by c.position asc, c.name asc")
    List<Category> findAllOrdered();

    @Query("select c from Category c where lower(c.name) like lower(concat('%', :q, '%')) order by c.position")
    List<Category> searchByName(@Param("q") String q, Pageable pageable);
}
