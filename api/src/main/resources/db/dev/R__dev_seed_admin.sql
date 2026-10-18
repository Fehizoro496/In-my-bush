-- Development seed data for the backoffice (profile "dev" only), applied after R__dev_seed.sql.
-- It fills every admin screen: accounts and shops in each status, a moderation queue, orders in each
-- status, reports of each kind and a journal of past decisions.
-- Idempotent: every insert uses ON CONFLICT DO NOTHING so the repeatable migration can re-run.
-- All accounts use the password: Inmybush2026!

-- ---------------------------------------------------------------- users
-- 0101–0104 buyers (active, active, suspended, banned) · 0105–0107 sellers · 0108 second administrator
INSERT INTO users (id, first_name, last_name, email, phone, password_hash, status, phone_verified_at, created_at) VALUES
    ('0b000000-0000-4000-8000-000000000101', 'Lova',   'Rabe',           'lova@example.mg',    '+261340100101', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE',    now(), now() - interval '40 days'),
    ('0b000000-0000-4000-8000-000000000102', 'Nirina', 'Andry',          'nirina@example.mg',  '+261340100102', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE',    now(), now() - interval '25 days'),
    ('0b000000-0000-4000-8000-000000000103', 'Solo',   'Randria',        'solo@example.mg',    '+261340100103', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'SUSPENDED', now(), now() - interval '18 days'),
    ('0b000000-0000-4000-8000-000000000104', 'Jean',   'Rasolofo',       'jean@example.mg',    '+261340100104', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'BANNED',    now(), now() - interval '30 days'),
    ('0b000000-0000-4000-8000-000000000105', 'Haja',   'Ramanana',       'vergers@example.mg', '+261340100105', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE',    now(), now() - interval '21 days'),
    ('0b000000-0000-4000-8000-000000000106', 'Zo',     'Rakotomalala',   'epices@example.mg',  '+261340100106', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE',    now(), now() - interval '15 days'),
    ('0b000000-0000-4000-8000-000000000107', 'Toky',   'Ravelo',         'express@example.mg', '+261340100107', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'SUSPENDED', now(), now() - interval '12 days'),
    ('0b000000-0000-4000-8000-000000000108', 'Miora',  'Rabemananjara',  'miora@inmybush.mg',  '+261340100108', '$2a$10$pRxqHEJdhVZJNq6Gu5KRg.2WGJ4usPVMSyGfkyQ0Dc7/bxDs3TLjy', 'ACTIVE',    now(), now() - interval '60 days')
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role) VALUES
    ('0b000000-0000-4000-8000-000000000101', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000102', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000103', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000104', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000105', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000105', 'SELLER'),
    ('0b000000-0000-4000-8000-000000000106', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000106', 'SELLER'),
    ('0b000000-0000-4000-8000-000000000107', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000107', 'SELLER'),
    ('0b000000-0000-4000-8000-000000000108', 'BUYER'),
    ('0b000000-0000-4000-8000-000000000108', 'ADMIN')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- shops (one per status)
INSERT INTO shops (id, owner_id, name, slug, description, region, city, status, created_at) VALUES
    ('0e000000-0000-4000-8000-000000000101', '0b000000-0000-4000-8000-000000000105', 'Vergers d''Itasy', 'vergers-d-itasy',
     'Fruits de verger cueillis à maturité autour du lac Itasy.', 'Itasy', 'Ampefy', 'ACTIVE', now() - interval '20 days'),
    ('0e000000-0000-4000-8000-000000000102', '0b000000-0000-4000-8000-000000000106', 'Épices de Sambava', 'epices-de-sambava',
     'Vanille, poivre sauvage et épices de la SAVA, en direct des planteurs.', 'SAVA', 'Sambava', 'PAUSED', now() - interval '14 days'),
    ('0e000000-0000-4000-8000-000000000103', '0b000000-0000-4000-8000-000000000107', 'Bio Express Tana', 'bio-express-tana',
     'Compléments et tisanes « bien-être ».', 'Analamanga', 'Antananarivo', 'SUSPENDED', now() - interval '11 days')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- products
-- Category ids come from V2 (see R__dev_seed.sql).
INSERT INTO products (id, shop_id, category_id, name, slug, description, price, compare_at_price, unit, unit_label,
                      stock, low_stock_threshold, origin_region, status, rejection_reason, created_at) VALUES
    -- Moderation queue: 7 products waiting for review, the oldest for 19 hours
    ('0f000000-0000-4000-8000-000000000101', '0e000000-0000-4000-8000-000000000101', '0a000000-0000-4000-8000-000000000001',
     'Avocats Hass', 'avocats-hass', 'Avocats Hass à chair beurrée, cueillis à maturité.',
     5000, NULL, 'KG', 'kg', 35, 5, 'Itasy', 'PENDING_REVIEW', NULL, now() - interval '19 hours'),
    ('0f000000-0000-4000-8000-000000000102', '0e000000-0000-4000-8000-000000000101', '0a000000-0000-4000-8000-000000000001',
     'Litchis frais', 'litchis-frais', 'Litchis de saison, en grappes.',
     4000, NULL, 'KG', 'kg', 60, 10, 'Itasy', 'PENDING_REVIEW', NULL, now() - interval '12 hours'),
    ('0f000000-0000-4000-8000-000000000103', '0e000000-0000-4000-8000-000000000102', '0a000000-0000-4000-8000-000000000003',
     'Vanille Bourbon', 'vanille-bourbon', 'Gousses de vanille Bourbon noire, 16 à 18 cm, affinées six mois.',
     25000, 30000, 'PACK', '10 gousses', 40, 5, 'SAVA', 'PENDING_REVIEW', NULL, now() - interval '9 hours'),
    ('0f000000-0000-4000-8000-000000000104', '0e000000-0000-4000-8000-000000000102', '0a000000-0000-4000-8000-000000000003',
     'Poivre sauvage voatsiperifery', 'poivre-sauvage-voatsiperifery', 'Poivre sauvage récolté en forêt, notes boisées et d''agrumes.',
     12000, NULL, 'JAR', 'pot 100 g', 22, 4, 'SAVA', 'PENDING_REVIEW', NULL, now() - interval '6 hours'),
    ('0f000000-0000-4000-8000-000000000105', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000005',
     'Confiture de goyave', 'confiture-de-goyave', 'Confiture artisanale, 60 % de fruits, cuite au chaudron.',
     7500, NULL, 'JAR', 'pot 350 g', 18, 4, 'Analamanga', 'PENDING_REVIEW', NULL, now() - interval '4 hours'),
    ('0f000000-0000-4000-8000-000000000106', '0e000000-0000-4000-8000-000000000004', '0a000000-0000-4000-8000-000000000008',
     'Baume karité-ravintsara', 'baume-karite-ravintsara', 'Baume réparateur au beurre de karité et à l''huile essentielle de ravintsara.',
     9000, NULL, 'JAR', 'pot 50 ml', 30, 5, 'Antananarivo', 'PENDING_REVIEW', NULL, now() - interval '2 hours'),
    ('0f000000-0000-4000-8000-000000000107', '0e000000-0000-4000-8000-000000000003', '0a000000-0000-4000-8000-000000000006',
     'Riz rouge des Hautes Terres', 'riz-rouge-des-hautes-terres', 'Riz rouge complet, cultivé sans intrants chimiques.',
     3500, NULL, 'KG', 'kg', 200, 20, 'Vakinankaratra', 'PENDING_REVIEW', NULL, now() - interval '40 minutes'),
    -- Rejected, with the reason shown to the seller
    ('0f000000-0000-4000-8000-000000000111', '0e000000-0000-4000-8000-000000000103', '0a000000-0000-4000-8000-000000000009',
     'Complément minceur miracle', 'complement-minceur-miracle', 'Perdez 10 kg en deux semaines, sans effort.',
     45000, NULL, 'JAR', 'pot 60 gélules', 100, 10, 'Analamanga', 'REJECTED',
     'Allégation de santé non autorisée et composition non précisée.', now() - interval '10 days'),
    ('0f000000-0000-4000-8000-000000000112', '0e000000-0000-4000-8000-000000000004', '0a000000-0000-4000-8000-000000000008',
     'Huile essentielle sans étiquette', 'huile-essentielle-sans-etiquette', 'Flacon de 10 ml.',
     15000, NULL, 'PIECE', 'flacon', 12, 3, 'Antananarivo', 'REJECTED',
     'Photos illisibles ; la plante et le mode d''extraction ne sont pas indiqués.', now() - interval '5 days'),
    -- Drafts and archived
    ('0f000000-0000-4000-8000-000000000121', '0e000000-0000-4000-8000-000000000101', '0a000000-0000-4000-8000-000000000001',
     'Oranges d''Itasy', 'oranges-d-itasy', 'Oranges juteuses à jus.',
     2500, NULL, 'KG', 'kg', 0, 5, 'Itasy', 'DRAFT', NULL, now() - interval '3 days'),
    ('0f000000-0000-4000-8000-000000000122', '0e000000-0000-4000-8000-000000000102', '0a000000-0000-4000-8000-000000000003',
     'Cannelle en bâtons', 'cannelle-en-batons', 'Bâtons de cannelle roulés à la main.',
     5000, NULL, 'PACK', 'sachet 50 g', 0, 5, 'SAVA', 'DRAFT', NULL, now() - interval '2 days'),
    ('0f000000-0000-4000-8000-000000000123', '0e000000-0000-4000-8000-000000000101', '0a000000-0000-4000-8000-000000000001',
     'Pêches de saison', 'peches-de-saison', 'Pêches blanches, fin de saison.',
     6000, NULL, 'KG', 'kg', 0, 5, 'Itasy', 'ARCHIVED', NULL, now() - interval '18 days'),
    -- Published
    ('0f000000-0000-4000-8000-000000000131', '0e000000-0000-4000-8000-000000000101', '0a000000-0000-4000-8000-000000000001',
     'Ananas Victoria', 'ananas-victoria', 'Petit ananas très sucré, à chair dorée.',
     4000, NULL, 'PIECE', 'pièce', 48, 8, 'Itasy', 'PUBLISHED', NULL, now() - interval '19 days'),
    ('0f000000-0000-4000-8000-000000000132', '0e000000-0000-4000-8000-000000000101', '0a000000-0000-4000-8000-000000000001',
     'Citrons verts', 'citrons-verts', 'Citrons verts non traités après récolte.',
     3000, NULL, 'KG', 'kg', 25, 5, 'Itasy', 'PUBLISHED', NULL, now() - interval '19 days'),
    ('0f000000-0000-4000-8000-000000000133', '0e000000-0000-4000-8000-000000000102', '0a000000-0000-4000-8000-000000000003',
     'Curcuma en poudre', 'curcuma-en-poudre', 'Curcuma séché au soleil puis moulu.',
     6000, NULL, 'JAR', 'pot 100 g', 4, 5, 'SAVA', 'PUBLISHED', NULL, now() - interval '13 days'),
    -- Published by a shop suspended since: hidden from the catalogue, still listed in the backoffice
    ('0f000000-0000-4000-8000-000000000134', '0e000000-0000-4000-8000-000000000103', '0a000000-0000-4000-8000-000000000004',
     'Tisane détox', 'tisane-detox', 'Mélange de plantes « purifiant ».',
     9000, NULL, 'PACK', 'sachet 80 g', 50, 5, 'Analamanga', 'PUBLISHED', NULL, now() - interval '11 days')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- orders
-- One order per status, an order whose acceptance delay has expired, and a two-shop checkout (0109).
INSERT INTO checkouts (id, buyer_id, address_id, delivery_mode, recipient, delivery_phone, delivery_address, delivery_slot, total, created_at) VALUES
    ('10000000-0000-4000-8000-000000000101', '0b000000-0000-4000-8000-000000000101', NULL, 'HOME',   'Lova Rabe',    '+261340100101', 'Lot IVC 12, Ambatonakanga, Antananarivo', 'Demain 9h–12h',    15000, now() - interval '1 day'),
    ('10000000-0000-4000-8000-000000000102', '0b000000-0000-4000-8000-000000000102', NULL, 'HOME',   'Nirina Andry', '+261340100102', 'Lot 45 B, Ivandry, Antananarivo',         'Vendredi 14h–17h', 43500, now() - interval '2 days'),
    ('10000000-0000-4000-8000-000000000103', '0b000000-0000-4000-8000-000000000101', NULL, 'HOME',   'Lova Rabe',    '+261340100101', 'Lot IVC 12, Ambatonakanga, Antananarivo', 'Aujourd''hui 14h–17h', 21000, now() - interval '3 days'),
    ('10000000-0000-4000-8000-000000000104', '0b000000-0000-4000-8000-000000000102', NULL, 'HOME',   'Nirina Andry', '+261340100102', 'Lot 45 B, Ivandry, Antananarivo',         'Lundi 9h–12h',     17000, now() - interval '6 days'),
    ('10000000-0000-4000-8000-000000000105', '0b000000-0000-4000-8000-000000000101', NULL, 'HOME',   'Lova Rabe',    '+261340100101', 'Lot IVC 12, Ambatonakanga, Antananarivo', 'Mercredi 9h–12h',  24000, now() - interval '5 days'),
    ('10000000-0000-4000-8000-000000000106', '0b000000-0000-4000-8000-000000000102', NULL, 'HOME',   'Nirina Andry', '+261340100102', 'Lot 45 B, Ivandry, Antananarivo',         'Jeudi 14h–17h',    15000, now() - interval '4 days'),
    ('10000000-0000-4000-8000-000000000107', '0b000000-0000-4000-8000-000000000101', NULL, 'HOME',   'Lova Rabe',    '+261340100101', 'Lot IVC 12, Ambatonakanga, Antananarivo', 'Samedi 9h–12h',    23000, now() - interval '8 days'),
    ('10000000-0000-4000-8000-000000000108', '0b000000-0000-4000-8000-000000000101', NULL, 'HOME',   'Lova Rabe',    '+261340100101', 'Lot IVC 12, Ambatonakanga, Antananarivo', 'Demain 14h–17h',   21000, now() - interval '30 hours'),
    ('10000000-0000-4000-8000-000000000109', '0b000000-0000-4000-8000-000000000102', NULL, 'HOME',   'Nirina Andry', '+261340100102', 'Lot 45 B, Ivandry, Antananarivo',         'Demain 9h–12h',    23000, now() - interval '3 hours')
ON CONFLICT DO NOTHING;

INSERT INTO payments (id, checkout_id, method, phone, amount, status, provider_ref, created_at) VALUES
    ('11000000-0000-4000-8000-000000000101', '10000000-0000-4000-8000-000000000101', 'CASH_ON_DELIVERY', NULL,            15000, 'PENDING',  NULL,            now() - interval '1 day'),
    ('11000000-0000-4000-8000-000000000102', '10000000-0000-4000-8000-000000000102', 'MVOLA',            '+261340100102', 43500, 'HELD',     'FAKE-SEED0102', now() - interval '2 days'),
    ('11000000-0000-4000-8000-000000000103', '10000000-0000-4000-8000-000000000103', 'CASH_ON_DELIVERY', NULL,            21000, 'PENDING',  NULL,            now() - interval '3 days'),
    ('11000000-0000-4000-8000-000000000104', '10000000-0000-4000-8000-000000000104', 'CASH_ON_DELIVERY', NULL,            17000, 'RELEASED', NULL,            now() - interval '6 days'),
    ('11000000-0000-4000-8000-000000000105', '10000000-0000-4000-8000-000000000105', 'ORANGE_MONEY',     '+261340100101', 24000, 'HELD',     'FAKE-SEED0105', now() - interval '5 days'),
    ('11000000-0000-4000-8000-000000000106', '10000000-0000-4000-8000-000000000106', 'MVOLA',            '+261340100102', 15000, 'REFUNDED', 'FAKE-SEED0106', now() - interval '4 days'),
    ('11000000-0000-4000-8000-000000000107', '10000000-0000-4000-8000-000000000107', 'AIRTEL_MONEY',     '+261340100101', 23000, 'REFUNDED', 'FAKE-SEED0107', now() - interval '8 days'),
    ('11000000-0000-4000-8000-000000000108', '10000000-0000-4000-8000-000000000108', 'CASH_ON_DELIVERY', NULL,            21000, 'PENDING',  NULL,            now() - interval '30 hours'),
    ('11000000-0000-4000-8000-000000000109', '10000000-0000-4000-8000-000000000109', 'CASH_ON_DELIVERY', NULL,            23000, 'PENDING',  NULL,            now() - interval '3 hours')
ON CONFLICT DO NOTHING;

-- commission = 10 % of the subtotal, total = subtotal + delivery_fee, seller_net = total - commission
INSERT INTO orders (id, number, checkout_id, buyer_id, shop_id, status, payment_status, delivery_mode, subtotal, delivery_fee,
                    discount, commission, total, seller_net, delivery_slot, accept_before, delivered_at, delivery_confirmed_at,
                    cancel_reason, created_at) VALUES
    ('12000000-0000-4000-8000-000000000101', 'IMB-24822', '10000000-0000-4000-8000-000000000101', '0b000000-0000-4000-8000-000000000101',
     '0e000000-0000-4000-8000-000000000101', 'ACCEPTED', 'PENDING', 'HOME', 12000, 3000, 0, 1200, 15000, 13800, 'Demain 9h–12h',
     now(), NULL, NULL, NULL, now() - interval '1 day'),
    ('12000000-0000-4000-8000-000000000102', 'IMB-24823', '10000000-0000-4000-8000-000000000102', '0b000000-0000-4000-8000-000000000102',
     '0e000000-0000-4000-8000-000000000002', 'PREPARED', 'HELD', 'HOME', 40500, 3000, 0, 4050, 43500, 39450, 'Vendredi 14h–17h',
     now() - interval '1 day', NULL, NULL, NULL, now() - interval '2 days'),
    ('12000000-0000-4000-8000-000000000103', 'IMB-24824', '10000000-0000-4000-8000-000000000103', '0b000000-0000-4000-8000-000000000101',
     '0e000000-0000-4000-8000-000000000003', 'IN_DELIVERY', 'PENDING', 'HOME', 18000, 3000, 0, 1800, 21000, 19200, 'Aujourd''hui 14h–17h',
     now() - interval '2 days', NULL, NULL, NULL, now() - interval '3 days'),
    ('12000000-0000-4000-8000-000000000104', 'IMB-24825', '10000000-0000-4000-8000-000000000104', '0b000000-0000-4000-8000-000000000102',
     '0e000000-0000-4000-8000-000000000101', 'DELIVERED', 'RELEASED', 'HOME', 14000, 3000, 0, 1400, 17000, 15600, 'Lundi 9h–12h',
     now() - interval '5 days', now() - interval '4 days', now() - interval '4 days', NULL, now() - interval '6 days'),
    -- Delivered, reception not confirmed by the buyer yet
    ('12000000-0000-4000-8000-000000000105', 'IMB-24826', '10000000-0000-4000-8000-000000000105', '0b000000-0000-4000-8000-000000000101',
     '0e000000-0000-4000-8000-000000000004', 'DELIVERED', 'HELD', 'HOME', 21000, 3000, 0, 2100, 24000, 21900, 'Mercredi 9h–12h',
     now() - interval '4 days', now() - interval '1 day', NULL, NULL, now() - interval '5 days'),
    ('12000000-0000-4000-8000-000000000106', 'IMB-24827', '10000000-0000-4000-8000-000000000106', '0b000000-0000-4000-8000-000000000102',
     '0e000000-0000-4000-8000-000000000102', 'REFUSED', 'REFUNDED', 'HOME', 12000, 3000, 0, 1200, 15000, 13800, 'Jeudi 14h–17h',
     now() - interval '3 days', NULL, NULL, 'Rupture de stock chez le producteur.', now() - interval '4 days'),
    ('12000000-0000-4000-8000-000000000107', 'IMB-24828', '10000000-0000-4000-8000-000000000107', '0b000000-0000-4000-8000-000000000101',
     '0e000000-0000-4000-8000-000000000001', 'CANCELLED', 'REFUNDED', 'HOME', 20000, 3000, 0, 2000, 23000, 21000, 'Samedi 9h–12h',
     now() - interval '7 days', NULL, NULL, 'Annulée par l''acheteur avant préparation.', now() - interval '8 days'),
    -- Acceptance delay expired 6 hours ago: the seller never answered
    ('12000000-0000-4000-8000-000000000108', 'IMB-24829', '10000000-0000-4000-8000-000000000108', '0b000000-0000-4000-8000-000000000101',
     '0e000000-0000-4000-8000-000000000002', 'PENDING_CONFIRMATION', 'PENDING', 'HOME', 18000, 3000, 0, 1800, 21000, 19200, 'Demain 14h–17h',
     now() - interval '6 hours', NULL, NULL, NULL, now() - interval '30 hours'),
    -- Two-shop checkout: one shop still has to answer, the other accepted
    ('12000000-0000-4000-8000-000000000109', 'IMB-24830', '10000000-0000-4000-8000-000000000109', '0b000000-0000-4000-8000-000000000102',
     '0e000000-0000-4000-8000-000000000101', 'PENDING_CONFIRMATION', 'PENDING', 'HOME', 8000, 3000, 0, 800, 11000, 10200, 'Demain 9h–12h',
     now() + interval '21 hours', NULL, NULL, NULL, now() - interval '3 hours'),
    ('12000000-0000-4000-8000-000000000110', 'IMB-24831', '10000000-0000-4000-8000-000000000109', '0b000000-0000-4000-8000-000000000102',
     '0e000000-0000-4000-8000-000000000003', 'ACCEPTED', 'PENDING', 'HOME', 9000, 3000, 0, 900, 12000, 11100, 'Demain 9h–12h',
     now() + interval '21 hours', NULL, NULL, NULL, now() - interval '3 hours')
ON CONFLICT DO NOTHING;

SELECT setval('order_number_seq', GREATEST((SELECT last_value FROM order_number_seq), 24831));

INSERT INTO order_items (id, order_id, product_id, product_name, product_slug, unit_price, unit_label, quantity, line_total) VALUES
    ('13000000-0000-4000-8000-000000000101', '12000000-0000-4000-8000-000000000101', '0f000000-0000-4000-8000-000000000131', 'Ananas Victoria',            'ananas-victoria',            4000,  'pièce',       3, 12000),
    ('13000000-0000-4000-8000-000000000102', '12000000-0000-4000-8000-000000000102', '0f000000-0000-4000-8000-000000000015', 'Coffret découverte 3 miels', 'coffret-decouverte-3-miels', 40500, 'coffret',     1, 40500),
    ('13000000-0000-4000-8000-000000000103', '12000000-0000-4000-8000-000000000103', '0f000000-0000-4000-8000-000000000021', 'Tomates cœur de bœuf',       'tomates-coeur-de-boeuf',     4500,  'kg',          4, 18000),
    ('13000000-0000-4000-8000-000000000104', '12000000-0000-4000-8000-000000000104', '0f000000-0000-4000-8000-000000000132', 'Citrons verts',              'citrons-verts',              3000,  'kg',          2, 6000),
    ('13000000-0000-4000-8000-000000000105', '12000000-0000-4000-8000-000000000104', '0f000000-0000-4000-8000-000000000131', 'Ananas Victoria',            'ananas-victoria',            4000,  'pièce',       2, 8000),
    ('13000000-0000-4000-8000-000000000106', '12000000-0000-4000-8000-000000000105', '0f000000-0000-4000-8000-000000000031', 'Savon au ravintsara',        'savon-au-ravintsara',        7000,  'pièce',       3, 21000),
    ('13000000-0000-4000-8000-000000000107', '12000000-0000-4000-8000-000000000106', '0f000000-0000-4000-8000-000000000133', 'Curcuma en poudre',          'curcuma-en-poudre',          6000,  'pot 100 g',   2, 12000),
    ('13000000-0000-4000-8000-000000000108', '12000000-0000-4000-8000-000000000107', '0f000000-0000-4000-8000-000000000004', 'Panier de saison',           'panier-de-saison',           20000, 'panier 5 kg', 1, 20000),
    ('13000000-0000-4000-8000-000000000109', '12000000-0000-4000-8000-000000000108', '0f000000-0000-4000-8000-000000000011', 'Miel de litchi cru',         'miel-de-litchi-cru',         18000, 'pot 500 g',   1, 18000),
    ('13000000-0000-4000-8000-000000000110', '12000000-0000-4000-8000-000000000109', '0f000000-0000-4000-8000-000000000131', 'Ananas Victoria',            'ananas-victoria',            4000,  'pièce',       2, 8000),
    ('13000000-0000-4000-8000-000000000111', '12000000-0000-4000-8000-000000000110', '0f000000-0000-4000-8000-000000000021', 'Tomates cœur de bœuf',       'tomates-coeur-de-boeuf',     4500,  'kg',          2, 9000)
ON CONFLICT DO NOTHING;

INSERT INTO order_events (id, order_id, status, note, created_at) VALUES
    ('14000000-0000-4000-8000-000000000101', '12000000-0000-4000-8000-000000000101', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '1 day'),
    ('14000000-0000-4000-8000-000000000102', '12000000-0000-4000-8000-000000000101', 'ACCEPTED', NULL, now() - interval '22 hours'),
    ('14000000-0000-4000-8000-000000000103', '12000000-0000-4000-8000-000000000102', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '2 days'),
    ('14000000-0000-4000-8000-000000000104', '12000000-0000-4000-8000-000000000102', 'ACCEPTED', NULL, now() - interval '46 hours'),
    ('14000000-0000-4000-8000-000000000105', '12000000-0000-4000-8000-000000000102', 'PREPARED', NULL, now() - interval '1 day'),
    ('14000000-0000-4000-8000-000000000106', '12000000-0000-4000-8000-000000000103', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '3 days'),
    ('14000000-0000-4000-8000-000000000107', '12000000-0000-4000-8000-000000000103', 'ACCEPTED', NULL, now() - interval '70 hours'),
    ('14000000-0000-4000-8000-000000000108', '12000000-0000-4000-8000-000000000103', 'PREPARED', NULL, now() - interval '2 days'),
    ('14000000-0000-4000-8000-000000000109', '12000000-0000-4000-8000-000000000103', 'IN_DELIVERY', NULL, now() - interval '3 hours'),
    ('14000000-0000-4000-8000-000000000110', '12000000-0000-4000-8000-000000000104', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '6 days'),
    ('14000000-0000-4000-8000-000000000111', '12000000-0000-4000-8000-000000000104', 'ACCEPTED', NULL, now() - interval '142 hours'),
    ('14000000-0000-4000-8000-000000000112', '12000000-0000-4000-8000-000000000104', 'PREPARED', NULL, now() - interval '5 days'),
    ('14000000-0000-4000-8000-000000000113', '12000000-0000-4000-8000-000000000104', 'IN_DELIVERY', NULL, now() - interval '100 hours'),
    ('14000000-0000-4000-8000-000000000114', '12000000-0000-4000-8000-000000000104', 'DELIVERED', 'Réception confirmée par l''acheteur', now() - interval '4 days'),
    ('14000000-0000-4000-8000-000000000115', '12000000-0000-4000-8000-000000000105', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '5 days'),
    ('14000000-0000-4000-8000-000000000116', '12000000-0000-4000-8000-000000000105', 'ACCEPTED', NULL, now() - interval '118 hours'),
    ('14000000-0000-4000-8000-000000000117', '12000000-0000-4000-8000-000000000105', 'PREPARED', NULL, now() - interval '3 days'),
    ('14000000-0000-4000-8000-000000000118', '12000000-0000-4000-8000-000000000105', 'IN_DELIVERY', NULL, now() - interval '2 days'),
    ('14000000-0000-4000-8000-000000000119', '12000000-0000-4000-8000-000000000105', 'DELIVERED', 'Livrée, en attente de confirmation de l''acheteur', now() - interval '1 day'),
    ('14000000-0000-4000-8000-000000000120', '12000000-0000-4000-8000-000000000106', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '4 days'),
    ('14000000-0000-4000-8000-000000000121', '12000000-0000-4000-8000-000000000106', 'REFUSED', 'Rupture de stock chez le producteur.', now() - interval '90 hours'),
    ('14000000-0000-4000-8000-000000000122', '12000000-0000-4000-8000-000000000107', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '8 days'),
    ('14000000-0000-4000-8000-000000000123', '12000000-0000-4000-8000-000000000107', 'ACCEPTED', NULL, now() - interval '190 hours'),
    ('14000000-0000-4000-8000-000000000124', '12000000-0000-4000-8000-000000000107', 'CANCELLED', 'Annulée par l''acheteur avant préparation.', now() - interval '7 days'),
    ('14000000-0000-4000-8000-000000000125', '12000000-0000-4000-8000-000000000108', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '30 hours'),
    ('14000000-0000-4000-8000-000000000126', '12000000-0000-4000-8000-000000000109', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '3 hours'),
    ('14000000-0000-4000-8000-000000000127', '12000000-0000-4000-8000-000000000110', 'PENDING_CONFIRMATION', 'Commande passée', now() - interval '3 hours'),
    ('14000000-0000-4000-8000-000000000128', '12000000-0000-4000-8000-000000000110', 'ACCEPTED', NULL, now() - interval '2 hours')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- reports (each target type and each status)
INSERT INTO reports (id, reporter_id, target_type, target_id, reason, details, status, resolution_note, resolved_by, resolved_at, created_at) VALUES
    ('19000000-0000-4000-8000-000000000101', '0b000000-0000-4000-8000-000000000101', 'PRODUCT', '0f000000-0000-4000-8000-000000000134',
     'Allégation trompeuse', 'La fiche promet de « purifier le foie » sans aucune preuve ni liste d''ingrédients.',
     'OPEN', NULL, NULL, NULL, now() - interval '3 hours'),
    ('19000000-0000-4000-8000-000000000102', '0b000000-0000-4000-8000-000000000102', 'SHOP', '0e000000-0000-4000-8000-000000000103',
     'Vendeur frauduleux', 'Commande payée, jamais livrée, le vendeur ne répond plus aux messages.',
     'OPEN', NULL, NULL, NULL, now() - interval '1 day'),
    ('19000000-0000-4000-8000-000000000103', '0b000000-0000-4000-8000-000000000003', 'USER', '0b000000-0000-4000-8000-000000000103',
     'Harcèlement', 'Messages insistants et insultants après un refus de vente.',
     'OPEN', NULL, NULL, NULL, now() - interval '2 days'),
    ('19000000-0000-4000-8000-000000000104', '0b000000-0000-4000-8000-000000000004', 'REVIEW', '15000000-0000-4000-8000-000000000001',
     'Avis hors sujet', 'L''avis parle de la livraison d''une autre commande.',
     'OPEN', NULL, NULL, NULL, now() - interval '5 hours'),
    ('19000000-0000-4000-8000-000000000105', '0b000000-0000-4000-8000-000000000002', 'MESSAGE', '17000000-0000-4000-8000-000000000001',
     'Spam', 'Même message envoyé plusieurs fois.',
     'OPEN', NULL, NULL, NULL, now() - interval '80 minutes'),
    ('19000000-0000-4000-8000-000000000106', '0b000000-0000-4000-8000-000000000101', 'PRODUCT', '0f000000-0000-4000-8000-000000000013',
     'Produit non conforme', 'Pot reçu à moitié plein par rapport à la photo.',
     'IN_REVIEW', NULL, NULL, NULL, now() - interval '2 days'),
    ('19000000-0000-4000-8000-000000000107', '0b000000-0000-4000-8000-000000000102', 'USER', '0b000000-0000-4000-8000-000000000104',
     'Arnaque', 'Se fait passer pour un vendeur et demande un paiement hors plateforme.',
     'RESOLVED', 'Compte banni après vérification des messages.', '0b000000-0000-4000-8000-000000000001', now() - interval '9 days', now() - interval '10 days'),
    ('19000000-0000-4000-8000-000000000108', '0b000000-0000-4000-8000-000000000103', 'PRODUCT', '0f000000-0000-4000-8000-000000000012',
     'Prix trop élevé', NULL,
     'DISMISSED', 'Le prix est libre : aucune infraction aux règles.', '0b000000-0000-4000-8000-000000000108', now() - interval '13 days', now() - interval '14 days')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- notifications sent by past moderation decisions
INSERT INTO notifications (id, user_id, context, type, title, body, link, created_at) VALUES
    ('18000000-0000-4000-8000-000000000101', '0b000000-0000-4000-8000-000000000107', 'SALE', 'PRODUCT_REJECTED',
     'Produit refusé : Complément minceur miracle', 'Allégation de santé non autorisée et composition non précisée.',
     '/vendre/produits/0f000000-0000-4000-8000-000000000111', now() - interval '10 days'),
    ('18000000-0000-4000-8000-000000000102', '0b000000-0000-4000-8000-000000000006', 'SALE', 'PRODUCT_REJECTED',
     'Produit refusé : Huile essentielle sans étiquette', 'Photos illisibles ; la plante et le mode d''extraction ne sont pas indiqués.',
     '/vendre/produits/0f000000-0000-4000-8000-000000000112', now() - interval '5 days'),
    ('18000000-0000-4000-8000-000000000103', '0b000000-0000-4000-8000-000000000105', 'SALE', 'PRODUCT_APPROVED',
     'Produit publié : Ananas Victoria', 'Votre produit est en ligne.',
     '/vendre/produits/0f000000-0000-4000-8000-000000000131', now() - interval '19 days')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------- administration journal (matches the states above)
INSERT INTO admin_audit_events (id, actor_id, action, target_type, target_id, reason, created_at, updated_at) VALUES
    ('1a000000-0000-4000-8000-000000000101', '0b000000-0000-4000-8000-000000000001', 'PRODUCT_APPROVED',  'PRODUCT',  '0f000000-0000-4000-8000-000000000131', NULL, now() - interval '19 days', now() - interval '19 days'),
    ('1a000000-0000-4000-8000-000000000102', '0b000000-0000-4000-8000-000000000001', 'PRODUCT_APPROVED',  'PRODUCT',  '0f000000-0000-4000-8000-000000000132', NULL, now() - interval '19 days', now() - interval '19 days'),
    ('1a000000-0000-4000-8000-000000000103', '0b000000-0000-4000-8000-000000000108', 'REPORT_DISMISSED',  'REPORT',   '19000000-0000-4000-8000-000000000108', 'Le prix est libre : aucune infraction aux règles.', now() - interval '13 days', now() - interval '13 days'),
    ('1a000000-0000-4000-8000-000000000104', '0b000000-0000-4000-8000-000000000108', 'PRODUCT_APPROVED',  'PRODUCT',  '0f000000-0000-4000-8000-000000000133', NULL, now() - interval '13 days', now() - interval '13 days'),
    ('1a000000-0000-4000-8000-000000000105', '0b000000-0000-4000-8000-000000000108', 'PRODUCT_APPROVED',  'PRODUCT',  '0f000000-0000-4000-8000-000000000134', NULL, now() - interval '11 days', now() - interval '11 days'),
    ('1a000000-0000-4000-8000-000000000106', '0b000000-0000-4000-8000-000000000001', 'PRODUCT_REJECTED',  'PRODUCT',  '0f000000-0000-4000-8000-000000000111', 'Allégation de santé non autorisée et composition non précisée.', now() - interval '10 days', now() - interval '10 days'),
    ('1a000000-0000-4000-8000-000000000107', '0b000000-0000-4000-8000-000000000001', 'USER_BANNED',       'USER',     '0b000000-0000-4000-8000-000000000104', 'Usurpation d''identité et demandes de paiement hors plateforme.', now() - interval '9 days', now() - interval '9 days'),
    ('1a000000-0000-4000-8000-000000000108', '0b000000-0000-4000-8000-000000000001', 'REPORT_RESOLVED',   'REPORT',   '19000000-0000-4000-8000-000000000107', 'Compte banni après vérification des messages.', now() - interval '9 days', now() - interval '9 days'),
    ('1a000000-0000-4000-8000-000000000109', '0b000000-0000-4000-8000-000000000108', 'USER_SUSPENDED',    'USER',     '0b000000-0000-4000-8000-000000000107', 'Plusieurs commandes payées non livrées : suspension le temps de l''enquête.', now() - interval '6 days', now() - interval '6 days'),
    ('1a000000-0000-4000-8000-000000000110', '0b000000-0000-4000-8000-000000000108', 'PRODUCT_REJECTED',  'PRODUCT',  '0f000000-0000-4000-8000-000000000112', 'Photos illisibles ; la plante et le mode d''extraction ne sont pas indiqués.', now() - interval '5 days', now() - interval '5 days'),
    ('1a000000-0000-4000-8000-000000000111', '0b000000-0000-4000-8000-000000000001', 'SETTINGS_UPDATED',  'PLATFORM', NULL, 'commission_rate', now() - interval '3 days', now() - interval '3 days'),
    ('1a000000-0000-4000-8000-000000000112', '0b000000-0000-4000-8000-000000000001', 'USER_SUSPENDED',    'USER',     '0b000000-0000-4000-8000-000000000103', 'Messages insultants envoyés à un vendeur.', now() - interval '36 hours', now() - interval '36 hours')
ON CONFLICT DO NOTHING;
