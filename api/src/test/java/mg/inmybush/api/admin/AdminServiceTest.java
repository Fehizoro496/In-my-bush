package mg.inmybush.api.admin;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.admin.service.*;
import mg.inmybush.api.auth.service.RefreshTokenService;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.catalog.service.ProductModerationService;
import mg.inmybush.api.order.repository.OrderRepository;
import mg.inmybush.api.report.repository.ReportRepository;
import mg.inmybush.api.report.service.ReportService;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.user.entity.*;
import mg.inmybush.api.user.repository.UserRepository;
import org.junit.jupiter.api.Test;

class AdminServiceTest {
    @Test void suspendRevokesSessionsAndRecordsTheReason() {
        var users = mock(UserRepository.class);
        var tokens = mock(RefreshTokenService.class);
        var audit = mock(AuditService.class);
        var service = new AdminService(users, mock(ShopRepository.class), mock(ProductRepository.class),
            mock(OrderRepository.class), mock(ReportRepository.class), mock(ReportService.class),
            mock(ProductModerationService.class), tokens, audit);
        var id = UUID.randomUUID();
        var user = new User("Hery", "Test", null, "+261340000000", "hash");
        user.setId(id);
        when(users.findById(id)).thenReturn(Optional.of(user));
        var result = service.suspendUser(id, "  Commandes non honorées  ");
        assertEquals(UserStatus.SUSPENDED, result.status());
        verify(tokens).revokeAll(id);
        verify(audit).record("USER_SUSPENDED", "USER", id, "Commandes non honorées");
    }
}
