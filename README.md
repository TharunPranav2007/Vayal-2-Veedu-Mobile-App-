# FarmDirect — Vayal 2 Veedu 🌾

> *"From the Field to Your Home"*

**Course:** U21CS503 – Mobile Application Development  
**Platform:** Cross-Platform Mobile Application (Flutter) + Modular Backend (NestJS + PostgreSQL)

---

## 📌 Project Overview

**FarmDirect (Vayal 2 Veedu)** is a full-stack, direct farmer-to-consumer digital marketplace designed to bridge the gap between agricultural growers and households. By eliminating traditional multi-tiered middlemen, the platform empowers farmers with direct market access, fair pricing, and automated order fulfillment, while providing consumers with fresh, traceable produce at transparent prices.

---

## 🎯 Problem Statement & Objectives

### Problem Addressed:
1. **Dependency on Intermediaries:** Farmers lose up to 50% of produce value to supply chain middlemen.
2. **Reduced Farmer Margins:** High distribution costs shrink agricultural profit margins.
3. **Consumer Price Inflation:** Retail markups artificially inflate fresh produce prices.
4. **Lack of Transparency:** Consumers cannot verify produce freshness, origin, or farmer identity.
5. **Supply Chain Friction:** Outdated manual order tracking and distribution inefficiencies.

### Core Objectives:
- Eliminate agricultural intermediaries through a direct digital marketplace.
- Provide real-time price, stock, and produce origin transparency.
- Streamline direct order placement, real-time delivery tracking, and automated fulfillment.
- Support role-based workflows for Farmers, Consumers, Delivery Partners, and Platform Administrators.

---

## 👥 User Roles & Capabilities

| Role | Symbol | Key Capabilities |
| :--- | :--- | :--- |
| **Farmer** | 🌾 `FARMER` | Add/manage produce listings, set pricing & stock, manage farm profile, process received orders, view sales metrics. |
| **Consumer** | 🛒 `CONSUMER` | Search & filter produce, add items to cart, server-validated checkout, track order status in real-time, submit reviews. |
| **Delivery Partner** | 🚚 `DELIVERY_PARTNER` | View assigned delivery jobs, accept pickup requests, navigate delivery routes, update delivery milestones. |
| **Administrator** | 🛡️ `ADMIN` | Oversee system-wide metrics, manage users, moderate produce catalog, inspect platform-wide order activities. |

---

## 🛠️ Technology Stack

### Mobile Client (Flutter)
- **Framework:** Flutter 3.x (Dart 3.x)
- **UI System:** Material 3 with "Vayal 2 Veedu" brand identity (Agricultural Green `#1E5631`, Fresh Orange `#F9690E`, Warm White `#FAFAFA`).
- **State Management:** Riverpod 2.x (`AsyncNotifier`, `ProviderScope`).
- **Navigation:** `go_router` declarative routing with dynamic role-based guards.
- **Networking:** Dio HTTP client with JWT interceptors.
- **Local Storage:** `flutter_secure_storage` for token security.

### Backend Infrastructure (NestJS)
- **Framework:** NestJS (TypeScript / Node.js) with modular dependency injection.
- **Database & ORM:** PostgreSQL + Prisma ORM.
- **API Protocol:** REST API (`/api/v1/`) + Swagger OpenAPI (`/api/docs`).
- **Real-Time Gateway:** NestJS WebSocket Gateway (Socket.IO) for live order updates.
- **Notifications:** Firebase Cloud Messaging (FCM).
- **Security:** JWT (Access + Refresh token rotation), Argon2 / bcrypt password hashing, Helmet, CORS, and Rate Limiting.

---

## 📐 System Architecture

```
[Flutter App (1 Unified Binary)]
       │
       ├── HTTPS REST (Dio) ────► [NestJS Controllers & Services] ────► [Prisma ORM] ──► [PostgreSQL DB]
       ├── WebSockets (Socket.IO)► [NestJS WS Gateway] ───────────────► Live Order Rooms
       └── FCM Push Notifications► [Firebase Admin SDK] ─────────────► Push Notification Tray
```

---

## 🗄️ Database ER Diagram & Schema

The relational schema strictly models 20 tables:
- `users`, `farmer_profiles`, `consumer_profiles`, `delivery_profiles`
- `categories`, `products`, `product_images`
- `carts`, `cart_items`
- `orders`, `order_items`, `order_status_history`, `payments`, `deliveries`
- `reviews`, `wishlists`, `wishlist_items`, `notifications`, `device_tokens`, `addresses`

---

## 🚀 Getting Started & Setup

### Prerequisites
- Node.js (v18+)
- Flutter SDK (v3.19+)
- PostgreSQL or Docker

### 1. Backend Setup
```bash
cd backend
npm install
cp .env.example .env
npx prisma generate
npx prisma migrate dev --name init
npm run start:dev
```
- REST API: `http://localhost:3000/api/v1`
- Swagger OpenAPI: `http://localhost:3000/api/docs`

### 2. Docker Compose (Alternative Backend Run)
```bash
docker-compose up -d
```

### 3. Flutter App Setup
```bash
flutter pub get
flutter run
```

---

## 🧪 Testing Suite

### Flutter Tests
```bash
flutter test
```

### Backend Tests
```bash
cd backend
npm run test
npm run test:e2e
```

---

## 📋 Course & Team Information

- **Course:** U21CS503 – Mobile Application Development
- **Project:** FarmDirect ("Vayal 2 Veedu")
- **Review:** Review 1 & Final Capstone Implementation
