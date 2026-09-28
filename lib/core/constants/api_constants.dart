class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; // Android Emulator loopback
  static const String localBaseUrl = 'http://localhost:3000/api/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Product Endpoints
  static const String products = '/products';
  static const String categories = '/categories';

  // Farmer Endpoints
  static const String farmerProfile = '/farmers/me';
  static const String farmerProducts = '/farmers/me/products';
  static const String farmerOrders = '/farmers/me/orders';
  static const String farmerSales = '/farmers/me/sales';

  // Cart & Checkout
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  // Order Endpoints
  static const String orders = '/orders';

  // Delivery Endpoints
  static const String deliveryAssignments = '/delivery/assignments';

  // Wishlist & Reviews
  static const String wishlist = '/wishlist';
  static const String reviews = '/reviews';

  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
}

class StorageKeys {
  static const String accessToken = 'jwt_access_token';
  static const String refreshToken = 'jwt_refresh_token';
  static const String userRole = 'user_role';
  static const String userData = 'user_data';
}
