package mg.inmybush.api.common;

import java.util.List;
import java.util.function.Function;
import org.springframework.data.domain.Page;

/** Stable pagination envelope shared by every list endpoint. */
public record PageResponse<T>(List<T> items, int page, int size, long totalItems, int totalPages) {

    public static <T> PageResponse<T> of(Page<T> page) {
        return new PageResponse<>(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements(), page.getTotalPages());
    }

    public static <E, T> PageResponse<T> of(Page<E> page, Function<? super E, ? extends T> mapper) {
        return of(page.map(mapper::apply));
    }
}
