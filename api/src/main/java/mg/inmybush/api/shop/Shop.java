package mg.inmybush.api.shop;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import mg.inmybush.api.common.BaseEntity;
import mg.inmybush.api.user.User;

@Entity
@Table(name = "shops")
public class Shop extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_id", nullable = false, unique = true)
    private User owner;

    @Column(name = "name", nullable = false, length = 120)
    private String name;

    @Column(name = "slug", nullable = false, unique = true, length = 140)
    private String slug;

    @Column(name = "description", columnDefinition = "text")
    private String description;

    @Column(name = "region", length = 120)
    private String region;

    @Column(name = "city", length = 120)
    private String city;

    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    @Column(name = "cover_url", length = 500)
    private String coverUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ShopStatus status = ShopStatus.ACTIVE;

    @Column(name = "rating_avg", nullable = false, precision = 3, scale = 2)
    private BigDecimal ratingAvg = BigDecimal.ZERO;

    @Column(name = "rating_count", nullable = false)
    private int ratingCount;

    protected Shop() {
    }

    public Shop(User owner, String name, String slug) {
        this.owner = owner;
        this.name = name;
        this.slug = slug;
    }

    public boolean isOwnedBy(java.util.UUID userId) {
        return owner.getId().equals(userId);
    }

    public boolean isActive() { return status == ShopStatus.ACTIVE; }

    public User getOwner() { return owner; }

    public String getName() { return name; }

    public void setName(String name) { this.name = name; }

    public String getSlug() { return slug; }

    public String getDescription() { return description; }

    public void setDescription(String description) { this.description = description; }

    public String getRegion() { return region; }

    public void setRegion(String region) { this.region = region; }

    public String getCity() { return city; }

    public void setCity(String city) { this.city = city; }

    public String getLogoUrl() { return logoUrl; }

    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }

    public String getCoverUrl() { return coverUrl; }

    public void setCoverUrl(String coverUrl) { this.coverUrl = coverUrl; }

    public ShopStatus getStatus() { return status; }

    public void setStatus(ShopStatus status) { this.status = status; }

    public BigDecimal getRatingAvg() { return ratingAvg; }

    public int getRatingCount() { return ratingCount; }

    public void updateRating(BigDecimal avg, int count) {
        this.ratingAvg = avg;
        this.ratingCount = count;
    }
}
