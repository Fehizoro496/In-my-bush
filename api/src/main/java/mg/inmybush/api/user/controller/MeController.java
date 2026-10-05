package mg.inmybush.api.user.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.user.dto.AddressRequest;
import mg.inmybush.api.user.dto.AddressResponse;
import mg.inmybush.api.user.dto.AddressUpdateRequest;
import mg.inmybush.api.user.dto.PayoutMethodRequest;
import mg.inmybush.api.user.dto.PayoutMethodResponse;
import mg.inmybush.api.user.dto.UpdateMeRequest;
import mg.inmybush.api.user.dto.UserResponse;
import mg.inmybush.api.user.service.AddressService;
import mg.inmybush.api.user.service.PayoutMethodService;
import mg.inmybush.api.user.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me")
@Tag(name = "Me", description = "Profil, adresses et moyens de versement de l'utilisateur connecté")
public class MeController {

    private final UserService userService;
    private final AddressService addressService;
    private final PayoutMethodService payoutMethodService;

    public MeController(UserService userService, AddressService addressService, PayoutMethodService payoutMethodService) {
        this.userService = userService;
        this.addressService = addressService;
        this.payoutMethodService = payoutMethodService;
    }

    @GetMapping
    @Operation(summary = "Profil de l'utilisateur connecté")
    public UserResponse me() {
        return userService.me(CurrentUser.id());
    }

    @PatchMapping
    @Operation(summary = "Modifier son profil (et son mot de passe)")
    public UserResponse update(@Valid @RequestBody UpdateMeRequest request) {
        return userService.updateMe(CurrentUser.id(), request);
    }

    @GetMapping("/addresses")
    public List<AddressResponse> addresses() {
        return addressService.list(CurrentUser.id());
    }

    @PostMapping("/addresses")
    @ResponseStatus(HttpStatus.CREATED)
    public AddressResponse createAddress(@Valid @RequestBody AddressRequest request) {
        return addressService.create(CurrentUser.id(), request);
    }

    @PatchMapping("/addresses/{id}")
    public AddressResponse updateAddress(@PathVariable UUID id, @Valid @RequestBody AddressUpdateRequest request) {
        return addressService.update(CurrentUser.id(), id, request);
    }

    @DeleteMapping("/addresses/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAddress(@PathVariable UUID id) {
        addressService.delete(CurrentUser.id(), id);
    }

    @GetMapping("/payout-methods")
    public List<PayoutMethodResponse> payoutMethods() {
        return payoutMethodService.list(CurrentUser.id());
    }

    @PostMapping("/payout-methods")
    @ResponseStatus(HttpStatus.CREATED)
    public PayoutMethodResponse createPayoutMethod(@Valid @RequestBody PayoutMethodRequest request) {
        return payoutMethodService.create(CurrentUser.id(), request);
    }

    @DeleteMapping("/payout-methods/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePayoutMethod(@PathVariable UUID id) {
        payoutMethodService.delete(CurrentUser.id(), id);
    }
}
