-- In my bush — initial schema.
-- Amounts are Ariary integers (BIGINT), ids are UUID, dates are TIMESTAMPTZ.
-- Enum-like columns are VARCHAR + CHECK so that JPA @Enumerated(STRING) maps 1-1.

CREATE EXTENSION IF NOT EXISTS unaccent;

-- ---------------------------------------------------------------- users & auth
CREATE TABLE users (
    id                UUID PRIMARY KEY,
    first_name        VARCHAR(80)  NOT NULL,
    last_name         VARCHAR(80)  NOT NULL,
    email             VARCHAR(160) UNIQUE,
    phone             VARCHAR(20)  NOT NULL UNIQUE,
    password_hash     VARCHAR(100) NOT NULL,
    avatar_url        VARCHAR(500),
    status            VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE'
                      CONSTRAINT ck_users_status CHECK (status IN ('ACTIVE', 'SUSPENDED', 'BANNED')),
    phone_verified_at TIMESTAMPTZ,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_users_status ON users (status);

CREATE TABLE user_roles (
    user_id UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role    VARCHAR(20) NOT NULL CONSTRAINT ck_user_roles_role CHECK (role IN ('BUYER', 'SELLER', 'ADMIN')),
    PRIMARY KEY (user_id, role)
);

CREATE TABLE refresh_tokens (
    id         UUID PRIMARY KEY,
    user_id    UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_refresh_tokens_user ON refresh_tokens (user_id);

CREATE TABLE otp_codes (
    id          UUID PRIMARY KEY,
    phone       VARCHAR(20) NOT NULL,
    code_hash   VARCHAR(64) NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    consumed_at TIMESTAMPTZ,
    attempts    INTEGER     NOT NULL DEFAULT 0 CHECK (attempts >= 0),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_otp_codes_phone ON otp_codes (phone, created_at DESC);

CREATE TABLE addresses (
    id         UUID PRIMARY KEY,
    user_id    UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    label      VARCHAR(60),
    recipient  VARCHAR(120) NOT NULL,
    phone      VARCHAR(20)  NOT NULL,
    line1      VARCHAR(255) NOT NULL,
    district   VARCHAR(120),
    city       VARCHAR(120) NOT NULL,
    landmark   VARCHAR(255),
    is_default BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_addresses_user ON addresses (user_id);

CREATE TABLE payout_methods (
    id           UUID PRIMARY KEY,
    user_id      UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    method       VARCHAR(20) NOT NULL
                 CONSTRAINT ck_payout_methods_method CHECK (method IN ('MVOLA', 'ORANGE_MONEY', 'AIRTEL_MONEY')),
    phone        VARCHAR(20) NOT NULL,
    phone_masked VARCHAR(30) NOT NULL,
    is_default   BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_payout_methods_user ON payout_methods (user_id);

-- ---------------------------------------------------------------- shops & catalog
CREATE TABLE shops (
    id           UUID PRIMARY KEY,
    owner_id     UUID          NOT NULL UNIQUE REFERENCES users (id),
    name         VARCHAR(120)  NOT NULL,
    slug         VARCHAR(140)  NOT NULL UNIQUE,
    description  TEXT,
    region       VARCHAR(120),
    city         VARCHAR(120),
    logo_url     VARCHAR(500),
    cover_url    VARCHAR(500),
    status       VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE'
                 CONSTRAINT ck_shops_status CHECK (status IN ('ACTIVE', 'PAUSED', 'SUSPENDED')),
    rating_avg   NUMERIC(3, 2) NOT NULL DEFAULT 0 CHECK (rating_avg BETWEEN 0 AND 5),
    rating_count INTEGER       NOT NULL DEFAULT 0 CHECK (rating_count >= 0),
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX ix_shops_status ON shops (status);

CREATE TABLE categories (
    id         UUID PRIMARY KEY,
    parent_id  UUID REFERENCES categories (id) ON DELETE SET NULL,
    name       VARCHAR(80)  NOT NULL,
    slug       VARCHAR(100) NOT NULL UNIQUE,
    icon       VARCHAR(40),
    position   INTEGER      NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_categories_parent ON categories (parent_id);

CREATE TABLE products (
    id                  UUID PRIMARY KEY,
    shop_id             UUID          NOT NULL REFERENCES shops (id),
    category_id         UUID          NOT NULL REFERENCES categories (id),
    name                VARCHAR(160)  NOT NULL,
    slug                VARCHAR(200)  NOT NULL UNIQUE,
    description         TEXT,
    price               BIGINT        NOT NULL CHECK (price > 0),
    compare_at_price    BIGINT        CHECK (compare_at_price IS NULL OR compare_at_price > 0),
    unit                VARCHAR(10)   NOT NULL
                        CONSTRAINT ck_products_unit CHECK (unit IN ('KG', 'G', 'L', 'PIECE', 'BUNCH', 'JAR', 'PACK')),
    unit_label          VARCHAR(40),
    stock               INTEGER       NOT NULL DEFAULT 0 CHECK (stock >= 0),
    low_stock_threshold INTEGER       NOT NULL DEFAULT 5 CHECK (low_stock_threshold >= 0),
    origin_region       VARCHAR(120),
    status              VARCHAR(20)   NOT NULL DEFAULT 'DRAFT'
                        CONSTRAINT ck_products_status CHECK (status IN ('DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'REJECTED', 'ARCHIVED')),
    rejection_reason    VARCHAR(500),
    rating_avg          NUMERIC(3, 2) NOT NULL DEFAULT 0 CHECK (rating_avg BETWEEN 0 AND 5),
    rating_count        INTEGER       NOT NULL DEFAULT 0 CHECK (rating_count >= 0),
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX ix_products_shop ON products (shop_id, status);
CREATE INDEX ix_products_category ON products (category_id);
CREATE INDEX ix_products_status_created ON products (status, created_at DESC);
CREATE INDEX ix_products_price ON products (price);

CREATE TABLE product_images (
    id         UUID PRIMARY KEY,
    product_id UUID         NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    url        VARCHAR(500) NOT NULL,
    position   INTEGER      NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_product_images_product ON product_images (product_id, position);

CREATE TABLE favorites (
    user_id    UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    product_id UUID        NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, product_id)
);
CREATE INDEX ix_favorites_product ON favorites (product_id);

-- ---------------------------------------------------------------- cart
CREATE TABLE carts (
    id         UUID PRIMARY KEY,
    user_id    UUID        NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE cart_items (
    id         UUID PRIMARY KEY,
    cart_id    UUID        NOT NULL REFERENCES carts (id) ON DELETE CASCADE,
    product_id UUID        NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    quantity   INTEGER     NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ux_cart_items_product UNIQUE (cart_id, product_id)
);

-- ---------------------------------------------------------------- checkout, orders, payments
CREATE TABLE checkouts (
    id               UUID PRIMARY KEY,
    buyer_id         UUID        NOT NULL REFERENCES users (id),
    address_id       UUID        REFERENCES addresses (id) ON DELETE SET NULL,
    delivery_mode    VARCHAR(10) NOT NULL CONSTRAINT ck_checkouts_mode CHECK (delivery_mode IN ('HOME', 'PICKUP')),
    recipient        VARCHAR(120),
    delivery_phone   VARCHAR(20),
    delivery_address VARCHAR(600),
    delivery_slot    VARCHAR(80),
    note             VARCHAR(500),
    total            BIGINT      NOT NULL CHECK (total >= 0),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_checkouts_buyer ON checkouts (buyer_id, created_at DESC);

CREATE TABLE payments (
    id           UUID PRIMARY KEY,
    checkout_id  UUID        NOT NULL UNIQUE REFERENCES checkouts (id),
    method       VARCHAR(20) NOT NULL
                 CONSTRAINT ck_payments_method CHECK (method IN ('MVOLA', 'ORANGE_MONEY', 'AIRTEL_MONEY', 'CASH_ON_DELIVERY')),
    phone        VARCHAR(20),
    amount       BIGINT      NOT NULL CHECK (amount >= 0),
    status       VARCHAR(20) NOT NULL
                 CONSTRAINT ck_payments_status CHECK (status IN ('PENDING', 'HELD', 'RELEASED', 'REFUNDED', 'FAILED')),
    provider_ref VARCHAR(100),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_payments_status ON payments (status, created_at DESC);

CREATE TABLE payouts (
    id           UUID PRIMARY KEY,
    shop_id      UUID        NOT NULL REFERENCES shops (id),
    amount       BIGINT      NOT NULL CHECK (amount >= 0),
    status       VARCHAR(20) NOT NULL CONSTRAINT ck_payouts_status CHECK (status IN ('SCHEDULED', 'PAID', 'FAILED')),
    method       VARCHAR(20) CONSTRAINT ck_payouts_method CHECK (method IN ('MVOLA', 'ORANGE_MONEY', 'AIRTEL_MONEY')),
    phone_masked VARCHAR(30),
    provider_ref VARCHAR(100),
    period_start DATE        NOT NULL,
    period_end   DATE        NOT NULL,
    paid_at      TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_payouts_period CHECK (period_end >= period_start)
);
CREATE INDEX ix_payouts_shop ON payouts (shop_id, created_at DESC);

CREATE SEQUENCE order_number_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE orders (
    id                    UUID PRIMARY KEY,
    number                VARCHAR(20) NOT NULL UNIQUE,
    checkout_id           UUID        NOT NULL REFERENCES checkouts (id),
    buyer_id              UUID        NOT NULL REFERENCES users (id),
    shop_id               UUID        NOT NULL REFERENCES shops (id),
    status                VARCHAR(30) NOT NULL
                          CONSTRAINT ck_orders_status CHECK (status IN ('PENDING_CONFIRMATION', 'ACCEPTED', 'PREPARED', 'IN_DELIVERY',
                                                                         'DELIVERED', 'REFUSED', 'CANCELLED')),
    payment_status        VARCHAR(20) NOT NULL
                          CONSTRAINT ck_orders_payment_status CHECK (payment_status IN ('PENDING', 'HELD', 'RELEASED', 'REFUNDED', 'FAILED')),
    delivery_mode         VARCHAR(10) NOT NULL CONSTRAINT ck_orders_mode CHECK (delivery_mode IN ('HOME', 'PICKUP')),
    subtotal              BIGINT      NOT NULL CHECK (subtotal >= 0),
    delivery_fee          BIGINT      NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
    discount              BIGINT      NOT NULL DEFAULT 0 CHECK (discount >= 0),
    commission            BIGINT      NOT NULL DEFAULT 0 CHECK (commission >= 0),
    total                 BIGINT      NOT NULL CHECK (total >= 0),
    seller_net            BIGINT      NOT NULL CHECK (seller_net >= 0),
    delivery_slot         VARCHAR(80),
    accept_before         TIMESTAMPTZ NOT NULL,
    delivered_at          TIMESTAMPTZ,
    delivery_confirmed_at TIMESTAMPTZ,
    cancel_reason         VARCHAR(500),
    payout_id             UUID REFERENCES payouts (id),
    version               BIGINT      NOT NULL DEFAULT 0,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_orders_buyer ON orders (buyer_id, created_at DESC);
CREATE INDEX ix_orders_shop ON orders (shop_id, status, created_at DESC);
CREATE INDEX ix_orders_status_accept ON orders (status, accept_before);
CREATE INDEX ix_orders_checkout ON orders (checkout_id);
CREATE INDEX ix_orders_payout ON orders (payout_id);

CREATE TABLE order_items (
    id           UUID PRIMARY KEY,
    order_id     UUID         NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    product_id   UUID         REFERENCES products (id) ON DELETE SET NULL,
    product_name VARCHAR(160) NOT NULL,
    product_slug VARCHAR(200),
    image_url    VARCHAR(500),
    unit_price   BIGINT       NOT NULL CHECK (unit_price >= 0),
    unit_label   VARCHAR(40),
    quantity     INTEGER      NOT NULL CHECK (quantity > 0),
    line_total   BIGINT       NOT NULL CHECK (line_total >= 0),
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_order_items_order ON order_items (order_id);
CREATE INDEX ix_order_items_product ON order_items (product_id);

CREATE TABLE order_events (
    id         UUID PRIMARY KEY,
    order_id   UUID        NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    status     VARCHAR(30) NOT NULL
               CONSTRAINT ck_order_events_status CHECK (status IN ('PENDING_CONFIRMATION', 'ACCEPTED', 'PREPARED', 'IN_DELIVERY',
                                                                  'DELIVERED', 'REFUSED', 'CANCELLED')),
    note       VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_order_events_order ON order_events (order_id, created_at);

-- ---------------------------------------------------------------- reviews
CREATE TABLE reviews (
    id           UUID PRIMARY KEY,
    product_id   UUID        NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    order_id     UUID        NOT NULL REFERENCES orders (id),
    author_id    UUID        NOT NULL REFERENCES users (id),
    rating       INTEGER     NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    seller_reply TEXT,
    replied_at   TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ux_reviews_order_product UNIQUE (order_id, product_id)
);
CREATE INDEX ix_reviews_product ON reviews (product_id, created_at DESC);
CREATE INDEX ix_reviews_author ON reviews (author_id, created_at DESC);

-- ---------------------------------------------------------------- messaging & notifications
CREATE TABLE conversations (
    id                   UUID PRIMARY KEY,
    buyer_id             UUID        NOT NULL REFERENCES users (id),
    shop_id              UUID        NOT NULL REFERENCES shops (id),
    product_id           UUID        REFERENCES products (id) ON DELETE SET NULL,
    order_id             UUID        REFERENCES orders (id) ON DELETE SET NULL,
    last_message_at      TIMESTAMPTZ,
    last_message_preview VARCHAR(200),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_conversations_buyer ON conversations (buyer_id, last_message_at DESC);
CREATE INDEX ix_conversations_shop ON conversations (shop_id, last_message_at DESC);

CREATE TABLE messages (
    id              UUID PRIMARY KEY,
    conversation_id UUID        NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
    sender_id       UUID        NOT NULL REFERENCES users (id),
    body            TEXT        NOT NULL,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_messages_conversation ON messages (conversation_id, created_at DESC);

CREATE TABLE notifications (
    id         UUID PRIMARY KEY,
    user_id    UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    context    VARCHAR(20)  NOT NULL CONSTRAINT ck_notifications_context CHECK (context IN ('PURCHASE', 'SALE', 'SYSTEM')),
    type       VARCHAR(40)  NOT NULL,
    title      VARCHAR(160) NOT NULL,
    body       VARCHAR(500),
    link       VARCHAR(300),
    read_at    TIMESTAMPTZ,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_notifications_user ON notifications (user_id, created_at DESC);
CREATE INDEX ix_notifications_unread ON notifications (user_id, context) WHERE read_at IS NULL;

-- ---------------------------------------------------------------- moderation
CREATE TABLE reports (
    id              UUID PRIMARY KEY,
    reporter_id     UUID        NOT NULL REFERENCES users (id),
    target_type     VARCHAR(20) NOT NULL
                    CONSTRAINT ck_reports_target CHECK (target_type IN ('PRODUCT', 'SHOP', 'USER', 'REVIEW', 'MESSAGE')),
    target_id       UUID        NOT NULL,
    reason          VARCHAR(80) NOT NULL,
    details         TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'OPEN'
                    CONSTRAINT ck_reports_status CHECK (status IN ('OPEN', 'IN_REVIEW', 'RESOLVED', 'DISMISSED')),
    resolution_note VARCHAR(500),
    resolved_by     UUID REFERENCES users (id),
    resolved_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_reports_status ON reports (status, created_at DESC);
CREATE INDEX ix_reports_target ON reports (target_type, target_id);

-- ---------------------------------------------------------------- settings
CREATE TABLE platform_settings (
    key        VARCHAR(60)  PRIMARY KEY,
    value      VARCHAR(255) NOT NULL,
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
