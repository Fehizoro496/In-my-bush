import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Every icon used by the app, mapped from the mockups' `Icon` component
/// names (`home`, `msg`, `pin`…) to Lucide. Keep all Lucide references in
/// this file so a package upgrade only touches one place.
///
/// Filled variants (`star`, `heartF`) use Material rounded glyphs because
/// Lucide is stroke-only.
abstract class AppIcons {
  static const IconData home = LucideIcons.house;
  static const IconData search = LucideIcons.search;
  static const IconData compass = LucideIcons.compass;
  static const IconData plus = LucideIcons.plus;
  static const IconData minus = LucideIcons.minus;
  static const IconData cart = LucideIcons.shoppingCart;
  static const IconData user = LucideIcons.user;
  static const IconData heart = LucideIcons.heart;
  static const IconData heartFilled = Icons.favorite_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData starOutline = LucideIcons.star;
  static const IconData pin = LucideIcons.mapPin;
  static const IconData sliders = LucideIcons.slidersHorizontal;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData chevronDown = LucideIcons.chevronDown;
  static const IconData chevronUp = LucideIcons.chevronUp;
  static const IconData arrowLeft = LucideIcons.arrowLeft;
  static const IconData arrowRight = LucideIcons.arrowRight;
  static const IconData check = LucideIcons.check;
  static const IconData close = LucideIcons.x;
  static const IconData bell = LucideIcons.bell;
  static const IconData message = LucideIcons.messageSquare;
  static const IconData truck = LucideIcons.truck;
  static const IconData leaf = LucideIcons.leaf;
  static const IconData sprout = LucideIcons.sprout;
  static const IconData shield = LucideIcons.shieldCheck;
  static const IconData package = LucideIcons.package;
  static const IconData chart = LucideIcons.chartColumn;
  static const IconData trend = LucideIcons.trendingUp;
  static const IconData settings = LucideIcons.settings;
  static const IconData users = LucideIcons.users;
  static const IconData store = LucideIcons.store;
  static const IconData tag = LucideIcons.tag;
  static const IconData flag = LucideIcons.flag;
  static const IconData award = LucideIcons.award;
  static const IconData card = LucideIcons.creditCard;
  static const IconData wallet = LucideIcons.wallet;
  static const IconData trash = LucideIcons.trash;
  static const IconData edit = LucideIcons.pencil;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
  static const IconData camera = LucideIcons.camera;
  static const IconData image = LucideIcons.image;
  static const IconData more = LucideIcons.ellipsis;
  static const IconData grid = LucideIcons.layoutGrid;
  static const IconData list = LucideIcons.list;
  static const IconData clock = LucideIcons.clock;
  static const IconData alert = LucideIcons.circleAlert;
  static const IconData wifiOff = LucideIcons.wifiOff;
  static const IconData logout = LucideIcons.logOut;
  static const IconData receipt = LucideIcons.receipt;
  static const IconData layers = LucideIcons.layers;
  static const IconData upload = LucideIcons.upload;
  static const IconData download = LucideIcons.download;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData filter = LucideIcons.slidersHorizontal;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData percent = LucideIcons.percent;
  static const IconData basket = LucideIcons.shoppingBasket;
  static const IconData mail = LucideIcons.mail;
  static const IconData lock = LucideIcons.lock;
  static const IconData ban = LucideIcons.ban;
  static const IconData info = LucideIcons.info;
  static const IconData checkCircle = LucideIcons.circleCheck;
  static const IconData menu = LucideIcons.menu;
  static const IconData share = LucideIcons.share2;
  static const IconData send = LucideIcons.send;

  static const Map<String, IconData> _byKey = {
    'home': home,
    'search': search,
    'compass': compass,
    'plus': plus,
    'minus': minus,
    'cart': cart,
    'user': user,
    'heart': heart,
    'heartF': heartFilled,
    'star': star,
    'starO': starOutline,
    'pin': pin,
    'sliders': sliders,
    'chevR': chevronRight,
    'chevL': chevronLeft,
    'chevD': chevronDown,
    'chevU': chevronUp,
    'arrowL': arrowLeft,
    'arrowR': arrowRight,
    'check': check,
    'x': close,
    'bell': bell,
    'msg': message,
    'truck': truck,
    'leaf': leaf,
    'sprout': sprout,
    'shield': shield,
    'package': package,
    'chart': chart,
    'trend': trend,
    'settings': settings,
    'users': users,
    'store': store,
    'tag': tag,
    'flag': flag,
    'award': award,
    'card': card,
    'wallet': wallet,
    'trash': trash,
    'edit': edit,
    'eye': eye,
    'camera': camera,
    'image': image,
    'more': more,
    'grid': grid,
    'list': list,
    'clock': clock,
    'alert': alert,
    'wifiOff': wifiOff,
    'logout': logout,
    'receipt': receipt,
    'layers': layers,
    'upload': upload,
    'download': download,
    'refresh': refresh,
    'filter': filter,
    'calendar': calendar,
    'percent': percent,
    'basket': basket,
    'mail': mail,
    'lock': lock,
    'ban': ban,
    'info': info,
    'checkCircle': checkCircle,
    'menu': menu,
    'share': share,
  };

  /// Resolves a mockup / API icon key (`"leaf"`, `"basket"`…).
  static IconData byKey(String? key) => _byKey[key] ?? leaf;
}
