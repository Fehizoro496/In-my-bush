-- Development seed data (profile "dev" only: see application-dev.yml).
-- Idempotent: every insert uses ON CONFLICT DO NOTHING so the repeatable migration can re-run.
-- All accounts use the password: Inmybush2026!

-- ---------------------------------------------------------------- users
INSERT INTO users (id, first_name, last_name, email, phone, password_hash, status, phone_verified_at) VALUES
    ('0b000000-0000-4000-8000-000000000001', 'Admin',    'In my bush', 'admin@inmybush.mg',   '+261340000001', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE', now()),
    ('0b000000-0000-4000-8000-000000000002', 'Hery',     'Rakoto',     'hery@example.mg',     '+261341234567', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE', now()),
    ('0b000000-0000-4000-8000-000000000003', 'Fara',     'Naivo',      'fara@example.mg',     '+261329876543', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE', now()),
    ('0b000000-0000-4000-8000-000000000004', 'Voahangy', 'Rasoa',      'rucher@example.mg',   '+261331112233', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE', now()),
    ('0b000000-0000-4000-8000-000000000005', 'Tsiry',    'Andria',     'fermetsara@example.mg','+261344445566', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE', now()),
    ('0b000000-0000-4000-8000-000000000006', 'Mialy',    'Razafy',     'hazo@example.mg',     '+261347778899', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE', now())
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role) VALUES
    ('0b000000-0000-4000-8000-000000000001', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000001', 'ADMIN'),
    ('0b000000-0000-4000-8000-000000000002', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000002', 'SELLER'),
    ('0b000000-0000-4000-8000-000000000003', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000004', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000004', 'SELLER'),
    ('0b000000-0000-4000-8000-000000000005', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000005', 'SELLER'),
    ('0b000000-0000-4000-8000-000000000006', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000006', 'SELLER')
ON CONFLICT DO NOTHING;

INSERT INTO addresses (id, user_id, label, recipient, phone, line1, district, city, landmark, is_default) VALUES
    ('0c000000-0000-4000-8000-000000000001', '0b000000-0000-4000-8000-000000000003', 'Maison', 'Fara Naivo', '+261329876543',
     'Lot II J 45', 'Ankadifotsy', 'Antananarivo', 'Portail vert, face à l''épicerie', TRUE),
    ('0c000000-0000-4000-8000-000000000002', '0b000000-0000-4000-8000-000000000002', 'Maison', 'Hery Rakoto', '+261341234567',
     'Lot 12 Antsenakely', 'Antsenakely', 'Antsirabe', NULL, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO payout_methods (id, user_id, method, phone, phone_masked, is_default) VALUES
    ('0d000000-0000-4000-8000-000000000001', '0b000000-0000-4000-8000-000000000002', 'MVOLA', '+261341234567', '+261 34 •• ••• 67', TRUE),
    ('0d000000-0000-4000-8000-000000000002', '0b000000-0000-4000-8000-000000000004', 'ORANGE_MONEY', '+261331112233', '+261 33 •• ••• 33', TRUE)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- shops
INSERT INTO shops (id, owner_id, name, slug, description, region, city, status) VALUES
    ('0e000000-0000-4000-8000-000000000001', '0b000000-0000-4000-8000-000000000002', 'Le Jardin de Hery', 'le-jardin-de-hery',
     'Maraîchage familial sans pesticides de synthèse, récolté le matin même.', 'Vakinankaratra', 'Antsirabe', 'ACTIVE'),
    ('0e000000-0000-4000-8000-000000000002', '0b000000-0000-4000-8000-000000000004', 'Rucher Ambohimanga', 'rucher-ambohimanga',
     'Miels crus, pollen et produits de la ruche des collines d''Ambohimanga.', 'Analamanga', 'Ambohimanga', 'ACTIVE'),
    ('0e000000-0000-4000-8000-000000000003', '0b000000-0000-4000-8000-000000000005', 'Ferme Tsara', 'ferme-tsara',
     'Légumes de plein champ et tomates anciennes.', 'Vakinankaratra', 'Antsirabe', 'ACTIVE'),
    ('0e000000-0000-4000-8000-000000000004', '0b000000-0000-4000-8000-000000000006', 'Atelier Hazo', 'atelier-hazo',
     'Savons saponifiés à froid et baumes aux plantes malgaches.', 'Analamanga', 'Antananarivo', 'ACTIVE')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- products
-- Category ids come from V2: 01 fruits-legumes, 02 laitiers, 03 epicerie, 04 boissons, 05 miel, 06 cereales,
-- 07 artisanat, 08 cosmetiques, 09 produits-locaux.
INSERT INTO products (id, shop_id, category_id, name, slug, description, price, compare_at_price, unit, unit_label,
                      stock, low_stock_threshold, origin_region, status) VALUES
    -- Le Jardin de Hery
    ('0f000000-0000-4000-8000-000000000001', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001',
     'Brèdes mafana', 'bredes-mafana', 'Botte de brèdes mafana cueillies du jour, idéales pour le romazava.',
     1000, NULL, 'BUNCH', 'botte', 42, 5, 'Antsirabe', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000002', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001',
     'Carottes nouvelles', 'carottes-nouvelles', 'Carottes nouvelles sucrées, récoltées à la main.',
     2000, NULL, 'KG', 'kg', 3, 5, 'Antsirabe', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000003', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001',
     'Tomates cerises', 'tomates-cerises', 'Barquette de tomates cerises mûries sur pied.',
     6000, NULL, 'PACK', 'barquette', 18, 5, 'Antsirabe', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000004', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001',
     'Panier de saison', 'panier-de-saison', 'Environ 5 kg de légumes de saison selon la récolte de la semaine.',
     20000, 25000, 'PACK', 'panier 5 kg', 2, 3, 'Antsirabe', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000005', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001',
     'Fraises de Behenjy', 'fraises-de-behenjy', 'Fraises parfumées de Behenjy, en barquette.',
     8000, NULL, 'PACK', 'barquette', 0, 3, 'Behenjy', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000006', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001',
     'Gingembre frais', 'gingembre-frais', 'Gingembre frais, racines charnues et piquantes.',
     3000, NULL, 'KG', 'kg', 12, 4, 'Antsirabe', 'PENDING_REVIEW'),
    ('0f000000-0000-4000-8000-000000000007', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001',
     'Salade batavia', 'salade-batavia', 'Salade batavia croquante.',
     800, NULL, 'PIECE', 'pièce', 26, 6, 'Antsirabe', 'PUBLISHED'),
    -- Rucher Ambohimanga
    ('0f000000-0000-4000-8000-000000000011', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000005',
     'Miel de litchi cru', 'miel-de-litchi-cru', 'Miel cru de fleurs de litchi, non chauffé, extrait à froid.',
     18000, NULL, 'JAR', 'pot 500 g', 30, 5, 'Analamanga', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000012', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000005',
     'Miel d''eucalyptus', 'miel-d-eucalyptus', 'Miel d''eucalyptus au goût boisé.',
     15000, NULL, 'JAR', 'pot 500 g', 20, 5, 'Analamanga', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000013', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000005',
     'Pollen frais', 'pollen-frais', 'Pollen frais récolté et congelé aussitôt.',
     9000, NULL, 'JAR', '200 g', 2, 3, 'Analamanga', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000014', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000007',
     'Bougie à la cire d''abeille', 'bougie-a-la-cire-d-abeille', 'Bougie coulée à la main en cire d''abeille pure.',
     6000, NULL, 'PIECE', 'pièce', 15, 3, 'Analamanga', 'PUBLISHED'),
    ('0f000000-0000-4000-8000-000000000015', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000005',
     'Coffret découverte 3 miels', 'coffret-decouverte-3-miels', 'Trois pots de 250 g : litchi, eucalyptus, niaouli.',
     40500, 45000, 'PACK', 'coffret', 6, 2, 'Analamanga', 'PUBLISHED'),
    -- Ferme Tsara
    ('0f000000-0000-4000-8000-000000000021', '0e000000-0000-4000-8000-000000000003', '0a000000-0000-4000-8000-000000000001',
     'Tomates cœur de bœuf', 'tomates-coeur-de-boeuf', 'Grosses tomates charnues, variété ancienne.',
     4500, NULL, 'KG', 'kg', 40, 5, 'Antsirabe', 'PUBLISHED'),
    -- Atelier Hazo
    ('0f000000-0000-4000-8000-000000000031', '0e000000-0000-4000-8000-000000000004', '0a000000-0000-4000-8000-000000000008',
     'Savon au ravintsara', 'savon-au-ravintsara', 'Savon saponifié à froid à l''huile essentielle de ravintsara.',
     7000, NULL, 'PIECE', 'pièce', 25, 5, 'Antananarivo', 'PUBLISHED')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- one delivered order (with review) and one pending order
INSERT INTO checkouts (id, buyer_id, address_id, delivery_mode, recipient, delivery_phone, delivery_address, delivery_slot, total, created_at) VALUES
    ('10000000-0000-4000-8000-000000000001', '0b000000-0000-4000-8000-000000000003', '0c000000-0000-4000-8000-000000000001', 'HOME',
     'Fara Naivo', '+261329876543', 'Lot II J 45, Ankadifotsy, Antananarivo', 'Samedi 9h–12h', 39000, now() - interval '10 days'),
    ('10000000-0000-4000-8000-000000000002', '0b000000-0000-4000-8000-000000000003', '0c000000-0000-4000-8000-000000000001', 'HOME',
     'Fara Naivo', '+261329876543', 'Lot II J 45, Ankadifotsy, Antananarivo', 'Demain 14h–17h', 26000, now() - interval '2 hours')
ON CONFLICT DO NOTHING;

INSERT INTO payments (id, checkout_id, method, phone, amount, status, provider_ref, created_at) VALUES
    ('11000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'MVOLA', '+261329876543', 39000, 'RELEASED', 'FAKE-SEED0001', now() - interval '10 days'),
    ('11000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'MVOLA', '+261329876543', 26000, 'HELD', 'FAKE-SEED0002', now() - interval '2 hours')
ON CONFLICT DO NOTHING;

INSERT INTO orders (id, number, checkout_id, buyer_id, shop_id, status, payment_status, delivery_mode, subtotal, delivery_fee,
                    discount, commission, total, seller_net, delivery_slot, accept_before, delivered_at, delivery_confirmed_at, created_at) VALUES
    ('12000000-0000-4000-8000-000000000001', 'IMB-24820', '10000000-0000-4000-8000-000000000001', '0b000000-0000-4000-8000-000000000003',
     '0e000000-0000-4000-8000-000000000002', 'DELIVERED', 'RELEASED', 'HOME', 36000, 3000, 0, 3600, 39000, 35400, 'Samedi 9h–12h',
     now() - interval '9 days', now() - interval '7 days', now() - interval '7 days', now() - interval '10 days'),
    ('12000000-0000-4000-8000-000000000002', 'IMB-24821', '10000000-0000-4000-8000-000000000002', '0b000000-0000-4000-8000-000000000003',
     '0e000000-0000-4000-8000-000000000001', 'PENDING_CONFIRMATION', 'HELD', 'HOME', 23000, 3000, 0, 2300, 26000, 23700, 'Demain 14h–17h',
     now() + interval '22 hours', NULL, NULL, now() - interval '2 hours')
ON CONFLICT DO NOTHING;

SELECT setval('order_number_seq', GREATEST((SELECT last_value FROM order_number_seq), 24821));

INSERT INTO order_items (id, order_id, product_id, product_name, product_slug, unit_price, unit_label, quantity, line_total) VALUES
    ('13000000-0000-4000-8000-000000000001', '12000000-0000-4000-8000-000000000001', '0f000000-0000-4000-8000-000000000011',
     'Miel de litchi cru', 'miel-de-litchi-cru', 18000, 'pot 500 g', 2, 36000),
    ('13000000-0000-4000-8000-000000000002', '12000000-0000-4000-8000-000000000002', '0f000000-0000-4000-8000-000000000004',
     'Panier de saison', 'panier-de-saison', 20000, 'panier 5 kg', 1, 20000),
    ('13000000-0000-4000-8000-000000000003', '12000000-0000-4000-8000-000000000002', '0f000000-0000-4000-8000-000000000001',
     'Brèdes mafana', 'bredes-mafana', 1000, 'botte', 3, 3000)
ON CONFLICT DO NOTHING;

INSERT INTO order_events (id, order_id, status, note, created_at) VALUES
    ('14000000-0000-4000-8000-000000000001', '12000000-0000-4000-8000-000000000001', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '10 days'),
    ('14000000-0000-4000-8000-000000000002', '12000000-0000-4000-8000-000000000001', 'ACCEPTED', NULL, now() - interval '10 days' + interval '1 hour'),
    ('14000000-0000-4000-8000-000000000003', '12000000-0000-4000-8000-000000000001', 'PREPARED', NULL, now() - interval '9 days'),
    ('14000000-0000-4000-8000-000000000004', '12000000-0000-4000-8000-000000000001', 'IN_DELIVERY', NULL, now() - interval '8 days'),
    ('14000000-0000-4000-8000-000000000005', '12000000-0000-4000-8000-000000000001', 'DELIVERED', 'Réception confirmée par l''acheteur', now() - interval '7 days'),
    ('14000000-0000-4000-8000-000000000006', '12000000-0000-4000-8000-000000000002', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '2 hours')
ON CONFLICT DO NOTHING;

INSERT INTO reviews (id, product_id, order_id, author_id, rating, comment, seller_reply, replied_at, created_at) VALUES
    ('15000000-0000-4000-8000-000000000001', '0f000000-0000-4000-8000-000000000011', '12000000-0000-4000-8000-000000000001',
     '0b000000-0000-4000-8000-000000000003', 5, 'Accueil chaleureux au rucher, miel exceptionnel. Commande prête à l''heure.',
     'Misaotra Fara, à bientôt au rucher !', now() - interval '6 days', now() - interval '6 days')
ON CONFLICT DO NOTHING;

-- Ratings derived from the seeded reviews (kept consistent with ReviewService's recomputation).
UPDATE products p SET rating_avg = s.avg, rating_count = s.cnt
FROM (SELECT product_id, ROUND(AVG(rating)::numeric, 2) AS avg, COUNT(*) AS cnt FROM reviews GROUP BY product_id) s
WHERE p.id = s.product_id;

UPDATE shops sh SET rating_avg = s.avg, rating_count = s.cnt
FROM (SELECT p.shop_id, ROUND(AVG(r.rating)::numeric, 2) AS avg, COUNT(*) AS cnt
      FROM reviews r JOIN products p ON p.id = r.product_id GROUP BY p.shop_id) s
WHERE sh.id = s.shop_id;

INSERT INTO conversations (id, buyer_id, shop_id, product_id, order_id, last_message_at, last_message_preview, created_at) VALUES
    ('16000000-0000-4000-8000-000000000001', '0b000000-0000-4000-8000-000000000003', '0e000000-0000-4000-8000-000000000001',
     '0f000000-0000-4000-8000-000000000004', '12000000-0000-4000-8000-000000000002', now() - interval '90 minutes',
     'Bonjour, le panier contient-il des carottes cette semaine ?', now() - interval '90 minutes')
ON CONFLICT DO NOTHING;

INSERT INTO messages (id, conversation_id, sender_id, body, created_at) VALUES
    ('17000000-0000-4000-8000-000000000001', '16000000-0000-4000-8000-000000000001', '0b000000-0000-4000-8000-000000000003',
     'Bonjour, le panier contient-il des carottes cette semaine ?', now() - interval '90 minutes')
ON CONFLICT DO NOTHING;

INSERT INTO notifications (id, user_id, context, type, title, body, link, created_at) VALUES
    ('18000000-0000-4000-8000-000000000001', '0b000000-0000-4000-8000-000000000002', 'SALE', 'ORDER_RECEIVED',
     'Nouvelle commande IMB-24821', 'Fara N. a commandé 2 articles. Confirmez avant 24 h.', '/vendre/commandes/12000000-0000-4000-8000-000000000002', now() - interval '2 hours'),
    ('18000000-0000-4000-8000-000000000002', '0b000000-0000-4000-8000-000000000002', 'SALE', 'NEW_MESSAGE',
     'Nouveau message de Fara N.', 'Bonjour, le panier contient-il des carottes cette semaine ?', '/compte/messages?conversation=16000000-0000-4000-8000-000000000001', now() - interval '90 minutes')
ON CONFLICT DO NOTHING;
