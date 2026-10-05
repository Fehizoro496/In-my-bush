/// Profile, addresses and payout methods of the signed-in user (`/me`).
abstract class AccountEndpoints {
  static const me = '/me';
  static const addresses = '/me/addresses';
  static const payoutMethods = '/me/payout-methods';

  static String address(String id) => '/me/addresses/$id';
}
