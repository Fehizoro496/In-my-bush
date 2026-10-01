package mg.inmybush.api.message;

import java.util.UUID;
import mg.inmybush.api.common.ForbiddenException;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.message.dto.ConversationResponse;
import mg.inmybush.api.message.dto.CreateConversationRequest;
import mg.inmybush.api.message.dto.MessageResponse;
import mg.inmybush.api.shop.Shop;
import mg.inmybush.api.shop.ShopRepository;
import mg.inmybush.api.user.User;
import mg.inmybush.api.user.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MessageService {

    private final ConversationRepository conversations;
    private final MessageRepository messages;
    private final ShopRepository shops;
    private final UserService userService;

    public MessageService(ConversationRepository conversations, MessageRepository messages,
                          ShopRepository shops, UserService userService) {
        this.conversations = conversations;
        this.messages = messages;
        this.shops = shops;
        this.userService = userService;
    }

    @Transactional(readOnly = true)
    public PageResponse<ConversationResponse> list(UUID userId, int page, int size) {
        return PageResponse.of(
            conversations.findByParticipant(userId, Pages.of(page, size)),
            c -> toConversationResponse(c));
    }

    @Transactional
    public ConversationResponse create(UUID userId, CreateConversationRequest req) {
        Shop shop = shops.findById(req.shopId())
            .orElseThrow(() -> NotFoundException.of("Boutique", req.shopId()));
        Conversation conv = new Conversation(userId, req.shopId());
        conv.setProductId(req.productId());
        conv.setOrderId(req.orderId());
        conversations.save(conv);

        Message msg = new Message(conv.getId(), userId, req.message());
        messages.save(msg);
        conv.updateLastMessage(req.message());

        return toConversationResponse(conv);
    }

    @Transactional(readOnly = true)
    public PageResponse<MessageResponse> getMessages(UUID userId, UUID conversationId, int page, int size) {
        Conversation conv = requireConversation(userId, conversationId);
        return PageResponse.of(
            messages.findByConversationId(conversationId, Pages.newestFirst(page, size)),
            m -> {
                User sender = userService.require(m.getSenderId());
                return MessageResponse.from(m, sender.getDisplayName());
            });
    }

    @Transactional
    public MessageResponse send(UUID userId, UUID conversationId, String body) {
        Conversation conv = requireConversation(userId, conversationId);
        Message msg = new Message(conversationId, userId, body);
        messages.save(msg);
        conv.updateLastMessage(body);
        User sender = userService.require(userId);
        return MessageResponse.from(msg, sender.getDisplayName());
    }

    @Transactional
    public void markRead(UUID userId, UUID conversationId) {
        requireConversation(userId, conversationId);
        messages.markAllRead(conversationId, userId);
    }

    private Conversation requireConversation(UUID userId, UUID conversationId) {
        Conversation conv = conversations.findById(conversationId)
            .orElseThrow(() -> NotFoundException.of("Conversation", conversationId));
        boolean isBuyer = conv.getBuyerId().equals(userId);
        boolean isSeller = shops.findById(conv.getShopId())
            .map(s -> s.isOwnedBy(userId)).orElse(false);
        if (!isBuyer && !isSeller) {
            throw new ForbiddenException("Vous n'avez pas accès à cette conversation.");
        }
        return conv;
    }

    private ConversationResponse toConversationResponse(Conversation c) {
        String shopName = shops.findById(c.getShopId()).map(Shop::getName).orElse(null);
        String buyerName = userService.require(c.getBuyerId()).getDisplayName();
        return new ConversationResponse(c.getId(), c.getBuyerId(), c.getShopId(), shopName, buyerName,
            c.getProductId(), c.getOrderId(), c.getLastMessagePreview(), c.getLastMessageAt(), c.getCreatedAt());
    }
}
