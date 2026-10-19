package mg.inmybush.api.admin.service;

import mg.inmybush.api.auth.service.SmsSender;
import mg.inmybush.api.notification.entity.NotificationContext;
import mg.inmybush.api.notification.entity.NotificationType;
import mg.inmybush.api.notification.service.NotificationService;
import mg.inmybush.api.report.entity.Report;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.user.entity.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

/**
 * Tells the people concerned about a moderation decision. A suspended or banned account can no longer
 * sign in to read its notifications, so account decisions are also sent by SMS, once the decision is saved.
 */
@Component
public class ModerationNotifier {

    private static final Logger log = LoggerFactory.getLogger(ModerationNotifier.class);

    private final NotificationService notifications;
    private final SmsSender sms;

    public ModerationNotifier(NotificationService notifications, SmsSender sms) {
        this.notifications = notifications;
        this.sms = sms;
    }

    public void accountSuspended(User user, String reason, boolean banned) {
        String title = banned ? "Compte banni" : "Compte suspendu";
        String body = (banned ? "Votre compte In my bush a été banni : " : "Votre compte In my bush est suspendu : ") + reason;
        notifications.notify(user.getId(), NotificationContext.SYSTEM,
            banned ? NotificationType.ACCOUNT_BANNED : NotificationType.ACCOUNT_SUSPENDED, title, body, null);
        smsAfterCommit(user.getPhone(), body);
    }

    public void accountReactivated(User user) {
        String body = "Votre compte In my bush est de nouveau actif.";
        notifications.notify(user.getId(), NotificationContext.SYSTEM, NotificationType.ACCOUNT_REACTIVATED,
            "Compte réactivé", body, "/compte");
        smsAfterCommit(user.getPhone(), body);
    }

    public void shopSuspended(Shop shop, String reason) {
        notifications.notify(shop.getOwner().getId(), NotificationContext.SALE, NotificationType.SHOP_SUSPENDED,
            "Boutique suspendue", "« " + shop.getName() + " » est masquée et ne reçoit plus de commandes : " + reason,
            "/vendre/boutique");
    }

    public void shopReactivated(Shop shop) {
        notifications.notify(shop.getOwner().getId(), NotificationContext.SALE, NotificationType.SHOP_REACTIVATED,
            "Boutique réactivée", "« " + shop.getName() + " » est de nouveau visible et peut recevoir des commandes.",
            "/vendre/boutique");
    }

    /** The reporter learns the outcome, never the internal notes nor the reason given to the reported person. */
    public void reportHandled(Report report) {
        String outcome = report.getStatus() == ReportStatus.RESOLVED
            ? "a été examiné et des mesures ont été prises."
            : "a été examiné : aucune infraction n'a été retenue.";
        notifications.notify(report.getReporterId(), NotificationContext.SYSTEM, NotificationType.REPORT_HANDLED,
            "Signalement traité", "Votre signalement « " + report.getReason() + " » " + outcome, null);
    }

    private void smsAfterCommit(String phone, String message) {
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            sendQuietly(phone, message);
            return;
        }
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                sendQuietly(phone, message);
            }
        });
    }

    /** The decision is already saved: a failed SMS is logged, it does not undo nor fail the decision. */
    private void sendQuietly(String phone, String message) {
        try {
            sms.send(phone, message);
        } catch (RuntimeException e) {
            log.warn("Moderation SMS not sent: {}", e.getMessage());
        }
    }
}
