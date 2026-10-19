package mg.inmybush.api.admin.service;

import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import mg.inmybush.api.admin.dto.AdminReportDetailResponse;
import mg.inmybush.api.admin.dto.ReportNoteResponse;
import mg.inmybush.api.admin.dto.ReportTargetResponse;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.common.BadRequestException;
import mg.inmybush.api.common.ConflictException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.message.repository.ConversationRepository;
import mg.inmybush.api.message.repository.MessageRepository;
import mg.inmybush.api.report.dto.ReportResponse;
import mg.inmybush.api.report.entity.Report;
import mg.inmybush.api.report.entity.ReportNote;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.report.entity.TargetType;
import mg.inmybush.api.report.repository.ReportNoteRepository;
import mg.inmybush.api.report.repository.ReportRepository;
import mg.inmybush.api.review.repository.ReviewRepository;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.user.repository.UserRepository;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Handling of reports: OPEN → IN_REVIEW → RESOLVED | DISMISSED. Closing a report requires the reason of the
 * decision and tells the reporter; internal notes stay within the moderation team.
 */
@Service
public class AdminReportService {

    private static final int EXCERPT = 500;

    private final ReportRepository reports;
    private final ReportNoteRepository notes;
    private final ProductRepository products;
    private final ShopRepository shops;
    private final UserRepository users;
    private final ReviewRepository reviews;
    private final MessageRepository messages;
    private final ConversationRepository conversations;
    private final AuditService audit;
    private final ModerationNotifier notifier;

    public AdminReportService(ReportRepository reports, ReportNoteRepository notes, ProductRepository products,
                              ShopRepository shops, UserRepository users, ReviewRepository reviews,
                              MessageRepository messages, ConversationRepository conversations,
                              AuditService audit, ModerationNotifier notifier) {
        this.reports = reports;
        this.notes = notes;
        this.products = products;
        this.shops = shops;
        this.users = users;
        this.reviews = reviews;
        this.messages = messages;
        this.conversations = conversations;
        this.audit = audit;
        this.notifier = notifier;
    }

    @Transactional(readOnly = true)
    public PageResponse<ReportResponse> list(ReportStatus status, TargetType type, int page, int size) {
        Specification<Report> spec = (root, query, cb) -> {
            var predicates = new ArrayList<Predicate>();
            if (status != null) predicates.add(cb.equal(root.get("status"), status));
            if (type != null) predicates.add(cb.equal(root.get("targetType"), type));
            return cb.and(predicates.toArray(Predicate[]::new));
        };
        return PageResponse.of(reports.findAll(spec, Pages.newestFirst(page, size)), ReportResponse::from);
    }

    @Transactional(readOnly = true)
    public AdminReportDetailResponse get(UUID id) {
        Report report = require(id);
        List<ReportNote> found = notes.findByReportIdOrderByCreatedAtAsc(id);
        Set<UUID> people = new HashSet<>();
        people.add(report.getReporterId());
        if (report.getResolvedBy() != null) people.add(report.getResolvedBy());
        found.forEach(n -> people.add(n.getAuthorId()));
        Map<UUID, String> names = audit.names(people);
        return new AdminReportDetailResponse(ReportResponse.from(report), names.get(report.getReporterId()),
            report.getResolvedBy() == null ? null : names.get(report.getResolvedBy()), target(report),
            reports.countByTargetTypeAndTargetId(report.getTargetType(), report.getTargetId()),
            found.stream().map(n -> ReportNoteResponse.from(n, names.get(n.getAuthorId()))).toList(),
            audit.history("REPORT", id));
    }

    /** Takes the report in charge (IN_REVIEW) or closes it (RESOLVED, DISMISSED) with the reason of the decision. */
    @Transactional
    public ReportResponse changeStatus(UUID adminId, UUID id, ReportStatus status, String note) {
        Report report = require(id);
        String reason = note == null || note.isBlank() ? null : note.trim();
        switch (status) {
            case IN_REVIEW -> report.startReview();
            case RESOLVED, DISMISSED -> {
                if (reason == null) {
                    throw new BadRequestException("REASON_REQUIRED", "Indiquez le motif de la décision.");
                }
                report.resolve(adminId, status, reason);
                notifier.reportHandled(report);
            }
            default -> throw new BadRequestException("Un signalement ne peut pas revenir au statut ouvert.");
        }
        audit.record("REPORT_" + status.name(), "REPORT", id, reason);
        return ReportResponse.from(report);
    }

    @Transactional
    public ReportNoteResponse addNote(UUID adminId, UUID id, String body) {
        Report report = require(id);
        if (report.isClosed()) {
            throw new ConflictException("INVALID_REPORT_STATUS", "Ce signalement est clos : il ne reçoit plus de notes.");
        }
        ReportNote note = notes.save(new ReportNote(id, adminId, body.trim()));
        return ReportNoteResponse.from(note, audit.names(List.of(adminId)).get(adminId));
    }

    private Report require(UUID id) {
        return reports.findById(id).orElseThrow(() -> NotFoundException.of("Signalement", id));
    }

    /** The reported content, read in its own table; a content deleted since the report is reported missing. */
    private ReportTargetResponse target(Report report) {
        UUID id = report.getTargetId();
        return switch (report.getTargetType()) {
            case PRODUCT -> products.findWithShopById(id).map(p -> new ReportTargetResponse(true, p.getName(),
                excerpt(p.getDescription()), p.getStatus().name(), p.getSlug(), p.getShop().getOwner().getId(),
                p.getShop().getOwner().getFullName(), p.getShop().getId(), p.getShop().getName()))
                .orElseGet(ReportTargetResponse::missing);
            case SHOP -> shops.findWithOwnerById(id).map(s -> new ReportTargetResponse(true, s.getName(),
                excerpt(s.getDescription()), s.getStatus().name(), null, s.getOwner().getId(), s.getOwner().getFullName(),
                s.getId(), s.getName())).orElseGet(ReportTargetResponse::missing);
            case USER -> users.findById(id).map(u -> {
                Shop shop = shops.findByOwnerId(u.getId()).orElse(null);
                return new ReportTargetResponse(true, u.getFullName(), null, u.getStatus().name(), null, u.getId(),
                    u.getFullName(), shop == null ? null : shop.getId(), shop == null ? null : shop.getName());
            }).orElseGet(ReportTargetResponse::missing);
            case REVIEW -> reviews.findById(id).map(r -> new ReportTargetResponse(true,
                "Avis " + r.getRating() + "/5 sur « " + r.getProduct().getName() + " »", excerpt(r.getComment()), null,
                r.getProduct().getSlug(), r.getAuthor().getId(), r.getAuthor().getFullName(),
                r.getProduct().getShop().getId(), r.getProduct().getShop().getName()))
                .orElseGet(ReportTargetResponse::missing);
            case MESSAGE -> messages.findById(id).map(m -> {
                String sender = users.findById(m.getSenderId()).map(u -> u.getFullName()).orElse(null);
                Shop shop = conversations.findById(m.getConversationId())
                    .flatMap(c -> shops.findById(c.getShopId())).orElse(null);
                return new ReportTargetResponse(true, "Message" + (sender == null ? "" : " de " + sender),
                    excerpt(m.getBody()), null, null, m.getSenderId(), sender,
                    shop == null ? null : shop.getId(), shop == null ? null : shop.getName());
            }).orElseGet(ReportTargetResponse::missing);
        };
    }

    private static String excerpt(String text) {
        if (text == null || text.length() <= EXCERPT) return text;
        return text.substring(0, EXCERPT) + "…";
    }
}
