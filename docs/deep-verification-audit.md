# Vayal 2 Veedu (FarmDirect) — Deep Verification Audit & Technical Gap Analysis

> **Audit Type:** Phase 0.5 Independent Verification & Code Inspection  
> **Evaluator:** Principal Mobile Application Engineer & Software Architect (25-30+ Years Experience)  
> **Date:** September 2026  
> **Status:** Fact-Based Deep Audit Complete — Halting for Phase 1 Guidance  

---

## 1. Executive Summary & Verification Methodology

This Phase 0.5 Deep Verification Audit independent of claims evaluates the exact source code, backend controllers, Prisma database schema, state management implementations, and network layers of **Vayal 2 Veedu (FarmDirect)**. 

### Core Architectural Audit Finding:
While the Flutter mobile application presents a **fully functional, interactive Material 3 UI** operating on **Riverpod reactive state management**, the connection between the Flutter frontend and the NestJS PostgreSQL backend is currently **hybrid / decoupled**. Frontend actions operate via local Riverpod state notifiers rather than executing live HTTP REST calls to NestJS endpoints (`/api/v1`). Furthermore, several core backend security guards and order state machine transition rules require strict enforcement before production deployment.

---

## 2. Feature Verification Classification Matrix

| Feature / Subsystem | Phase 0 Claim | Phase 0.5 Fact-Based Verification | Classification | Detailed Gap Description |
| :--- | :--- | :--- | :---: | :--- |
| **Multi-Role UI Screens** | Working | Evaluated: `Farmer`, `Consumer`, `Delivery`, `Admin` screens render correctly in Material 3. | **VERIFIED WORKING** | Visual components and responsive layouts operate cleanly. |
| **Riverpod State Management** | Working | Evaluated: `productsProvider`, `cartProvider`, `ordersProvider` manage local reactive state. | **VERIFIED WORKING** | Local state updates immediately across screens in-memory. |
| **Frontend-Backend API Link** | Working | Evaluated: `DioClient` configured, but Flutter screens do not send HTTP calls to NestJS `/api/v1`. | **DECOUPLED / MOCKED** | App operates in isolated local mode; network REST integration missing. |
| **JWT Session Restoration** | Working | Evaluated: `authProvider` manages in-memory `AuthState`, but tokens are not auto-restored from `flutter_secure_storage` on app cold boot. | **PARTIALLY WORKING** | Session lost upon cold restart. |
| **Backend Authentication** | Working | Evaluated: `auth.service.ts` hashes passwords with `bcryptjs` and returns JWT access/refresh tokens. | **VERIFIED WORKING** | NestJS Auth endpoints (`POST /auth/register`, `POST /auth/login`) operate cleanly. |
| **Backend Authorization (RBAC)** | Working | Evaluated: `@UseGuards(JwtAuthGuard, RolesGuard)` created, but NOT applied to `ProductsController` & `OrdersController`. | **BROKEN / SECURITY RISK** | Any HTTP client can invoke `/api/v1/orders` or `/api/v1/products` without token validation. |
| **Order State Machine** | Working | Evaluated: Status string updated in DB/Riverpod, but NestJS `orders.service.ts` lacks transition matrix checks. | **PARTIALLY WORKING** | Invalid transitions (e.g. `DELIVERED` ➔ `PLACED`) are not blocked server-side. |
| **Database Transactions & Stock Locking** | Working | Evaluated: `orders.service.ts` uses `prisma.$transaction` with `decrement` stock updates. | **VERIFIED WORKING (Backend)** | Atomic stock deduction implemented on NestJS backend. |
| **Product Image Upload Pipeline** | Working | Evaluated: `AddProductScreen` camera button displays snackbar without uploading image binary/file. | **MOCKED** | Image selection & S3/local file storage pipeline missing. |
| **Payment Workflow** | Working | Evaluated: Cash on Delivery or Mock Sandbox payment selection dialog in UI. | **MOCKED** | UI simulation only; gateway callback verification missing. |
| **Consumer Wishlist** | Working | Evaluated: `Wishlist` table exists in `schema.prisma`, but no Flutter wishlist screen or provider exists. | **MISSING** | UI screen & Riverpod provider not built. |
| **Reviews & Ratings** | Working | Evaluated: `Review` table exists in `schema.prisma`, but no review form or submission workflow exists in Flutter. | **MISSING** | Review submission UI & API missing. |
| **Realtime Push Notifications** | Working | Evaluated: Socket.IO Gateway in NestJS exists, but Flutter app lacks WebSocket client package & listener. | **PARTIALLY WORKING** | Gateway built; Flutter WebSocket listener missing. |

---

## 3. Deep Architectural & Security Gaps

### A. Security & Resource Ownership Vulnerabilities (CRITICAL)
1. **Unprotected Backend Controllers:** `backend/src/products/products.controller.ts` and `backend/src/orders/orders.controller.ts` do not decorate endpoints with `@UseGuards(JwtAuthGuard, RolesGuard)`.
2. **Missing IDOR / Ownership Checks:** In `orders.service.ts`, `updateStatus` does not verify if the requesting user is the assigned Farmer or Delivery Partner for that specific order.

### B. Data Integrity & Order State Machine Gaps (HIGH)
1. **Unchecked State Transitions:** In `OrdersService.updateStatus`, any `OrderStatus` enum can be passed. Invalid transitions (e.g., `DELIVERED` ➔ `PLACED` or `CANCELLED` after `DELIVERED`) are accepted by PostgreSQL.
2. **Stock Verification Race Conditions:** Stock deduction is performed in a transaction, but Flutter client doesn't handle HTTP 400 `Insufficient stock` exceptions gracefully when another user buys stock concurrently.

### C. Session & Network Resilience Gaps (HIGH)
1. **Session Volatility:** When the Flutter app is closed and reopened, Riverpod `authProvider` resets to unauthenticated state (`AuthState()`), requiring the user to re-login.
2. **Offline Network Handling:** No `Connectivity` check or Dio error interceptor to present retry UI options when the backend server is unreachable.

---

## 4. Gap-Based 12-Phase Implementation Roadmap

Based strictly on the verified facts above, here is the new prioritized roadmap:

- **PHASE 1 — Critical Security & Authorization:** Apply `@UseGuards(JwtAuthGuard, RolesGuard)` to all NestJS endpoints; implement resource ownership checks (`IDOR` protection).
- **PHASE 2 — Frontend-Backend Integration:** Connect Flutter `DioClient` to NestJS Auth (`login`, `register`), Products (`GET`, `POST`), and Orders (`POST`, `PATCH`).
- **PHASE 3 — Persistent Session & Auto-Login:** Store JWT tokens in `flutter_secure_storage`; auto-restore session on app startup in `authProvider`.
- **PHASE 4 — Controlled Order State Machine:** Implement a strict state transition matrix in `orders.service.ts` to reject invalid status jumps.
- **PHASE 5 — Farmer Module Backend Sync:** Wire `AddProductScreen` and `MyProductsScreen` to execute live HTTP operations against PostgreSQL.
- **PHASE 6 — Consumer Marketplace & Cart Persistence:** Connect `ConsumerHomeScreen` and `CheckoutScreen` to live backend APIs with transactional stock locking.
- **PHASE 7 — Delivery Partner Assignment & Authorization:** Restrict delivery job access to verified delivery profiles and assigned order IDs.
- **PHASE 8 — WebSocket Realtime Pipeline:** Add `socket_io_client` to Flutter app; listen for order status events to update tracking UI automatically.
- **PHASE 9 — Product Image Storage Pipeline:** Implement multi-part file upload for product photos.
- **PHASE 10 — Consumer Wishlist & Review System:** Build Wishlist UI screen and Review submission form with purchase verification.
- **PHASE 11 — Admin Moderation & User Management:** Add Admin API endpoints for user verification and product moderation.
- **PHASE 12 — Automated Testing & E2E Verification:** Expand Unit, Widget, Integration, and Failure-Mode tests across frontend and backend.
