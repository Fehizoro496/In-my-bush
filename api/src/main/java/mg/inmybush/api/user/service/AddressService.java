package mg.inmybush.api.user.service;

import java.util.List;
import java.util.UUID;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PhoneNumbers;
import mg.inmybush.api.user.dto.AddressRequest;
import mg.inmybush.api.user.dto.AddressResponse;
import mg.inmybush.api.user.dto.AddressUpdateRequest;
import mg.inmybush.api.user.entity.Address;
import mg.inmybush.api.user.repository.AddressRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Delivery addresses; exactly one is the default as soon as the user has one. */
@Service
public class AddressService {

    private final AddressRepository addresses;

    public AddressService(AddressRepository addresses) {
        this.addresses = addresses;
    }

    @Transactional(readOnly = true)
    public List<AddressResponse> list(UUID userId) {
        return addresses.findByUserIdOrderByIsDefaultDescCreatedAtAsc(userId).stream().map(AddressResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public Address require(UUID userId, UUID addressId) {
        return addresses.findByIdAndUserId(addressId, userId).orElseThrow(() -> NotFoundException.of("Adresse", addressId));
    }

    @Transactional
    public AddressResponse create(UUID userId, AddressRequest req) {
        Address a = new Address(userId);
        a.setLabel(req.label());
        a.setRecipient(req.recipient().trim());
        a.setPhone(PhoneNumbers.normalize(req.phone()));
        a.setLine1(req.line1().trim());
        a.setDistrict(req.district());
        a.setCity(req.city().trim());
        a.setLandmark(req.landmark());
        boolean first = addresses.countByUserId(userId) == 0;
        a = addresses.save(a);
        if (first || Boolean.TRUE.equals(req.isDefault())) {
            makeDefault(userId, a);
        }
        return AddressResponse.from(a);
    }

    @Transactional
    public AddressResponse update(UUID userId, UUID addressId, AddressUpdateRequest req) {
        Address a = require(userId, addressId);
        if (req.label() != null) a.setLabel(req.label());
        if (req.recipient() != null) a.setRecipient(req.recipient().trim());
        if (req.phone() != null) a.setPhone(PhoneNumbers.normalize(req.phone()));
        if (req.line1() != null) a.setLine1(req.line1().trim());
        if (req.district() != null) a.setDistrict(req.district());
        if (req.city() != null) a.setCity(req.city().trim());
        if (req.landmark() != null) a.setLandmark(req.landmark());
        if (Boolean.TRUE.equals(req.isDefault())) {
            makeDefault(userId, a);
        }
        return AddressResponse.from(a);
    }

    @Transactional
    public void delete(UUID userId, UUID addressId) {
        Address a = require(userId, addressId);
        boolean wasDefault = a.isDefault();
        addresses.delete(a);
        addresses.flush();
        if (wasDefault) {
            addresses.findByUserIdOrderByIsDefaultDescCreatedAtAsc(userId).stream().findFirst()
                .ifPresent(next -> next.setDefault(true));
        }
    }

    private void makeDefault(UUID userId, Address target) {
        for (Address other : addresses.findByUserIdOrderByIsDefaultDescCreatedAtAsc(userId)) {
            other.setDefault(other.getId().equals(target.getId()));
        }
        target.setDefault(true);
    }
}
