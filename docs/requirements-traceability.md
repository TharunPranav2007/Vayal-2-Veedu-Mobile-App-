# Vayal 2 Veedu (FarmDirect) — Requirements Traceability Matrix

> **Document Version:** 1.1.0  
> **Traceability Standard:** ISO/IEC 25010 & IEEE 830 Mapping  

---

## 1. Requirements Mapping Matrix

| Req ID | Project Requirement | Application Feature | Target Screen | Backend API | Database Entity | Status | Verification Test |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **REQ-01** | Multi-Role Authentication | JWT Auth with Passport Strategy | `LoginScreen`, `RegisterScreen` | `POST /auth/login`, `POST /auth/register` | `User`, `RefreshToken` | ✅ Implemented | Unit Test: `JwtStrategy`, `JwtAuthGuard` |
| **REQ-02** | Farmer Produce Management | Add/Edit/Delete Produce with IDOR Check | `AddProductScreen`, `MyProductsScreen` | `POST /products`, `PATCH /products/:id`, `DELETE /products/:id` | `Product`, `ProductImage`, `Category` | ✅ Implemented (Phase 1 Secure) | Security Test 3 & 7 (`security.spec.ts`) |
| **REQ-03** | Farmer Inventory Control | Live Stock Updates & Stock Locking | `FarmerDashboardScreen`, `MyProductsScreen` | `PATCH /products/:id` | `Product` | ✅ Implemented | Unit Test: Deduct stock logic |
| **REQ-04** | Consumer Product Discovery | Search, Category Filter & Sorting | `ConsumerHomeScreen` | `GET /products` | `Product`, `Category` | ✅ Implemented | Widget Test: SearchBar & ChoiceChips |
| **REQ-05** | Persistent Shopping Cart | Cart Item & Subtotal Calculation | `CartScreen` | Local Riverpod + `Cart` DB Entity | `Cart`, `CartItem` | ✅ Implemented | Unit Test: CartNotifier total calculation |
| **REQ-06** | Checkout & Stock Locking | Order Placement & Consumer Binding | `CheckoutScreen` | `POST /orders` | `Order`, `OrderItem`, `Payment` | ✅ Implemented (Phase 1 Secure) | Security Test: Consumer binding & stock locking |
| **REQ-07** | Real-Time Order Tracking | Live Status Timeline & IDOR View | `OrderTrackingScreen` | `GET /orders/:id` | `Order`, `OrderStatusHistory` | ✅ Implemented (Phase 1 Secure) | Security Test 4: Order IDOR protection |
| **REQ-08** | Delivery Partner Dispatch | View & Update Assigned Deliveries | `DeliveryDashboardScreen` | `GET /deliveries/my-deliveries`, `PATCH /deliveries/:id/status` | `Delivery`, `DeliveryProfile` | ✅ Implemented (Phase 1 Secure) | Security Test 5: Delivery IDOR protection |
| **REQ-09** | Admin System Oversight | Platform Metrics & Moderation | `AdminDashboardScreen` | Admin endpoints | `User`, `Order`, `Product` | ✅ Implemented (Phase 1 Secure) | Security Test 6: Admin RBAC protection |
| **REQ-10** | Role-Based Access Control | Strict Route & API Security Guards | NestJS Global Guards | `JwtAuthGuard`, `RolesGuard` | `User.role` | ✅ Implemented (Phase 1 Secure) | Security Test 1 & 2: `security.spec.ts` |

---

## 2. Requirement Verification Sign-off

- **Phase 1 Security & Authorization Sign-off**: Global JWT authentication (`JwtAuthGuard`), server-side Role-Based Access Control (`RolesGuard`), and resource ownership IDOR verification are fully implemented and verified with 100% pass rate across 7 Jest security test cases.
