package mg.inmybush.api.admin;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.util.UUID;
import mg.inmybush.api.admin.service.ModerationNotifier;
import mg.inmybush.api.auth.service.SmsSender;
import mg.inmybush.api.notification.entity.NotificationContext;
import mg.inmybush.api.notification.entity.NotificationType;
import mg.inmybush.api.notification.service.NotificationService;
import mg.inmybush.api.report.entity.Report;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.report.entity.TargetType;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.user.entity.User;
import org.junit.jupiter.api.Test;

class ModerationNotifierTest {
    NotificationService notifications = mock(NotificationService.class);
    SmsSender sms = mock(SmsSender.class);
    ModerationNotifier notifier = new ModerationNotifier(notifications, sms);

    User user() {
        User u = new User("Fara", "Rasoa", null, "+261329876543", "hash");
        u.setId(UUID.randomUUID());
        return u;
    }

    @Test void aSuspendedAccountIsToldBySmsAsItCanNoLongerSignIn() {
        User u = user();
        notifier.accountSuspended(u, "Fraude au paiement", false);
        verify(notifications).notify(eq(u.getId()), eq(NotificationContext.SYSTEM), eq(NotificationType.ACCOUNT_SUSPENDED),
            eq("Compte suspendu"), contains("Fraude au paiement"), isNull());
        verify(sms).send(eq("+261329876543"), contains("Fraude au paiement"));
    }

    @Test void aFailedSmsDoesNotFailTheDecision() {
        doThrow(new IllegalStateException("passerelle indisponible")).when(sms).send(any(), any());
        notifier.accountSuspended(user(), "Fraude", true);
        verify(notifications).notify(any(), any(), eq(NotificationType.ACCOUNT_BANNED), eq("Compte banni"), any(), any());
    }

    @Test void theShopOwnerIsToldOfTheSuspensionAndItsReason() {
        User owner = user();
        Shop shop = new Shop(owner, "Rucher d'Ambositra", "rucher");
        notifier.shopSuspended(shop, "Produits non conformes");
        verify(notifications).notify(eq(owner.getId()), eq(NotificationContext.SALE), eq(NotificationType.SHOP_SUSPENDED),
            any(), contains("Produits non conformes"), eq("/vendre/boutique"));
        verifyNoInteractions(sms);
    }

    @Test void theReporterLearnsTheOutcomeButNotTheInternalReason() {
        UUID reporter = UUID.randomUUID();
        Report report = new Report(reporter, TargetType.REVIEW, UUID.randomUUID(), "Avis hors sujet", null);
        report.resolve(UUID.randomUUID(), ReportStatus.RESOLVED, "Avis supprimé, auteur averti");
        notifier.reportHandled(report);
        verify(notifications).notify(eq(reporter), eq(NotificationContext.SYSTEM), eq(NotificationType.REPORT_HANDLED),
            eq("Signalement traité"), argThat(body -> body.contains("Avis hors sujet") && !body.contains("auteur averti")), isNull());
    }
}
