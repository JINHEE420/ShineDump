part of 'app_router.dart';

enum RouteAuthority {
  unauthenticated,
  guest,
  user,
  admin;

  // This is helpful when handling different authentication roles (guest, user, admin, etc..).
  static RouteAuthority fromAuthState(Option<User> authState) {
    if (authState.isSome()) {
      return RouteAuthority.user;
    }
    return RouteAuthority.unauthenticated;
  }
}
