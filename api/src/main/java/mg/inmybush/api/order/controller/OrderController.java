package mg.inmybush.api.order.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.order.dto.CancelRequest;
import mg.inmybush.api.order.dto.OrderResponse;
import mg.inmybush.api.order.dto.OrderSummaryResponse;
import mg.inmybush.api.order.service.OrderService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me/orders")
@Tag(name = "Me")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    @Operation(summary = "Mes commandes (acheteur)")
    public PageResponse<OrderSummaryResponse> list(@RequestParam(defaultValue = "0") int page,
                                                    @RequestParam(defaultValue = "20") int size) {
        return orderService.buyerOrders(CurrentUser.id(), page, size);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'une commande")
    public OrderResponse get(@PathVariable UUID id) {
        return orderService.buyerOrder(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "Annuler une commande")
    public OrderResponse cancel(@PathVariable UUID id, @Valid @RequestBody(required = false) CancelRequest request) {
        return orderService.cancel(CurrentUser.id(), id, request != null ? request.reason() : null);
    }

    @PostMapping("/{id}/confirm-delivery")
    @Operation(summary = "Confirmer la réception")
    public OrderResponse confirmDelivery(@PathVariable UUID id) {
        return orderService.confirmDelivery(CurrentUser.id(), id);
    }
}
