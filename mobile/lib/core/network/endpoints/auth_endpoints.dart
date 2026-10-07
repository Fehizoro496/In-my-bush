/// Authentication (`/auth`).
abstract class AuthEndpoints {
  /// Common prefix of every authentication call.
  static const prefix = '/auth/';

  static const login = '/auth/login';
  static const register = '/auth/register';

  /// Sign-up, step 1: texts a verification code to the phone number.
  static const registerOtp = '/auth/register/otp';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
}
