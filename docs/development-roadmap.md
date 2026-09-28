# FarmDirect (Vayal 2 Veedu) — Development Roadmap (Phases 0–17)

## Executive Summary & Phase Breakdown

The FarmDirect development lifecycle is structured into 18 incremental phases (Phase 0 through Phase 17). Every phase contains clear deliverables, technical milestones, and verification criteria.

---

## Phase Matrix

| Phase | Title | Core Focus & Key Deliverables | Status |
| :--- | :--- | :--- | :---: |
| **Phase 0** | **Requirements & Architecture Specification** | Complete comprehensive system specs, ER diagrams, API contracts, screen maps, and technology justifications in `docs/`. | **IN PROGRESS / COMPLETE** |
| **Phase 1** | **Architecture & Project Initialization** | Initialize Flutter project structure (`lib/app`, `lib/core`, `lib/features`), NestJS backend project (`backend/src`), Git repository, `.gitignore`, `.env.example`. | Pending |
| **Phase 2** | **PostgreSQL & Prisma Database Engine** | Configure Docker PostgreSQL container, create `prisma/schema.prisma` with core models & indexes, run migrations, and generate Prisma client. | Pending |
| **Phase 3** | **NestJS Backend Foundation** | Set up modular NestJS structure, Swagger OpenAPI (`/api/docs`), global `ValidationPipe`, unified `HttpExceptionFilter`, and response interceptors. | Pending |
| **Phase 4** | **Authentication & Role Authorization** | Implement `/auth/register`, `/auth/login`, `/auth/refresh`, JWT token logic, Argon2 password hashing, NestJS `RolesGuard` and `JwtAuthGuard`. | Pending |
| **Phase 5** | **Farmer Module** | Implement Farmer Profile API, Product CRUD (`/farmers/me/products`), stock availability management, and Flutter Farmer screens (`AddProduct`, `MyProducts`, `FarmerDashboard`). | Pending |
| **Phase 6** | **Consumer Marketplace & Discovery** | Implement server-side product search, category filtering, price sorting, and Flutter Consumer screens (`ConsumerHome`, `ProductDetail`, `SearchFilter`). | Pending |
| **Phase 7** | **Cart & Server-Validated Checkout** | Implement backend Cart API, server-side price recalculation, stock locking transaction, and Flutter Cart/Checkout UI. | Pending |
| **Phase 8** | **Order Management Lifecycle** | Implement full order lifecycle (`PLACED` ──► `CONFIRMED` ──► `PREPARING` ──► `READY_FOR_PICKUP`), status history audit log, and Order screens for Consumer & Farmer. | Pending |
| **Phase 9** | **Delivery Partner Module** | Implement delivery assignment API, pickup/dropoff status transitions (`PICKED_UP`, `OUT_FOR_DELIVERY`, `DELIVERED`), and Flutter Delivery Partner screens. | Pending |
| **Phase 10** | **Reviews & Wishlist Engine** | Implement verified purchase review system (1-5 stars), product average rating aggregation, wishlist operations, and dynamic UI ratings. | Pending |
| **Phase 11** | **Notifications & Real-Time Engine** | Integrate Socket.IO WebSocket Gateway for live order tracking and Firebase Cloud Messaging (FCM) for push notifications with REST fallback. | Pending |
| **Phase 12** | **Admin Platform Portal** | Implement system analytics dashboard API (`/admin/dashboard`), user management (activate/deactivate), product moderation, and Admin screens. | Pending |
| **Phase 13** | **Testing Suite Execution** | Build and execute Flutter unit/widget tests, 13-step E2E integration test flow, and NestJS Jest unit/Supertest integration tests. | Pending |
| **Phase 14** | **Security Audit & Hardening** | Implement Helmet security headers, CORS origin checks, IP rate limiting (`nestjs/throttler`), secure storage verification, and secret scanning. | Pending |
| **Phase 15** | **Performance & Cache Optimization** | Database query index optimization, pagination verification, image thumbnail caching, and Flutter local persistence with `flutter_secure_storage`. | Pending |
| **Phase 16** | **UI/UX Aesthetics Polish ("Vayal 2 Veedu")** | Polish Material 3 design, custom brand colors (Agricultural Green `#1E5631`, Fresh Orange `#F9690E`), smooth animations, empty/error state illustrations. | Pending |
| **Phase 17** | **Release APK & Build Deliverables** | Configure Gradle build parameters, sign Android application, build release APK (`app-release.apk`), verify APK installation on emulator & physical device. | Pending |

---

## Verification & Quality Gates

Each phase transition requires passing the following quality gate:
1. **Format & Linting:** Clean static analysis for both Flutter (`flutter analyze`) and NestJS (`npm run lint`).
2. **Automated Tests:** Zero regression failures in unit and integration tests.
3. **Execution Verification:** Clean compilation and execution on Node.js and Android emulator.
