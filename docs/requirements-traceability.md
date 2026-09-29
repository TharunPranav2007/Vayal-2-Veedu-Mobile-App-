# Vayal 2 Veedu (FarmDirect) — Requirements Traceability Matrix

> **Document Version:** 1.0.0  
> **Traceability Standard:** ISO/IEC 25010 & IEEE 830 Mapping  

---

## 1. Requirements Mapping Matrix

| Req ID | Project Requirement | Application Feature | Target Screen | Backend API | Database Entity | Status | Verification Test |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **REQ-01** | Multi-Role Authentication | JWT Auth with Role Guards | `LoginScreen`, `RegisterScreen`, `RoleSelectionScreen` | `POST /api/v1/auth/login`, `POST /api/v1/auth/register` | `User`, `RefreshToken` | ✅ Implemented | Unit Test: AuthNotifier; E2E: Login flow |
| **REQ-02** | Farmer Produce Management | Add/Edit/Delete Produce | `AddProductScreen`, `MyProductsScreen` | `POST /api/v1/products`, `DELETE /api/v1/products/:id` | `Product`, `ProductImage`, `Category` | ✅ Implemented | Widget Test: AddProductForm; Integration Test |
| **REQ-03** | Farmer Inventory Control | Live Stock Updates & Alert | `FarmerDashboardScreen`, `MyProductsScreen` | `PATCH /api/v1/products/:id` | `Product` | ✅ Implemented | Unit Test: Deduct stock logic |
| **REQ-04** | Consumer Product Discovery | Search, Category Filter & Sorting | `ConsumerHomeScreen` | `GET /api/v1/products` | `Product`, `Category` | ✅ Implemented | Widget Test: SearchBar & ChoiceChips |
| **REQ-05** | Persistent Shopping Cart | Cart Item & Subtotal/GST Calculation | `CartScreen` | Local Riverpod + `Cart` DB Entity | `Cart`, `CartItem` | ✅ Implemented | Unit Test: CartNotifier total calculation |
| **REQ-06** | Checkout & Stock Locking | Order Placement & Stock Locking | `CheckoutScreen` | `POST /api/v1/orders` | `Order`, `OrderItem`, `Payment` | ✅ Implemented | Widget Test: Checkout Form; DB Transaction Test |
| **REQ-07** | Real-Time Order Tracking | Live Status Timeline (`PLACED` ➔ `DELIVERED`) | `OrderTrackingScreen` | `GET /api/v1/orders/:id`, WebSocket Gateway | `Order`, `OrderStatusHistory` | ✅ Implemented | Widget Test: OrderTracking Timeline |
| **REQ-08** | Delivery Partner Dispatch | View & Accept Delivery Jobs | `DeliveryDashboardScreen` | `GET /api/v1/orders`, `PATCH /api/v1/orders/:id/status` | `Delivery`, `DeliveryProfile` | ✅ Implemented | Integration Test: Delivery Partner Status update |
| **REQ-09** | Admin System Oversight | Platform Metrics & Moderation | `AdminDashboardScreen` | `GET /api/v1/admin/metrics` | `User`, `Order`, `Product` | ✅ Implemented | Widget Test: Admin Metric Cards |
| **REQ-10** | Role-Based Access Control | Strict Route & API Security | `AppRouter` Guards | `JwtAuthGuard`, `RolesGuard` | `User.role` | ✅ Implemented | Unit Test: RolesGuard authorization check |

---

## 2. Requirement Verification Sign-off

All 10 primary functional requirements specified in the project scope have been successfully mapped to concrete code implementation artifacts across the Mobile Client, Backend Controllers, and PostgreSQL Database tables.
