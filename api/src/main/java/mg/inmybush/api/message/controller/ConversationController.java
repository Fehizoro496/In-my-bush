package mg.inmybush.api.message.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.message.dto.ConversationResponse;
import mg.inmybush.api.message.dto.CreateConversationRequest;
import mg.inmybush.api.message.dto.MessageResponse;
import mg.inmybush.api.message.dto.SendMessageRequest;
import mg.inmybush.api.message.service.MessageService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/conversations")
@Tag(name = "Messagerie")
public class ConversationController {

    private final MessageService messageService;

    public ConversationController(MessageService messageService) {
        this.messageService = messageService;
    }

    @GetMapping
    @Operation(summary = "Mes conversations")
    public PageResponse<ConversationResponse> list(@RequestParam(defaultValue = "0") int page,
                                                    @RequestParam(defaultValue = "20") int size) {
        return messageService.list(CurrentUser.id(), page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Démarrer une conversation avec une boutique")
    public ConversationResponse create(@Valid @RequestBody CreateConversationRequest request) {
        return messageService.create(CurrentUser.id(), request);
    }

    @GetMapping("/{id}/messages")
    @Operation(summary = "Messages d'une conversation")
    public PageResponse<MessageResponse> messages(@PathVariable UUID id,
                                                   @RequestParam(defaultValue = "0") int page,
                                                   @RequestParam(defaultValue = "20") int size) {
        return messageService.getMessages(CurrentUser.id(), id, page, size);
    }

    @PostMapping("/{id}/messages")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Envoyer un message")
    public MessageResponse send(@PathVariable UUID id, @Valid @RequestBody SendMessageRequest request) {
        return messageService.send(CurrentUser.id(), id, request.body());
    }

    @PostMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Marquer les messages comme lus")
    public void markRead(@PathVariable UUID id) {
        messageService.markRead(CurrentUser.id(), id);
    }
}
