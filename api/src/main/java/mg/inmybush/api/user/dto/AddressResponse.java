package mg.inmybush.api.user.dto;

import java.util.UUID;
import mg.inmybush.api.user.entity.Address;

public record AddressResponse(UUID id, String label, String recipient, String phone, String line1, String district,
                              String city, String landmark, boolean isDefault) {

    public static AddressResponse from(Address a) {
        return new AddressResponse(a.getId(), a.getLabel(), a.getRecipient(), a.getPhone(), a.getLine1(), a.getDistrict(),
            a.getCity(), a.getLandmark(), a.isDefault());
    }
}
