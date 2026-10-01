-- Reference data needed in every environment.

INSERT INTO categories (id, parent_id, name, slug, icon, position) VALUES
    ('0a000000-0000-4000-8000-000000000001', NULL, 'Fruits & légumes',  'fruits-legumes',    'leaf',    1),
    ('0a000000-0000-4000-8000-000000000002', NULL, 'Produits laitiers', 'produits-laitiers', 'package', 2),
    ('0a000000-0000-4000-8000-000000000003', NULL, 'Épicerie',          'epicerie',          'basket',  3),
    ('0a000000-0000-4000-8000-000000000004', NULL, 'Boissons',          'boissons',          'package', 4),
    ('0a000000-0000-4000-8000-000000000005', NULL, 'Miel & confitures', 'miel-confitures',   'sprout',  5),
    ('0a000000-0000-4000-8000-000000000006', NULL, 'Céréales',          'cereales',          'basket',  6),
    ('0a000000-0000-4000-8000-000000000007', NULL, 'Artisanat',         'artisanat',         'store',   7),
    ('0a000000-0000-4000-8000-000000000008', NULL, 'Cosmétiques bio',   'cosmetiques-bio',   'sprout',  8),
    ('0a000000-0000-4000-8000-000000000009', NULL, 'Produits locaux',   'produits-locaux',   'pin',     9);

-- commission_rate: share of the order subtotal kept by In my bush (0.10 = 10 %)
-- delivery_fee: flat home-delivery fee per order, in Ariary
-- free_delivery_threshold: subtotal from which home delivery is free (0 = never)
-- seller_accept_hours: delay for the seller to accept an order before automatic cancellation
-- auto_release_days: days after delivery before the payment is released without buyer confirmation
INSERT INTO platform_settings (key, value) VALUES
    ('commission_rate', '0.10'),
    ('delivery_fee', '3000'),
    ('free_delivery_threshold', '0'),
    ('seller_accept_hours', '24'),
    ('auto_release_days', '3');
