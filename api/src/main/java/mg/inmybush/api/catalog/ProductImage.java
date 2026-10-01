package mg.inmybush.api.catalog;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "product_images")
public class ProductImage extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "url", nullable = false, length = 500)
    private String url;

    @Column(name = "position", nullable = false)
    private int position;

    protected ProductImage() {
    }

    public ProductImage(Product product, String url, int position) {
        this.product = product;
        this.url = url;
        this.position = position;
    }

    public String getUrl() { return url; }

    public int getPosition() { return position; }
}
