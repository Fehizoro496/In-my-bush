package mg.inmybush.api.common;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

/** Builds bounded {@link Pageable}s from the {@code ?page=&size=} query parameters. */
public final class Pages {

    public static final int DEFAULT_SIZE = 20;
    public static final int MAX_SIZE = 100;

    private Pages() {
    }

    public static Pageable of(int page, int size, Sort sort) {
        int safePage = Math.max(page, 0);
        int safeSize = size <= 0 ? DEFAULT_SIZE : Math.min(size, MAX_SIZE);
        return PageRequest.of(safePage, safeSize, sort == null ? Sort.unsorted() : sort);
    }

    public static Pageable of(int page, int size) {
        return of(page, size, Sort.unsorted());
    }

    public static Pageable newestFirst(int page, int size) {
        return of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
    }
}
