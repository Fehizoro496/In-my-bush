import '../../../core/utils/formatters.dart';
import '../../../shared/models/visual.dart';
import 'catalog_models.dart';

/// Data of the mockups (M-Home, M-Product, M-Seller, M-Search, M-Categories,
/// M-Favorites…). Shared by every mock repository.
abstract class CatalogMockData {
  static final DateTime _now = DateTime.now();

  static DateTime daysAgo(int days, {int hour = 10, int minute = 0}) {
    final d = _now.subtract(Duration(days: days));
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  // Shops ----------------------------------------------------------------------
  static Shop _shop(
    String name,
    String initials,
    String color, {
    String city = '',
    String region = '',
    double rating = 4.7,
    int reviews = 20,
    int products = 8,
    int since = 2022,
    String coverTint = '#E6F3CC',
    String coverInk = '#365A10',
    String? ring,
    List<String> tags = const [],
    String description = '',
    String? responseTime,
    int? distanceKm,
    bool pickup = false,
    String? deliveryNote,
    String? slug,
  }) {
    final s = slug ?? slugify(name);
    return Shop(
      id: 'shop-$s',
      name: name,
      slug: s,
      city: city,
      region: region,
      ratingAvg: rating,
      ratingCount: reviews,
      productCount: products,
      createdAt: DateTime(since, 3, 1),
      avatar: AvatarLook(initials: initials, color: color),
      cover: Visual(tint: coverTint, ink: coverInk),
      ringColor: ring,
      tags: tags,
      description: description,
      responseTime: responseTime,
      distanceKm: distanceKm,
      pickup: pickup,
      deliveryNote: deliveryNote,
    );
  }

  static final Shop fermeTsara = _shop('Ferme Tsara', 'FT', '#4A7A12',
      city: 'Antsirabe',
      region: 'Vakinankaratra',
      rating: 4.9,
      reviews: 312,
      products: 28,
      since: 2021,
      ring: '#B2DA6A',
      tags: const ['Producteur local', 'Maraîchage'],
      description: 'Maraîchers à Antsirabe : légumes de saison cultivés sans intrant chimique.',
      responseTime: '~2 h',
      distanceKm: 170,
      pickup: true,
      deliveryNote: 'Livre Tana le jeudi');

  static final Shop rucher = _shop('Rucher d’Ambohimanga', 'RA', '#D86F12',
      slug: 'rucher-ambohimanga',
      city: 'Ambohimanga',
      region: 'Analamanga',
      rating: 4.9,
      reviews: 146,
      products: 9,
      since: 2022,
      coverTint: '#FDE6CC',
      coverInk: '#8A3D06',
      ring: '#FBC98F',
      tags: const ['Apiculture', 'Local'],
      description:
          'Apiculteurs depuis trois générations. Nos ruches suivent les floraisons des Hautes Terres : litchi, eucalyptus, niaouli. Miels crus, jamais chauffés.',
      responseTime: '~1 h',
      distanceKm: 22,
      pickup: true,
      deliveryNote: 'Livre Tana en 24 h');

  static final Shop coopAlaotra = _shop('Coop. Lac Alaotra', 'LA', '#7A5A2E',
      city: 'Ambatondrazaka', region: 'Alaotra-Mangoro', rating: 4.7, reviews: 64, products: 14, ring: '#E6DACB');
  static final Shop atelierHazo = _shop('Atelier Hazo', 'AH', '#2F6DA8',
      city: 'Antananarivo',
      region: 'Analamanga',
      rating: 4.8,
      reviews: 57,
      products: 22,
      since: 2023,
      coverTint: '#DCE8D2',
      tags: const ['Cosmétiques', 'Fait main']);
  static final Shop apiSud =
      _shop('Api Sud', 'AS', '#8A5A12', city: 'Fianarantsoa', region: 'Haute Matsiatra', rating: 4.6, reviews: 24, products: 5);
  static final Shop savaVanille = _shop('Sava Vanille', 'SV', '#5B4526', city: 'Sambava', region: 'Sava', rating: 5.0, reviews: 63);
  static final Shop vergerMahitsy = _shop('Verger Mahitsy', 'VM', '#365A10', city: 'Mahitsy', region: 'Analamanga', rating: 4.6, reviews: 41);
  static final Shop vergersImerina = _shop('Vergers d’Imerina', 'VI', '#A43C24', city: 'Ambohidratrimo', region: 'Analamanga', rating: 4.7, reviews: 33);
  static final Shop cafeHautesTerres =
      _shop('Café des Hautes Terres', 'CH', '#5B3A1E', city: 'Manjakandriana', region: 'Analamanga', rating: 4.8, reviews: 74);
  static final Shop cueilleurs =
      _shop('Cueilleurs de Ranomafana', 'CR', '#5B3A2E', city: 'Ranomafana', region: 'Vatovavy', rating: 4.9, reviews: 37);
  static final Shop jardinsBehenjy =
      _shop('Jardins de Behenjy', 'JB', '#B4500A', city: 'Behenjy', region: 'Vakinankaratra', rating: 4.5, reviews: 22);
  static final Shop laiterie =
      _shop('Laiterie des Hautes Terres', 'LH', '#4A5A3A', city: 'Antsirabe', region: 'Vakinankaratra', rating: 4.6, reviews: 52);
  static final Shop coopIvoloina =
      _shop('Coop. Ivoloina', 'CI', '#9A2F45', city: 'Toamasina', region: 'Atsinanana', rating: 4.7, reviews: 205);
  static final Shop vergersManjakandriana =
      _shop('Vergers de Manjakandriana', 'VM', '#A43C24', city: 'Manjakandriana', region: 'Analamanga', rating: 4.5, reviews: 29);
  static final Shop fermeSoa = _shop('Ferme Soa', 'FS', '#5B3A6E', city: 'Ambatolampy', region: 'Vakinankaratra', rating: 4.6, reviews: 15);
  static final Shop cocoNosyBe = _shop('Coco Nosy Be', 'CN', '#5B4526', city: 'Nosy Be', region: 'Diana', rating: 4.7, reviews: 18);

  /// Shop of the signed-in seller (Hery).
  static final Shop jardinDeHery = _shop('Le Jardin de Hery', 'JH', '#4A7A12',
      city: 'Antsirabe',
      region: 'Vakinankaratra',
      rating: 4.8,
      reviews: 57,
      products: 12,
      since: 2024,
      description:
          'Maraîcher à Antsirabe depuis 2019. Légumes de saison cultivés sans intrant chimique, récoltés la veille de la livraison.',
      pickup: true);

  static List<Shop> get shops => [
        fermeTsara,
        rucher,
        coopAlaotra,
        atelierHazo,
        apiSud,
        savaVanille,
        vergerMahitsy,
        vergersImerina,
        cafeHautesTerres,
        cueilleurs,
        jardinsBehenjy,
        laiterie,
        coopIvoloina,
        vergersManjakandriana,
        fermeSoa,
        cocoNosyBe,
        jardinDeHery,
      ];

  // Categories -----------------------------------------------------------------
  static const List<Category> categories = [
    Category(
      id: 'cat-fruits-legumes',
      name: 'Fruits & légumes',
      slug: 'fruits-legumes',
      icon: 'leaf',
      productCount: 248,
      visual: Visual(tint: '#8CC63F', ink: '#1F3608', icon: 'leaf'),
    ),
    Category(
      id: 'cat-laitiers',
      name: 'Produits laitiers',
      shortName: 'Laitiers',
      slug: 'produits-laitiers',
      icon: 'package',
      productCount: 64,
      visual: Visual(tint: '#EEF0EA', ink: '#4A5A3A', icon: 'package'),
    ),
    Category(
      id: 'cat-epicerie',
      name: 'Épicerie',
      slug: 'epicerie',
      icon: 'basket',
      productCount: 182,
      visual: Visual(tint: '#F4F0E6', ink: '#5B4526', icon: 'basket'),
    ),
    Category(
      id: 'cat-miel',
      name: 'Miel & confitures',
      slug: 'miel-confitures',
      icon: 'sprout',
      productCount: 71,
      visual: Visual(tint: '#FDE6CC', ink: '#B4500A', icon: 'sprout'),
    ),
    Category(
      id: 'cat-boissons',
      name: 'Boissons',
      slug: 'boissons',
      icon: 'package',
      productCount: 58,
      visual: Visual(tint: '#F0F6E6', ink: '#365A10', icon: 'package'),
    ),
    Category(
      id: 'cat-cereales',
      name: 'Céréales',
      slug: 'cereales',
      icon: 'basket',
      productCount: 43,
      visual: Visual(tint: '#EFE3D3', ink: '#7A5A2E', icon: 'basket'),
    ),
    Category(
      id: 'cat-artisanat',
      name: 'Produits artisanaux',
      shortName: 'Artisanat',
      slug: 'artisanat',
      icon: 'store',
      productCount: 96,
      visual: Visual(tint: '#FFF4E8', ink: '#8A3D06', icon: 'store'),
    ),
    Category(
      id: 'cat-cosmetiques',
      name: 'Cosmétiques bio',
      shortName: 'Cosmétiques',
      slug: 'cosmetiques',
      icon: 'sprout',
      productCount: 87,
      visual: Visual(tint: '#DCE8D2', ink: '#365A10', icon: 'sprout'),
    ),
    Category(
      id: 'cat-locaux',
      name: 'Produits locaux',
      slug: 'produits-locaux',
      icon: 'pin',
      productCount: 312,
      visual: Visual(tint: '#1F3608', ink: '#8CC63F', icon: 'pin'),
      foreground: '#F4FAE8',
    ),
  ];

  // Products -------------------------------------------------------------------
  static Product _p(
    String name,
    Shop shop,
    int price,
    String unitLabel,
    double rating,
    int reviews,
    String tint,
    String ink, {
    String icon = 'leaf',
    String? photo,
    ProductUnit unit = ProductUnit.piece,
    String category = 'fruits-legumes',
    int? compareAt,
    int stock = 40,
    int threshold = 5,
    String description = '',
    int sold = 0,
    int? distanceKm,
    String? stockUnit,
    int createdDaysAgo = 30,
    Map<String, String> attributes = const {},
    String? slug,
  }) {
    final s = slug ?? slugify(name);
    return Product(
      id: 'prd-$s',
      slug: s,
      name: name,
      description: description,
      price: price,
      compareAtPrice: compareAt,
      unit: unit,
      unitLabel: unitLabel,
      stock: stock,
      lowStockThreshold: threshold,
      originRegion: shop.region,
      ratingAvg: rating,
      ratingCount: reviews,
      soldCount: sold,
      shopId: shop.id,
      shopName: shop.name,
      shopSlug: shop.slug,
      shopCity: shop.city,
      categoryId: 'cat-$category',
      categorySlug: category,
      visual: Visual(tint: tint, ink: ink, icon: icon),
      photoLabel: photo ?? name.split(' ').first,
      distanceKm: distanceKm ?? shop.distanceKm,
      stockUnitLabel: stockUnit,
      createdAt: daysAgo(createdDaysAgo),
      attributes: attributes,
    );
  }

  static final Product tomates = _p('Tomates cœur de bœuf', fermeTsara, 4500, 'kg', 4.8, 126, '#F6E3D6', '#B4500A',
      photo: 'Tomates', unit: ProductUnit.kg, sold: 540, description: 'Grosses tomates charnues, cueillies à maturité.');
  static final Product mielLitchi = _p('Miel de litchi cru', rucher, 18000, 'pot 500 g', 4.9, 88, '#FDE6CC', '#B4500A',
      icon: 'sprout',
      photo: 'Miel',
      unit: ProductUnit.jar,
      category: 'miel-confitures',
      stock: 24,
      sold: 320,
      description:
          'Miel cru, non chauffé et non filtré, issu de ruches installées au cœur des vergers de litchis. Texture crémeuse, notes florales et fruitées. Il cristallise naturellement avec le temps.',
      attributes: const {
        'Poids net': '500 g',
        'Conservation': 'Au sec, à l’abri de la lumière',
        'Récolte': 'Novembre 2025',
      });
  static final Product rizRouge = _p('Riz rouge bio', coopAlaotra, 6000, 'kg', 4.7, 64, '#EFE3D3', '#7A5A2E',
      icon: 'basket', photo: 'Riz', unit: ProductUnit.kg, category: 'cereales');
  static final Product vanille = _p('Vanille Bourbon, gousses', savaVanille, 12000, 'lot de 5', 5.0, 63, '#E9E0D0', '#5B4526',
      photo: 'Vanille', unit: ProductUnit.pack, category: 'epicerie', stock: 3, threshold: 5);
  static final Product avocats = _p('Avocats Hass', vergerMahitsy, 2400, 'kg', 4.6, 41, '#DCEBC6', '#365A10',
      photo: 'Avocats', unit: ProductUnit.kg, compareAt: 3000);
  static final Product confiture = _p('Confiture de goyave de Chine', vergersImerina, 7000, 'pot 350 g', 4.7, 33, '#FBDCD3', '#A43C24',
      icon: 'sprout', photo: 'Confiture', unit: ProductUnit.jar, category: 'miel-confitures', compareAt: 10000);
  static final Product cafe = _p('Café arabica torréfié', cafeHautesTerres, 8100, '250 g', 4.8, 74, '#E6DACB', '#5B3A1E',
      icon: 'package', photo: 'Café', unit: ProductUnit.pack, category: 'boissons', compareAt: 9000);
  static final Product bredes = _p('Brèdes mafana', fermeTsara, 1000, 'botte', 4.7, 19, '#DDEBC9', '#365A10',
      photo: 'Brèdes', unit: ProductUnit.bunch, createdDaysAgo: 2);
  static final Product poivre = _p('Poivre sauvage voatsiperifery', cueilleurs, 15000, '100 g', 4.9, 37, '#E8DDD5', '#5B3A2E',
      icon: 'sprout', photo: 'Poivre', unit: ProductUnit.g, category: 'epicerie', createdDaysAgo: 3);
  static final Product savon = _p('Savon au ravintsara', atelierHazo, 7000, 'pièce', 4.8, 57, '#DCE8D2', '#365A10',
      icon: 'sprout', photo: 'Savon', category: 'cosmetiques', createdDaysAgo: 4);
  static final Product carottes = _p('Carottes nouvelles', jardinsBehenjy, 2000, 'kg', 4.5, 22, '#FCE3CF', '#B4500A',
      photo: 'Carottes', unit: ProductUnit.kg);
  static final Product yaourt = _p('Yaourt fermier nature', laiterie, 2500, 'pot 400 g', 4.6, 52, '#EEF0EA', '#4A5A3A',
      icon: 'package', photo: 'Yaourt', unit: ProductUnit.jar, category: 'produits-laitiers', sold: 610);
  static final Product litchis = _p('Litchis frais', coopIvoloina, 5000, 'kg', 4.7, 205, '#F8DADF', '#9A2F45',
      photo: 'Litchis', unit: ProductUnit.kg, stock: 0);
  static final Product jusGoyave = _p('Jus de goyave pressé', vergersManjakandriana, 5000, 'litre', 4.5, 29, '#FBDCD3', '#A43C24',
      icon: 'package', photo: 'Jus', unit: ProductUnit.l, category: 'boissons', sold: 580);
  static final Product patates = _p('Patates douces violettes', fermeSoa, 1800, 'kg', 4.6, 15, '#E7DDEB', '#5B3A6E',
      photo: 'Patates douces', unit: ProductUnit.kg, stock: 4);
  static final Product huileCoco = _p('Huile de coco vierge', cocoNosyBe, 10800, '50 cl', 4.7, 18, '#F1EEE6', '#5B4526',
      icon: 'package', photo: 'Huile', unit: ProductUnit.l, category: 'epicerie', compareAt: 12000);
  static final Product mielEucalyptus = _p('Miel d’eucalyptus', rucher, 15000, 'pot 500 g', 4.8, 51, '#FCEBD2', '#B4500A',
      icon: 'sprout', photo: 'Miel', unit: ProductUnit.jar, category: 'miel-confitures');
  static final Product mielNiaouli = _p('Miel de niaouli', apiSud, 16000, 'pot 500 g', 4.6, 24, '#F4E3C3', '#8A5A12',
      icon: 'sprout', photo: 'Miel', unit: ProductUnit.jar, category: 'miel-confitures');
  static final Product pollen = _p('Pollen frais', rucher, 9000, '200 g', 4.7, 12, '#F7E7B8', '#8A5A12',
      icon: 'sprout', photo: 'Pollen', unit: ProductUnit.g, category: 'miel-confitures', stock: 2);
  static final Product bougie = _p('Bougie à la cire d’abeille', rucher, 6000, 'pièce', 4.9, 20, '#F4F0E6', '#5B4526',
      icon: 'store', photo: 'Bougie', category: 'artisanat');

  static List<Product> get products => [
        tomates,
        mielLitchi,
        rizRouge,
        vanille,
        avocats,
        confiture,
        cafe,
        bredes,
        poivre,
        savon,
        carottes,
        yaourt,
        litchis,
        jusGoyave,
        patates,
        huileCoco,
        mielEucalyptus,
        mielNiaouli,
        pollen,
        bougie,
      ];

  /// Order of the "Tous les produits" catalogue.
  static List<Product> get catalogue => [
        carottes,
        yaourt,
        litchis,
        jusGoyave,
        patates,
        huileCoco,
        tomates,
        mielLitchi,
        rizRouge,
        vanille,
        avocats,
        confiture,
        cafe,
        bredes,
        poivre,
        savon,
        mielEucalyptus,
        mielNiaouli,
        pollen,
        bougie,
      ];

  static Product? productBySlug(String slug) {
    for (final p in products) {
      if (p.slug == slug || p.id == slug) return p;
    }
    return null;
  }

  static Shop? shopBySlug(String slug) {
    for (final s in shops) {
      if (s.slug == slug || s.id == slug) return s;
    }
    return null;
  }

  static HomeFeed get homeFeed => HomeFeed(
        recommended: [tomates, mielLitchi, rizRouge, vanille],
        promotions: [avocats, confiture, cafe],
        newArrivals: [bredes, poivre, savon],
        popular: [yaourt, jusGoyave, tomates],
        popularShops: [fermeTsara, rucher, coopAlaotra],
        nearbyProducerCount: 12,
      );

  static List<Review> reviewsFor(String productId) => [
        Review(
          id: 'rev-1-$productId',
          productId: productId,
          rating: 5,
          authorName: 'Mialy R.',
          author: const AvatarLook(initials: 'MR', color: '#4A7A12'),
          comment: 'Très parfumé, on sent vraiment le litchi. Pot bien emballé, livré le lendemain.',
          createdAt: daysAgo(3),
        ),
        Review(
          id: 'rev-2-$productId',
          productId: productId,
          rating: 5,
          authorName: 'Toky A.',
          author: const AvatarLook(initials: 'TA', color: '#2F6DA8'),
          comment: 'Je le prends chaque mois. Le retrait au rucher est une belle occasion de rencontrer l’apiculteur.',
          createdAt: daysAgo(14),
        ),
      ];

  static Review shopLatestReview(String shopId) => Review(
        id: 'rev-shop-$shopId',
        rating: 5,
        authorName: 'Fara N.',
        author: const AvatarLook(initials: 'FN', color: '#D86F12'),
        comment: 'Accueil chaleureux au rucher, miel exceptionnel. Commande prête à l’heure.',
        createdAt: daysAgo(5),
      );

  static const List<String> trends = ['Litchis', 'Paniers de saison', 'Vanille', 'Café arabica', 'Avocats'];
}
