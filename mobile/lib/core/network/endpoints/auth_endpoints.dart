/// Authentication (`/auth`).
abstract class AuthEndpoints {
  /// Common prefix of every authentication call.
  static const prefix = '/auth/';

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const otpRequest = '/auth/otp/request';
  static const otpVerify = '/auth/otp/verify';
}
