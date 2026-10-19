package mg.inmybush.api.admin;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.admin.service.AdminReportService;
import mg.inmybush.api.admin.service.AuditService;
import mg.inmybush.api.admin.service.ModerationNotifier;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.ApiException;
import mg.inmybush.api.message.repository.ConversationRepository;
import mg.inmybush.api.message.repository.MessageRepository;
import mg.inmybush.api.report.entity.Report;
import mg.inmybush.api.report.entity.ReportNote;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.report.entity.TargetType;
import mg.inmybush.api.report.repository.ReportNoteRepository;
import mg.inmybush.api.report.repository.ReportRepository;
import mg.inmybush.api.review.repository.ReviewRepository;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class AdminReportServiceTest {
    ReportRepository reports = mock(ReportRepository.class);
    ReportNoteRepository notes = mock(ReportNoteRepository.class);
    AuditService audit = mock(AuditService.class);
    ModerationNotifier notifier = mock(ModerationNotifier.class);
    AdminReportService service = new AdminReportService(reports, notes, mock(ProductRepository.class),
        mock(ShopRepository.class), mock(UserRepository.class), mock(ReviewRepository.class),
        mock(MessageRepository.class), mock(ConversationRepository.class), audit, notifier);
    UUID adminId = UUID.randomUUID();
    Report report;

    @BeforeEach void setup() {
        report = new Report(UUID.randomUUID(), TargetType.PRODUCT, UUID.randomUUID(), "Allégation trompeuse", null);
        report.setId(UUID.randomUUID());
        when(reports.findById(report.getId())).thenReturn(Optional.of(report));
    }

    @Test void takingAReportInChargeNeedsNoReason() {
        service.changeStatus(adminId, report.getId(), ReportStatus.IN_REVIEW, null);
        assertEquals(ReportStatus.IN_REVIEW, report.getStatus());
        assertNull(report.getResolvedAt());
        verify(audit).record("REPORT_IN_REVIEW", "REPORT", report.getId(), null);
        verifyNoInteractions(notifier);
    }

    @Test void closingAReportRequiresTheReasonOfTheDecision() {
        for (String blank : new String[]{null, "", "   "}) {
            var error = assertThrows(ApiException.class,
                () -> service.changeStatus(adminId, report.getId(), ReportStatus.RESOLVED, blank));
            assertEquals("REASON_REQUIRED", error.getCode());
        }
        assertEquals(ReportStatus.OPEN, report.getStatus());
        verifyNoInteractions(audit, notifier);
    }

    @Test void closingAReportRecordsTheDecisionAndTellsTheReporter() {
        service.changeStatus(adminId, report.getId(), ReportStatus.DISMISSED, " Fiche conforme ");
        assertEquals(ReportStatus.DISMISSED, report.getStatus());
        assertEquals("Fiche conforme", report.getResolutionNote());
        assertEquals(adminId, report.getResolvedBy());
        verify(audit).record("REPORT_DISMISSED", "REPORT", report.getId(), "Fiche conforme");
        verify(notifier).reportHandled(report);
    }

    @Test void aClosedReportCannotChangeNorReceiveNotes() {
        service.changeStatus(adminId, report.getId(), ReportStatus.RESOLVED, "Produit retiré");
        assertThrows(ApiException.class, () -> service.changeStatus(adminId, report.getId(), ReportStatus.DISMISSED, "Autre"));
        assertThrows(ApiException.class, () -> service.changeStatus(adminId, report.getId(), ReportStatus.IN_REVIEW, null));
        assertThrows(ApiException.class, () -> service.addNote(adminId, report.getId(), "Trop tard"));
        verify(notes, never()).save(any());
    }

    @Test void aReportNeverGoesBackToOpen() {
        assertThrows(ApiException.class, () -> service.changeStatus(adminId, report.getId(), ReportStatus.OPEN, "Rouvrir"));
    }

    @Test void notesKeepTheirAuthor() {
        when(notes.save(any())).thenAnswer(i -> i.getArgument(0));
        when(audit.names(any())).thenReturn(Map.of(adminId, "Miora Rabe"));
        var note = service.addNote(adminId, report.getId(), "  Vendeur contacté par téléphone ");
        assertEquals("Vendeur contacté par téléphone", note.body());
        assertEquals("Miora Rabe", note.authorName());
        verify(notes).save(argThat((ReportNote n) -> n.getReportId().equals(report.getId()) && n.getAuthorId().equals(adminId)));
    }
}
