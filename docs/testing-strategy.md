# FarmDirect (Vayal 2 Veedu) — Testing Strategy & CI/CD Pipeline

## 1. Multi-Layered Testing Strategy

To ensure zero regressions and production stability, FarmDirect employs a rigorous multi-layered testing strategy spanning both the mobile Flutter client and the NestJS backend.

```
+-----------------------------------------------------------------+
|                    13-STEP INTEGRATION TESTS                     |
|           End-to-End User Journeys (Flutter & Backend)          |
+-----------------------------------------------------------------+
                 │                               │
                 ▼                               ▼
+---------------------------------+  +----------------------------+
|     FLUTTER CLIENT TESTS        |  |    NESTJS BACKEND TESTS    |
+---------------------------------+  +----------------------------+
| - Unit Tests (Validators, Cart) |  | - Service Unit Tests (Jest)|
| - State Tests (Riverpod)        |  | - Controller Tests         |
| - Widget Tests (UI Components)  |  | - API E2E (Supertest)      |
+---------------------------------+  +----------------------------+
```

---

## 2. Flutter Testing Strategy

### 2.1 Unit & State Tests (`flutter_test`)
- **Validators:** Test email, phone, password strength, product price (>0), stock (>=0).
- **Cart Calculations:** Test subtotal, delivery fee calculation, discount application, and final total rounding.
- **Data Models:** Test json serialization / deserialization using `freezed` models.
- **Riverpod Controllers:** Test state notifier behavior for auth state, catalog filtering, cart state transitions.

### 2.2 Widget Tests (`flutter_test`)
- **Login & Registration Screens:** Verify form validation error popups and button enable/disable logic.
- **Product Card Component:** Test rating display, stock indicator, price formatting, and favorite toggle interaction.
- **Cart & Checkout Screen:** Test dynamic quantity increment/decrement, clear cart dialog, and payment selector.
- **Order Tracking Screen:** Test progress steppers for order states (`PLACED` ──► `DELIVERED`).

---

## 3. Mandatory 13-Step Integration Workflow Test

The end-to-end integration test suite executes the complete marketplace lifecycle:

1. **User Registration:** Consumer, Farmer, and Delivery Partner accounts register via `/auth/register`.
2. **User Login:** Authenticate accounts and obtain valid JWT tokens.
3. **Farmer Product Creation:** Farmer lists a new produce item (`POST /api/v1/farmers/me/products`).
4. **Consumer Catalog Search:** Consumer searches and filters for the newly created produce item.
5. **Consumer Product Detail View:** Consumer views product attributes, stock, and farmer profile.
6. **Consumer Add to Cart:** Consumer adds produce item to cart with desired quantity.
7. **Consumer Order Checkout:** Consumer places test order with shipping address and payment method.
8. **Farmer Order Notification & Receipt:** Farmer receives order in dashboard (`GET /farmers/me/orders`).
9. **Farmer Order Processing:** Farmer accepts and marks order state as `READY_FOR_PICKUP`.
10. **Delivery Partner Assignment:** System assigns delivery job to Delivery Partner.
11. **Delivery Lifecycle Update:** Delivery Partner picks up produce and updates status to `DELIVERED`.
12. **Consumer Order Completion:** Consumer receives delivery notification and confirms order delivery.
13. **Consumer Product Review:** Consumer posts a 5-star review for the purchased produce item.

---

## 4. NestJS Backend Testing Strategy

### 4.1 Unit Tests (Jest)
- Test isolated service methods (Auth service password hashing, order price calculation logic, stock deduction).
- Mock Prisma DB queries and external notification service dependencies.

### 4.2 API Integration & E2E Tests (Supertest)
- Execute HTTP requests against NestJS API using a test PostgreSQL database.
- Validate role-based endpoint protection (e.g. `CONSUMER` token getting `403 Forbidden` on `/admin/dashboard`).
- Test database transaction rollbacks when stock is insufficient during checkout.

---

## 5. GitHub Actions CI/CD Pipeline Specification

File path: `.github/workflows/ci.yml`

```yaml
name: FarmDirect CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  backend-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgrespassword
          POSTGRES_DB: farmdirect_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json

      - name: Install Backend Dependencies
        run: cd backend && npm ci

      - name: Prisma Generate & Migrate
        run: cd backend && npx prisma generate && npx prisma migrate reset --force
        env:
          DATABASE_URL: postgresql://postgres:postgrespassword@localhost:5432/farmdirect_test?schema=public

      - name: Run Backend Linter & Format Check
        run: cd backend && npm run lint

      - name: Run Backend Unit & E2E Tests
        run: cd backend && npm run test && npm run test:e2e
        env:
          DATABASE_URL: postgresql://postgres:postgrespassword@localhost:5432/farmdirect_test?schema=public
          JWT_SECRET: test_jwt_secret_key

  flutter-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.x'
          channel: 'stable'
          cache: true

      - name: Install Flutter Dependencies
        run: flutter pub get

      - name: Check Formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Run Static Analysis
        run: flutter analyze

      - name: Run Flutter Unit & Widget Tests
        run: flutter test
```
