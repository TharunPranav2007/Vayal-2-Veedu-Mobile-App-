# FarmDirect (Vayal 2 Veedu) — System & Software Architecture

## 1. System Context & Overview

FarmDirect is built on a decoupled, client-server architecture. The mobile front-end is written in **Flutter**, serving all four roles (`FARMER`, `CONSUMER`, `DELIVERY_PARTNER`, `ADMIN`) with dynamic role-based UI views. The backend is built with **NestJS** (TypeScript) running on top of **Node.js**, with **Prisma ORM** managing a **PostgreSQL** relational database.

```
+-----------------------------------------------------------------------+
|                            FLUTTER CLIENT                             |
|  (Consumer App / Farmer App / Delivery App / Admin App in 1 Binary)   |
+-----------------------------------------------------------------------+
        |                      |                     |
        | REST (Dio)           | WebSockets (WSS)    | Push (FCM)
        v                      v                     v
+------------------+   +------------------+   +---------------------+
| NestJS REST API  |   | NestJS WS Gateway|   |  Firebase Cloud     |
|   (/api/v1/)     |   |   (Socket.io)    |   |     Messaging       |
+------------------+   +------------------+   +---------------------+
        |                      |                     |
        +----------+-----------+                     |
                   |                                 |
                   v                                 |
+------------------------------------+               |
|            Prisma ORM              |               |
+------------------------------------+               |
                   |                                 |
                   v                                 v
+------------------------------------+    +---------------------+
|        PostgreSQL Database         |    | FCM Mobile Devices  |
+------------------------------------+    +---------------------+
```

---

## 2. End-to-End Data Flow Architecture

### 2.1 Unidirectional Mobile Data Flow (Flutter + Riverpod)

```
[User Touch / Event]
        │
        ▼
[UI Layer (Screen / Widget)]
        │
        ▼
[Riverpod AsyncNotifier Controller / ViewModel]
        │
        ▼
[Repository Contract & Implementation]
        │
        ▼
[Remote Data Source (Dio HTTP Client / Socket Client)]
        │
        ▼ (HTTPS REST / WSS)
[NestJS Controller (DTO Validation & Route Guards)]
        │
        ▼
[NestJS Service (Business Logic & Transactions)]
        │
        ▼
[Prisma Client (ORM)]
        │
        ▼
[PostgreSQL Database]
```

---

## 3. Real-Time Architecture (WebSockets + REST Fallback)

WebSockets are utilized exclusively for event-driven live state updates. Normal CRUD requests (catalog browsing, profile edits, product creation) remain standard HTTP REST endpoints.

### 3.1 WebSocket Event Flow
1. **Connection & Auth:** Flutter client connects to NestJS WebSocket Gateway at `/ws/orders` carrying JWT token in query/header. Gateway authenticates connection using `WSS Guard`.
2. **Room Subscription:** Clients automatically join role/order specific rooms:
   - Consumer joins room: `consumer:{consumerId}` & `order:{orderId}`
   - Farmer joins room: `farmer:{farmerId}`
   - Delivery Partner joins room: `delivery:{deliveryPartnerId}`
   - Admin joins room: `admin:live_orders`
3. **Event Dispatch:**
   - `order.created`: Sent to Farmer.
   - `order.status.updated`: Sent to Consumer, Farmer & Admin.
   - `delivery.assigned`: Sent to Delivery Partner.
   - `delivery.location.updated`: Sent to Consumer for live delivery tracking.
4. **Resilience & Fallback:** If WebSocket disconnects or fails, Flutter Riverpod controllers fallback gracefully to periodic REST polling (`GET /api/v1/orders/:id/tracking`) or manual pull-to-refresh without crashing or blocking the app.

---

## 4. Notification Architecture (Firebase Cloud Messaging)

```
[NestJS Event Trigger] (e.g., Order Status -> READY_FOR_PICKUP)
        │
        ▼
[Notifications Service]
        │
        ├── 1. Persist notification in `notifications` DB table
        └── 2. Retrieve recipient FCM tokens from `device_tokens` table
        │
        ▼
[Firebase Admin SDK]
        │
        ▼
[Firebase Cloud Messaging (FCM)]
        │
        ▼
[Flutter App Client] (Foreground Banner / Background Notification Tray)
```

---

## 5. Security Architecture

1. **Authentication:**
   - **JWT Tokens:** Short-lived Access Tokens (15m expiration) signed with `JWT_SECRET` + Refresh Token Rotation (7d expiration) stored in secure database table `refresh_tokens`.
   - **Password Hashing:** **Argon2id** (or **bcrypt** fallback with minimum 12 rounds).
   - **Token Storage:** Flutter client persists JWT securely using `flutter_secure_storage` (Android EncryptedSharedPreferences / Keychain).
2. **Authorization Guards:**
   - **Role-Based Access Control (RBAC):** NestJS `@Roles(Role.FARMER, Role.ADMIN)` custom decorators backed by `RolesGuard`.
   - **Resource Ownership Guards:** Verification that `req.user.id` owns the target resource (e.g., Farmer owns product ID, Consumer owns order ID).
3. **Network & System Protection:**
   - **Helmet:** Enables HTTP security headers (CSP, HSTS, X-Frame-Options, X-Content-Type-Options).
   - **CORS:** Configured with explicit origin whitelist.
   - **Rate Limiting:** `nestjs/throttler` enforces rate limits (e.g., 100 requests / 60 seconds per IP, stricter limits on auth endpoints).
   - **Input Validation:** Global `ValidationPipe` with `class-validator` and `class-transformer` enforcing strict DTO constraints and stripping unknown payload properties (`whitelist: true`).

---

## 6. Technology Justification Matrix

| Technology | Selection | Alternative | Rationale for Selection |
| :--- | :--- | :--- | :--- |
| **Mobile Framework** | Flutter (Material 3) | React Native | Single codebase for Android/iOS with native performance, rich Material 3 design, seamless graphics rendering. |
| **State Management** | Riverpod 2.x | Provider / Bloc | Compile-safe, no BuildContext dependencies, declarative AsyncNotifier, easy provider overrides for testing. |
| **Navigation** | go_router | Navigator 1.0 | Declarative routing, seamless deep-linking, direct integration with Riverpod for role-based route redirects. |
| **Backend Framework**| NestJS (TypeScript) | Plain Express | Enterprise-grade modular architecture, native dependency injection, decorators, built-in validation & guards. |
| **Database ORM** | Prisma ORM | TypeORM | Type-safe query builder, declarative schema definitions, automated type generation, robust migration toolchain. |
| **Database** | PostgreSQL | MongoDB | Strict relational integrity, native transaction support, foreign key constraints, robust indexing for marketplace data. |
| **Real-time Engine** | Socket.IO (Nest Gateway) | Raw WebSockets | Automatic reconnection, room/channel abstraction, fallback transports, event handling. |
