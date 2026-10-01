package mg.inmybush.api.order;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.UUID;
import mg.inmybush.api.auth.CurrentUser;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.order.dto.OrderResponse;
import mg.inmybush.api.order.dto.OrderSummaryResponse;
import mg.inmybush.api.order.dto.RefuseRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/seller/orders")
@Tag(name = "Vendeur")
public class SellerOrderController {

    private final OrderService orderService;

    public SellerOrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    @Operation(summary = "Commandes reçues par ma boutique")
    public PageResponse<OrderSummaryResponse> list(@RequestParam(required = false) OrderStatus status,
                                                    @RequestParam(defaultValue = "0") int page,
                                                    @RequestParam(defaultValue = "20") int size) {
        return orderService.sellerOrders(CurrentUser.id(), status, page, size);
    }

    @GetMapping("/{id}")
    public OrderResponse get(@PathVariable UUID id) {
        return orderService.sellerOrder(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/accept")
    @Operation(summary = "Accepter une commande")
    public OrderResponse accept(@PathVariable UUID id) {
        return orderService.accept(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/refuse")
    @Operation(summary = "Refuser une commande")
    public OrderResponse refuse(@PathVariable UUID id, @Valid @RequestBody RefuseRequest request) {
        return orderService.refuse(CurrentUser.id(), id, request.reason());
    }

    @PostMapping("/{id}/prepare")
    @Operation(summary = "Marquer comme préparée")
    public OrderResponse prepare(@PathVariable UUID id) {
        return orderService.prepare(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/ship")
    @Operation(summary = "Marquer comme en livraison")
    public OrderResponse ship(@PathVariable UUID id) {
        return orderService.ship(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/deliver")
    @Operation(summary = "Marquer comme livrée")
    public OrderResponse deliver(@PathVariable UUID id) {
        return orderService.deliver(CurrentUser.id(), id);
    }
}
