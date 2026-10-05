package mg.inmybush.api.catalog.repository;

import java.util.Arrays;
import java.util.Objects;
import org.springframework.data.jpa.domain.Specification;

/** Null-tolerant AND of specifications. */
public final class Specs {

    private Specs() {
    }

    @SafeVarargs
    public static <T> Specification<T> allOf(Specification<T>... specs) {
        Specification<T> all = (root, query, cb) -> cb.conjunction();
        for (Specification<T> spec : Arrays.stream(specs).filter(Objects::nonNull).toList()) {
            all = all.and(spec);
        }
        return all;
    }
}
