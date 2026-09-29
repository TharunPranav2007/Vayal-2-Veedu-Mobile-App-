# Vayal 2 Veedu (FarmDirect) — Test Coverage Gap Analysis

> **Document Version:** 1.0.0  
> **Evaluation:** Phase 0.5 Independent Verification  

---

## 1. Executive Summary

The current test suite consists of **7 unit/widget tests** (`test/unit_test.dart` and `test/widget_test.dart`), all of which pass (`00:01 +7: All tests passed!`). However, these tests focus primarily on local Riverpod state notifiers in isolation.

To ensure production quality, comprehensive backend tests (NestJS/Supertest), network failure tests, security authorization tests, and end-to-end integration tests must be established.

---

## 2. Test Coverage Gap Matrix

| Subsystem / Feature | Existing Test | Missing Test | Priority |
| :--- | :--- | :--- | :---: |
| **Products Riverpod Store** | `ProductsNotifier Unit Tests` (`unit_test.dart`) | Dio HTTP client sync test; empty list retry state test | **MEDIUM** |
| **Cart & GST Calculation** | `CartNotifier Unit Tests` (`unit_test.dart`) | Cart item max stock limit test; out-of-stock item addition test | **HIGH** |
| **Order Status Transitions** | `OrdersNotifier Unit Tests` (`unit_test.dart`) | Invalid status jump rejection test (`DELIVERED` ➔ `PLACED`) | **CRITICAL** |
| **App Shell Rendering** | `Vayal2VeeduApp renders successfully` (`widget_test.dart`) | Screen-specific widget tests (`LoginScreen`, `CheckoutScreen`) | **MEDIUM** |
| **JWT Authentication** | None | AuthController integration test; invalid password rejection test | **CRITICAL** |
| **Role-Based Authorization Guard** | None | NestJS `RolesGuard` test; unauthorized endpoint access test | **CRITICAL** |
| **Resource Ownership (IDOR)** | None | Farmer editing another farmer's product test; Consumer modifying another's order test | **CRITICAL** |
| **Database Transactions & Stock Locking** | None | Concurrent order placement stock lock test (`prisma.$transaction`) | **HIGH** |
| **Network Interruption & Retry** | None | Offline/Timeout Dio interceptor failure recovery test | **HIGH** |
| **WebSocket Realtime Pipeline** | None | Socket.IO Order Status Event dispatch test | **MEDIUM** |
| **Product Image Upload** | None | File size & MIME type upload validation test | **LOW** |
| **Consumer Review Verification** | None | Review submission for unpurchased item rejection test | **MEDIUM** |

---

## 3. Priority Recommendations for Phase 1 & Beyond

1. **CRITICAL Priority:** Write NestJS integration tests (`Supertest`) to verify `@UseGuards(JwtAuthGuard, RolesGuard)` and resource ownership checks on all API endpoints.
2. **HIGH Priority:** Implement database transaction concurrency tests for stock locking (`OrdersService.createOrder`).
3. **HIGH Priority:** Add Riverpod & Dio network failure recovery widget tests in Flutter.
