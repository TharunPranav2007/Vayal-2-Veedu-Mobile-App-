# 🌾 FarmDirect — Vayal 2 Veedu (வயல் 2 வீடு)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-2.x-42A5F5?style=for-the-badge&logo=flutter&logoColor=white)
![NestJS](https://img.shields.io/badge/NestJS-10.x-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-5.x-2D3748?style=for-the-badge&logo=prisma&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

### **"Direct from the Farmer's Field (வயல்) to Your Home (வீடு)"**

*A Production-Grade, Cross-Platform Digital Agriculture Marketplace connecting Farmers, Consumers, Delivery Partners, and Platform Administrators in Real-Time.*

</div>

---

## 📖 Table of Contents
- [📌 Project Overview](#-project-overview)
- [✨ What's New in Version 2.0](#-whats-new-in-version-20)
- [⚡ Multi-Role Matrix & Demo Credentials](#-multi-role-matrix--demo-credentials)
- [📐 System Architecture & Order Pipeline](#-system-architecture--order-pipeline)
- [🎨 Design System & UI Highlights](#-design-system--ui-highlights)
- [🛠️ Technology Stack](#️-technology-stack)
- [🚀 Quick Start & Installation](#-quick-start--installation)
- [👥 GitHub Team Workflow](#-github-team-workflow)
- [🗄️ Database Schema](#️-database-schema)
- [🎓 Course Information](#-course-information)

---

## 📌 Project Overview

**FarmDirect (Vayal 2 Veedu / வயல் 2 வீடு)** is an end-to-end mobile and backend platform engineered to eliminate multi-tiered agricultural intermediaries. By connecting growers directly with households, the platform ensures:

- 🌾 **For Farmers:** Fair pricing, 100% direct revenue retention, and automated order status pipelines.
- 🛒 **For Consumers:** Fresh, pesticide-free, traceable farm produce at fair market prices with multi-order live dispatch tracking.
- 🛵 **For Delivery Partners:** Real-time job dispatches, interactive job detail inspection, customer/farm contact shortcuts, and route coordinates.
- 🛡️ **For Administrators:** Platform-wide GMV analytics, verified farmer/rider moderation, and full transaction oversight.

---

## ✨ What's New in Version 2.0

> [!TIP]
> **Major Feature Additions & Platform Enhancements**

### 📱 1. Multi-Order Live Tracking (`/consumer/orders/track`)
- Consumers can now view and track **all placed orders** (not just the latest single order) sequentially.
- Features a live 5-step animated progress timeline (`Placed` ➔ `Confirmed` ➔ `Preparing` ➔ `Out for Delivery` ➔ `Delivered`).

### 🛵 2. Interactive Delivery Job Detail Inspector
- Delivery partners can tap any available job in their portal to launch a rich bottom-sheet modal.
- Includes exact farm pickup address, customer dropoff location, itemized produce breakdown, and 1-tap **Call Farm** & **Call Customer** actions.

### 🌾 3. Sequential Farmer Order Pipeline
- Farmers can transition incoming orders step-by-step (`1. Confirm Order` ➔ `2. Start Packing` ➔ `3. Ready for Pickup`), keeping all 4 user roles perfectly in sync.

### 🔑 4. One-Tap Role Auto-Fill Login
- Pre-filled demo credentials across all login portals for instant one-tap access without typing credentials manually.

### 🛡️ 5. Security & Authorization Hardening
- Backend NestJS JWT authentication & RBAC guards across `/products` and `/orders` APIs.
- IDOR (Insecure Direct Object Reference) protection enforcing strict user resource ownership.

### 📱 6. Layout & Rendering Performance Fixes
- Replaced shrinkwrap sliver viewports with optimized static flex rendering, eliminating all Flutter layout assertion crashes across all mobile screen dimensions.
- Enabled Android 13+ Predictive Back gesture compatibility in `AndroidManifest.xml`.

---

## ⚡ Multi-Role Matrix & Demo Credentials

| Role | Symbol | Portal Route | Pre-filled Email | Password | Key Functionalities |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **Farmer** | 🌾 | `/farmer/dashboard` | `farmer@vayal2veedu.com` | `Password123!` | • Publish & edit produce listings with pricing & stock<br>• Realtime revenue metrics (GMV & Active Produce)<br>• Sequential 3-step order acceptance & packing pipeline |
| **Consumer** | 🛒 | `/consumer/home` | `consumer@vayal2veedu.com` | `Password123!` | • Organic produce catalog with category filters<br>• Dynamic shopping cart with live GST (5%) & delivery calculation<br>• Live multi-order fulfillment tracking timeline |
| **Delivery Partner** | 🛵 | `/delivery/dashboard` | `delivery@vayal2veedu.com` | `Password123!` | • Available dispatch jobs queue<br>• Interactive job details modal with farm & customer contact buttons<br>• Milestone status toggles (`Pick Up` ➔ `Deliver`) |
| **Administrator** | 🛡️ | `/admin/dashboard` | `admin@vayal2veedu.com` | `Password123!` | • System-wide GMV & order volume analytics<br>• Verified farmer profiles & delivery partner moderation<br>• Live transaction oversight & dispatch inspection |

---

## 📐 System Architecture & Order Pipeline

```mermaid
graph TD
    A[🌾 FARMER PORTAL] -->|1. List Organic Produce| B(📦 Central Inventory Store)
    B -->|2. Real-Time Feed| C[🛒 CONSUMER PORTAL]
    C -->|3. Place Order & Deduct Inventory| D(🚚 Central Dispatch Pipeline)
    D -->|4. Incoming Order Alert| A
    D -->|5. Available Job Alert| E[🛵 DELIVERY PARTNER PORTAL]
    A -->|6. Confirm & Pack Produce| D
    E -->|7. Pick Up & Deliver| F[📍 LIVE CONSUMER TRACKING TIMELINE]
    D & B -->|8. Real-Time GMV & Order Audits| G[🛡️ ADMIN DASHBOARD]
```

---

## 🎨 Design System & UI Highlights

The application adopts Google's **Material 3** design system customized with the **Vayal 2 Veedu** agricultural identity:

- 🟢 **Agricultural Green (`#1E5631`):** Represents fresh fields, organic produce, and trust.
- 📙 **Fresh Harvest Orange (`#F9690E`):** Highlights call-to-actions, cart badges, and active alerts.
- 🔵 **Info Blue (`#0288D1`):** Accents delivery dispatch statuses and interactive modals.
- ⚪ **Warm Surface (`#FAFAFA`):** Provides high readability contrast for mobile screens.
- 🔤 **Typography:** Google Fonts (`Outfit` for headlines, `Inter` for clean body typography).

---

## 🛠️ Technology Stack

### **Mobile Frontend (Flutter)**
- **Framework:** Flutter 3.x / Dart 3.x
- **State Management:** Riverpod 2.x (`StateNotifierProvider`, `ProviderScope`)
- **Navigation:** `go_router` 13.x with declarative role guards
- **HTTP Client:** Dio 5.x with JSON serializable models
- **Typography & Icons:** Google Fonts & Cupertino Icons

### **Backend Service (NestJS)**
- **Framework:** NestJS 10.x (TypeScript / Node.js)
- **Database ORM:** PostgreSQL 16 + Prisma ORM
- **API Specification:** Swagger OpenAPI (`/api/docs`)
- **Realtime Gateway:** Socket.IO WebSocket Gateway
- **Security:** JWT authentication, RBAC Guards, bcrypt hashing, Helmet, CORS

---

## 🚀 Quick Start & Installation

### 1. Prerequisites
- **Flutter SDK:** v3.19+ ([Download Flutter](https://flutter.dev))
- **Node.js:** v18+ ([Download Node.js](https://nodejs.org))
- **Android Studio** with Android SDK 35 & Pixel 6 AVD Emulator

---

### 2. Running the Flutter Mobile App

```bash
# Clone the repository
git clone https://github.com/TharunPranav2007/Vayal-2-Veedu-Mobile-App-.git
cd Vayal-2-Veedu-Mobile-App-

# Install Flutter dependencies
flutter pub get

# Run unit and widget tests
flutter test

# Launch on connected Android Emulator (Pixel 6)
flutter run -d emulator-5554
```

---

### 3. Running the NestJS Backend Service

```bash
# Navigate to backend directory
cd backend

# Install Node dependencies
npm install

# Set up environment configuration
cp .env.example .env

# Run database migrations and generate Prisma client
npx prisma generate
npx prisma migrate dev

# Start NestJS dev server
npm run start:dev
```
- **REST API Base URL:** `http://localhost:3000/api`
- **Swagger Documentation:** [http://localhost:3000/api/docs](http://localhost:3000/api/docs)

---

## 👥 GitHub Team Workflow

### 1. Pushing Local Changes
```bash
# Stage changed files
git add .

# Commit with a descriptive message
git commit -m "feat(mobile): add delivery job detail modal and multi-order tracking"

# Push to main branch
git push origin main
```

### 2. Pulling Latest Changes
```bash
# Always pull before starting daily work
git pull origin main
```

---

## 🗄️ Database Schema

The PostgreSQL database models 20 core relational entities:
- `users`, `farmer_profiles`, `consumer_profiles`, `delivery_profiles`
- `categories`, `products`, `product_images`
- `carts`, `cart_items`, `orders`, `order_items`, `deliveries`
- `reviews`, `wishlists`, `notifications`, `addresses`

---

## 🎓 Course Information

- **Course:** U21CS503 – Mobile Application Development
- **Application Name:** FarmDirect ("Vayal 2 Veedu" / "வயல் 2 வீடு")
- **Repository:** [`TharunPranav2007/Vayal-2-Veedu-Mobile-App-`](https://github.com/TharunPranav2007/Vayal-2-Veedu-Mobile-App-)
- **License:** MIT License
