# Vayal 2 Veedu (FarmDirect) — Security & Authorization Architecture

## Executive Overview
This document defines the formal security, authentication, and authorization architecture implemented in the NestJS backend for Vayal 2 Veedu (FarmDirect). The application enforces server-side Role-Based Access Control (RBAC) and explicit Insecure Direct Object Reference (IDOR) resource ownership checks across all endpoints.

---

## 1. Authentication Architecture & JWT Handling

### 1.1 Authentication Tokens
- **Strategy**: Passport JWT Strategy (`JwtStrategy` extending `@nestjs/passport`).
- **Access Tokens**: Short-lived (15 minutes expiry) signed JWTs.
- **Refresh Tokens**: Long-lived (7 days expiry) signed JWTs stored in PostgreSQL (`RefreshToken` table).
- **Token Payload**:
  ```json
  {
    "sub": "<user_uuid>",
    "email": "user@example.com",
    "role": "FARMER" | "CONSUMER" | "DELIVERY_PARTNER" | "ADMIN",
    "iat": 1759170000,
    "exp": 1759170900
  }
  ```

### 1.2 Authentication Guard Pipeline
- **Global Guard**: `JwtAuthGuard` registered as `APP_GUARD` in `AppModule`.
- **Public Bypassing**: Custom `@Public()` decorator sets metadata `isPublic: true`. Public endpoints bypass JWT extraction.
- **Unauthenticated Handling**: Any request to a protected endpoint lacking a valid `Authorization: Bearer <token>` header immediately yields `HTTP 401 Unauthorized`.

---

## 2. Role Model & Role-Based Access Control (RBAC)

### 2.1 Server-Side Roles
Defined in Prisma Schema (`enum Role`):
1. `FARMER`: Local agriculture produce producers.
2. `CONSUMER`: Direct farm-to-door end customers.
3. `DELIVERY_PARTNER`: Independent logistics & delivery agents.
4. `ADMIN`: System operators & administrators.

### 2.2 Roles Enforcement
- Custom `@Roles(...)` decorator specifies allowed roles per route.
- `RolesGuard` inspects route metadata via `Reflector`.
- Requests from authenticated users whose `user.role` is not explicitly listed in `@Roles(...)` immediately yield `HTTP 403 Forbidden`.

---

## 3. Resource Ownership & IDOR Protection Model

A valid JWT token and matching role do NOT automatically permit resource access. Server-side ownership verification must be performed on every state mutation or private query.

### 3.1 Products Domain
- **Public Reading**: `GET /products`, `GET /products/:id` are public.
- **Product Creation (`POST /products`)**: Allowed for `FARMER` and `ADMIN`. Binds product automatically to `user.farmerProfileId`.
- **Product Modification & Deletion (`PATCH /products/:id`, `DELETE /products/:id`)**:
  - Checks `product.farmer.userId === user.id` OR `user.role === 'ADMIN'`.
  - Non-owner Farmers trying to edit or delete another Farmer's product receive `HTTP 403 Forbidden`.

### 3.2 Orders Domain
- **Order Placement (`POST /orders`)**: Allowed for `CONSUMER` and `ADMIN`. Uses authenticated `user.consumerProfileId`. Ignores/overrides client-supplied consumer IDs.
- **Order List Query (`GET /orders`)**: Scoped automatically to the authenticated profile:
  - `CONSUMER`: `where.consumerId = user.consumerProfileId`
  - `FARMER`: `where.farmerId = user.farmerProfileId`
  - `DELIVERY_PARTNER`: `where.delivery.deliveryPartnerId = user.deliveryProfileId`
  - `ADMIN`: Unrestricted
- **Order Details (`GET /orders/:id`)**:
  - Verified against relationship graph: `order.consumer.userId === user.id || order.farmer.userId === user.id || order.delivery.deliveryPartner.userId === user.id || user.role === 'ADMIN'`.
  - Unrelated users receive `HTTP 403 Forbidden`.

### 3.3 Order Status State Machine Security
Order state transitions (`PATCH /orders/:id/status`) are validated per role:
- **`FARMER`** (must own order):
  - `PLACED` → `CONFIRMED` or `CANCELLED`
  - `CONFIRMED` → `PREPARING`
  - `PREPARING` → `READY_FOR_PICKUP`
- **`DELIVERY_PARTNER`** (must be assigned to delivery):
  - `READY_FOR_PICKUP` → `PICKED_UP`
  - `PICKED_UP` → `OUT_FOR_DELIVERY`
  - `OUT_FOR_DELIVERY` → `DELIVERED`
- **`CONSUMER`** (must own order):
  - `PLACED` → `CANCELLED` (only while current state is `PLACED`)
- **`ADMIN`**:
  - Administrative override.

### 3.4 Deliveries Domain
- **Assigned Deliveries (`GET /deliveries/my-deliveries`)**: Returns deliveries assigned to `user.deliveryProfileId`.
- **Delivery Status Update (`PATCH /deliveries/:id/status`)**: Verifies `delivery.deliveryPartner.userId === user.id` or `user.role === 'ADMIN'`.

---

## 4. Endpoint Authorization & Visibility Matrix

| Endpoint | HTTP Method | Guard / Role | Public / Protected | Ownership Requirement |
| :--- | :--- | :--- | :--- | :--- |
| `/auth/register` | POST | `@Public()` | Public | N/A |
| `/auth/login` | POST | `@Public()` | Public | N/A |
| `/products` | GET | `@Public()` | Public | N/A |
| `/products/:id` | GET | `@Public()` | Public | N/A |
| `/products` | POST | `@Roles(FARMER, ADMIN)` | Protected | Bound to caller's `farmerProfileId` |
| `/products/:id` | PATCH | `@Roles(FARMER, ADMIN)` | Protected | `product.farmer.userId === user.id` |
| `/products/:id` | DELETE | `@Roles(FARMER, ADMIN)` | Protected | `product.farmer.userId === user.id` |
| `/orders` | POST | `@Roles(CONSUMER, ADMIN)` | Protected | Bound to caller's `consumerProfileId` |
| `/orders` | GET | `@Roles(ALL)` | Protected | Scoped to user profile |
| `/orders/:id` | GET | `@Roles(ALL)` | Protected | Caller must be order participant |
| `/orders/:id/status` | PATCH | `@Roles(FARMER, DP, CONSUMER, ADMIN)` | Protected | Participant & role-allowed state transition |
| `/deliveries/my-deliveries` | GET | `@Roles(DELIVERY_PARTNER, ADMIN)` | Protected | Bound to caller's `deliveryProfileId` |
| `/deliveries/:id/status` | PATCH | `@Roles(DELIVERY_PARTNER, ADMIN)` | Protected | `delivery.deliveryPartner.userId === user.id` |

---

## 5. Automated Security Test Suite Cases
Location: `backend/src/security.spec.ts`

- **TEST 1**: Unauthenticated user calling protected endpoint → `401 Unauthorized` (PASSED)
- **TEST 2**: Authenticated CONSUMER calling FARMER-only endpoint → `403 Forbidden` (PASSED)
- **TEST 3**: FARMER A modifying FARMER B's product → `403 Forbidden` (PASSED)
- **TEST 4**: CONSUMER A inspecting CONSUMER B's order → `403 Forbidden` (PASSED)
- **TEST 5**: DELIVERY_PARTNER A modifying DELIVERY_PARTNER B's delivery → `403 Forbidden` (PASSED)
- **TEST 6**: Normal user calling ADMIN endpoint → `403 Forbidden` (PASSED)
- **TEST 7**: Valid resource owner modifying own resource → `200 OK` (PASSED)

---

## 6. Known Security Limitations & Future Roadmap
1. **Frontend Session Persistence**: Flutter app local storage persistence for JWT tokens and refresh token rotation will be integrated in Phase 2.
2. **WebSocket Gateway Authorization**: Socket.io token handshake validation will be enforced in Phase 2 / real-time updates.
