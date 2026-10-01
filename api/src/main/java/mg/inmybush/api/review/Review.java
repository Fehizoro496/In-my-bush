package mg.inmybush.api.review;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import mg.inmybush.api.catalog.Product;
import mg.inmybush.api.common.BaseEntity;
import mg.inmybush.api.order.Order;
import mg.inmybush.api.user.User;

@Entity
@Table(name = "reviews")
public class Review extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;

    @Column(name = "rating", nullable = false)
    private int rating;

    @Column(name = "comment", columnDefinition = "text")
    private String comment;

    @Column(name = "seller_reply", columnDefinition = "text")
    private String sellerReply;

    @Column(name = "replied_at")
    private Instant repliedAt;

    protected Review() {
    }

    public Review(Product product, Order order, User author, int rating, String comment) {
        this.product = product;
        this.order = order;
        this.author = author;
        this.rating = rating;
        this.comment = comment;
    }

    public void reply(String reply) {
        this.sellerReply = reply;
        this.repliedAt = Instant.now();
    }

    public Product getProduct() { return product; }

    public Order getOrder() { return order; }

    public User getAuthor() { return author; }

    public int getRating() { return rating; }

    public String getComment() { return comment; }

    public String getSellerReply() { return sellerReply; }

    public Instant getRepliedAt() { return repliedAt; }
}
