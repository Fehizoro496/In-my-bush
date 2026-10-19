package mg.inmybush.api.admin;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.admin.service.AdminShopService;
import mg.inmybush.api.admin.service.AuditService;
import mg.inmybush.api.admin.service.ModerationNotifier;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.ApiException;
import mg.inmybush.api.order.repository.OrderRepository;
import mg.inmybush.api.report.repository.ReportRepository;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.entity.ShopStatus;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.user.entity.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class AdminShopServiceTest {
    ShopRepository shops = mock(ShopRepository.class);
    ProductRepository products = mock(ProductRepository.class);
    AuditService audit = mock(AuditService.class);
    ModerationNotifier notifier = mock(ModerationNotifier.class);
    AdminShopService service = new AdminShopService(shops, products, mock(OrderRepository.class),
        mock(ReportRepository.class), audit, notifier);
    Shop shop;

    @BeforeEach void setup() {
        User owner = new User("Hery", "Rakoto", null, "+261341234567", "hash");
        owner.setId(UUID.randomUUID());
        shop = new Shop(owner, "Le Jardin de Hery", "le-jardin-de-hery");
        shop.setId(UUID.randomUUID());
        when(shops.findWithOwnerById(shop.getId())).thenReturn(Optional.of(shop));
        when(products.countByShopAndStatus(any())).thenReturn(List.of(new ProductRepository.ShopStatusCount() {
            public UUID getShopId() { return shop.getId(); }
            public ProductStatus getStatus() { return ProductStatus.PUBLISHED; }
            public long getCnt() { return 4; }
        }));
    }

    @Test void suspensionHidesTheShopAndTellsItsOwner() {
        var result = service.suspend(shop.getId(), " Commandes jamais livrées ");
        assertEquals(ShopStatus.SUSPENDED, shop.getStatus());
        assertFalse(shop.isActive());
        assertEquals(4L, result.productCounts().get(ProductStatus.PUBLISHED));
        assertEquals(0L, result.productCounts().get(ProductStatus.PENDING_REVIEW));
        assertEquals("Hery Rakoto", result.ownerName());
        verify(audit).record("SHOP_SUSPENDED", "SHOP", shop.getId(), "Commandes jamais livrées");
        verify(notifier).shopSuspended(shop, "Commandes jamais livrées");
    }

    @Test void aSuspendedShopIsNotSuspendedTwice() {
        shop.setStatus(ShopStatus.SUSPENDED);
        var error = assertThrows(ApiException.class, () -> service.suspend(shop.getId(), "Encore"));
        assertEquals("INVALID_SHOP_STATUS", error.getCode());
        verifyNoInteractions(audit, notifier);
    }

    @Test void onlyASuspendedShopIsReactivated() {
        shop.setStatus(ShopStatus.PAUSED);
        assertThrows(ApiException.class, () -> service.reactivate(shop.getId()));
        shop.setStatus(ShopStatus.SUSPENDED);
        service.reactivate(shop.getId());
        assertEquals(ShopStatus.ACTIVE, shop.getStatus());
        verify(audit).record("SHOP_REACTIVATED", "SHOP", shop.getId(), null);
        verify(notifier).shopReactivated(shop);
    }

    @Test void anUnknownShopIsNotFound() {
        var error = assertThrows(ApiException.class, () -> service.suspend(UUID.randomUUID(), "Motif"));
        assertEquals(404, error.getStatus().value());
    }
}
