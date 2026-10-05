package mg.inmybush.api.user.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.util.UUID;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "addresses")
public class Address extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "label", length = 60)
    private String label;

    @Column(name = "recipient", nullable = false, length = 120)
    private String recipient;

    @Column(name = "phone", nullable = false, length = 20)
    private String phone;

    @Column(name = "line1", nullable = false)
    private String line1;

    @Column(name = "district", length = 120)
    private String district;

    @Column(name = "city", nullable = false, length = 120)
    private String city;

    @Column(name = "landmark")
    private String landmark;

    @Column(name = "is_default", nullable = false)
    private boolean isDefault;

    protected Address() {
    }

    public Address(UUID userId) {
        this.userId = userId;
    }

    /** One-line text snapshot stored on checkouts. */
    public String toSingleLine() {
        StringBuilder sb = new StringBuilder(line1);
        if (district != null && !district.isBlank()) sb.append(", ").append(district);
        sb.append(", ").append(city);
        if (landmark != null && !landmark.isBlank()) sb.append(" (").append(landmark).append(")");
        return sb.toString();
    }

    public UUID getUserId() { return userId; }

    public String getLabel() { return label; }

    public void setLabel(String label) { this.label = label; }

    public String getRecipient() { return recipient; }

    public void setRecipient(String recipient) { this.recipient = recipient; }

    public String getPhone() { return phone; }

    public void setPhone(String phone) { this.phone = phone; }

    public String getLine1() { return line1; }

    public void setLine1(String line1) { this.line1 = line1; }

    public String getDistrict() { return district; }

    public void setDistrict(String district) { this.district = district; }

    public String getCity() { return city; }

    public void setCity(String city) { this.city = city; }

    public String getLandmark() { return landmark; }

    public void setLandmark(String landmark) { this.landmark = landmark; }

    public boolean isDefault() { return isDefault; }

    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }
}
