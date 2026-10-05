package mg.inmybush.api.catalog.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import mg.inmybush.api.common.BaseEntity;

@Entity
@Table(name = "categories")
public class Category extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private Category parent;

    @Column(name = "name", nullable = false, length = 80)
    private String name;

    @Column(name = "slug", nullable = false, unique = true, length = 100)
    private String slug;

    @Column(name = "icon", length = 40)
    private String icon;

    @Column(name = "position", nullable = false)
    private int position;

    protected Category() {
    }

    public Category(Category parent, String name, String slug, String icon, int position) {
        this.parent = parent;
        this.name = name;
        this.slug = slug;
        this.icon = icon;
        this.position = position;
    }

    public Category getParent() { return parent; }

    public String getName() { return name; }

    public String getSlug() { return slug; }

    public String getIcon() { return icon; }

    public int getPosition() { return position; }
}
