package mg.inmybush.api.admin;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.admin.service.*;
import mg.inmybush.api.auth.service.RefreshTokenService;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.catalog.service.ProductModerationService;
import mg.inmybush.api.common.ApiException;
import mg.inmybush.api.order.repository.OrderRepository;
import mg.inmybush.api.report.repository.ReportRepository;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.user.entity.*;
import mg.inmybush.api.user.repository.UserRepository;
import org.junit.jupiter.api.Test;

class AdminServiceTest {
    UserRepository users = mock(UserRepository.class);
    RefreshTokenService tokens = mock(RefreshTokenService.class);
    AuditService audit = mock(AuditService.class);
    ModerationNotifier notifier = mock(ModerationNotifier.class);
    ProductModerationService moderation = mock(ProductModerationService.class);
    AdminService service = new AdminService(users, mock(ShopRepository.class), mock(ProductRepository.class),
        mock(OrderRepository.class), mock(ReportRepository.class), moderation, tokens, audit, notifier);
    UUID adminId = UUID.randomUUID();

    User user(boolean admin) {
        var user = new User("Hery", "Test", null, "+261340000000", "hash");
        user.setId(UUID.randomUUID());
        if (admin) user.addRole(Role.ADMIN);
        when(users.findById(user.getId())).thenReturn(Optional.of(user));
        return user;
    }

    @Test void suspendRevokesSessionsRecordsTheReasonAndTellsTheUser() {
        var user = user(false);
        var result = service.suspendUser(adminId, user.getId(), "  Commandes non honorées  ");
        assertEquals(UserStatus.SUSPENDED, result.status());
        verify(tokens).revokeAll(user.getId());
        verify(audit).record("USER_SUSPENDED", "USER", user.getId(), "Commandes non honorées");
        verify(notifier).accountSuspended(user, "Commandes non honorées", false);
    }

    @Test void anAdministratorCannotSuspendOrBanThemselves() {
        for (var action : List.<Runnable>of(() -> service.suspendUser(adminId, adminId, "Test"),
            () -> service.banUser(adminId, adminId, "Test"))) {
            var error = assertThrows(ApiException.class, action::run);
            assertEquals("SELF_MODERATION", error.getCode());
        }
        verifyNoInteractions(tokens, audit, notifier);
    }

    @Test void theLastActiveAdministratorKeepsTheirAccess() {
        var other = user(true);
        when(users.lockActiveAdmins()).thenReturn(List.of(other));
        var error = assertThrows(ApiException.class, () -> service.banUser(adminId, other.getId(), "Départ"));
        assertEquals("LAST_ADMIN", error.getCode());
        assertEquals(UserStatus.ACTIVE, other.getStatus());
        verifyNoInteractions(tokens, audit, notifier);
    }

    @Test void anotherAdministratorCanBeSuspendedWhileOneRemains() {
        var other = user(true);
        var me = user(true);
        when(users.lockActiveAdmins()).thenReturn(List.of(other, me));
        service.suspendUser(me.getId(), other.getId(), "Compte compromis");
        assertEquals(UserStatus.SUSPENDED, other.getStatus());
    }

    @Test void aDecisionIsNotRepeated() {
        var user = user(false);
        user.setStatus(UserStatus.BANNED);
        assertThrows(ApiException.class, () -> service.banUser(adminId, user.getId(), "Encore"));
        var active = user(false);
        assertThrows(ApiException.class, () -> service.reactivateUser(active.getId()));
        verifyNoInteractions(audit, notifier);
    }

    @Test void reactivationTellsTheUser() {
        var user = user(false);
        user.setStatus(UserStatus.SUSPENDED);
        service.reactivateUser(user.getId());
        assertEquals(UserStatus.ACTIVE, user.getStatus());
        verify(audit).record("USER_REACTIVATED", "USER", user.getId(), null);
        verify(notifier).accountReactivated(user);
    }

    @Test void withdrawingAProductIsJournaledWithItsReason() {
        var id = UUID.randomUUID();
        service.withdrawProduct(id, " Allégation trompeuse ");
        verify(moderation).withdraw(id, " Allégation trompeuse ");
        verify(audit).record("PRODUCT_WITHDRAWN", "PRODUCT", id, "Allégation trompeuse");
    }
}
