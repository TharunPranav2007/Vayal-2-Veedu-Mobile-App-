# FarmDirect (Vayal 2 Veedu) — Requirements & Feature Specification

## 1. Executive Summary & Problem Statement

**FarmDirect** ("Vayal 2 Veedu" — *From the Field to Your Home*) is a two-sided digital marketplace designed to connect farmers directly with consumers. 

### Key Problems Addressed:
- **Intermediary Exploitation & Reduced Margins:** Elimination of multi-tiered middlemen, allowing farmers to earn fair market value.
- **Consumer Price Inflation:** Direct pricing reduces markup for consumers while ensuring produce freshness.
- **Lack of Price Transparency:** Real-time visibility into market prices, stock, and produce origin.
- **Order & Supply Chain Friction:** Digitized order placement, real-time delivery tracking, and automated status management.
- **Direct Farmer-Consumer Connectivity:** Enable direct communication, transparent reviews, and trust-building between produce growers and households.

---

## 2. Core User Roles

| Role | Symbol | Description | Key Objectives |
| :--- | :--- | :--- | :--- |
| **Farmer** | 🌾 `FARMER` | Primary seller listing agricultural produce | Add/manage products, set pricing/stock, fulfill orders, view sales metrics |
| **Consumer** | 🛒 `CONSUMER` | Household or business buyer purchasing fresh produce | Browse/search produce, cart management, checkout, track orders, review products |
| **Delivery Partner** | 🚚 `DELIVERY_PARTNER` | Logistics provider delivering orders from field to home | Accept delivery assignments, navigate pickup/dropoff, update delivery milestones |
| **Administrator** | 🛡️ `ADMIN` | Platform operator governing marketplace compliance | System monitoring, user moderation, order oversight, analytics dashboards |

---

## 3. Requirement Matrix

### 3.1 Functional Requirements (FR)

| Req ID | Module | User Role | Requirement Description | Priority |
| :--- | :--- | :--- | :--- | :--- |
| **FR-AUTH-01** | Auth | All | Role-based Registration & Authentication (Email, Password, Phone, Role) | Critical |
| **FR-AUTH-02** | Auth | All | JWT Access Token & Refresh Token Auth with Secure Storage | Critical |
| **FR-FAR-01** | Farmer | Farmer | Manage Farm Profile (Farm name, location, address, bio, farm images) | High |
| **FR-FAR-02** | Farmer | Farmer | Product CRUD (Name, Description, Category, Price/unit, Stock, Images) | Critical |
| **FR-FAR-03** | Farmer | Farmer | Stock & Availability Toggle (Publish/Unpublish, Stock updates) | High |
| **FR-FAR-04** | Farmer | Farmer | Receive & Process Orders (Accept, Prepare, Mark Ready for Pickup) | Critical |
| **FR-FAR-05** | Farmer | Farmer | Sales Analytics & Earnings Dashboard | Medium |
| **FR-CON-01** | Consumer | Consumer | Browse, Filter (Category, Price, Locality) & Search Products | Critical |
| **FR-CON-02** | Consumer | Consumer | Server-side Paginated Product Discovery with Sorting | Critical |
| **FR-CON-03** | Consumer | Consumer | Shopping Cart Management (Add, Remove, Quantity modification) | Critical |
| **FR-CON-04** | Consumer | Consumer | Wishlist Management (Add, Remove, Move to Cart) | Medium |
| **FR-CON-05** | Consumer | Consumer | Checkout & Order Placement with Server-side Price Verification | Critical |
| **FR-CON-06** | Consumer | Consumer | Payment Processing Abstraction (COD & Test/Mock Payment Gateway) | Critical |
| **FR-CON-07** | Consumer | Consumer | Real-time Order Tracking & History | Critical |
| **FR-CON-08** | Consumer | Consumer | Ratings & Reviews for Delivered Purchases (1–5 Stars + Text) | High |
| **FR-DEL-01** | Delivery | Delivery | View Assigned Deliveries & Delivery Details | Critical |
| **FR-DEL-02** | Delivery | Delivery | Delivery Status Lifecycle Updates (Accepted, Picked Up, Out for Delivery, Delivered) | Critical |
| **FR-ADM-01** | Admin | Admin | User & Profile Management (Activate/Deactivate Users, Verify Farmers) | High |
| **FR-ADM-02** | Admin | Admin | Marketplace Moderation (Product approval/removal, Review moderation) | Medium |
| **FR-ADM-03** | Admin | Admin | Platform-wide Metrics Dashboard (Total GMV, Orders, Active Users) | Medium |
| **FR-NOT-01** | System | All | Push Notifications via FCM for Order & Delivery State Changes | High |
| **FR-RT-01** | System | All | Real-Time Order & Delivery Status Updates via WebSockets (with REST fallback) | High |
| **FR-AI-01** | AI (Opt) | Farmer/Consumer | FarmAssist AI: Product description generation & natural language search queries | Low (Optional) |

---

## 4. Feature Matrix by Role

```
+------------------------------------+--------+----------+----------+-------+
| Feature / Action                   | Farmer | Consumer | Delivery | Admin |
+------------------------------------+--------+----------+----------+-------+
| Auth (Register/Login/Refresh/Me)   |   X    |    X     |    X     |   X   |
| Edit Personal Profile & Address    |   X    |    X     |    X     |   X   |
| Manage Farm Details                |   X    |          |          |       |
| Add / Edit / Delete Products       |   X    |          |          |   X   |
| Update Stock & Publish Status      |   X    |          |          |       |
| Search & Filter Products           |        |    X     |          |   X   |
| Cart Operations & Wishlist         |        |    X     |          |       |
| Checkout & Payment Selection       |        |    X     |          |       |
| Accept & Process Orders            |   X    |          |          |       |
| Accept Delivery & Update Delivery  |        |          |    X     |       |
| Live Order Status Tracking         |   X    |    X     |    X     |   X   |
| Post Product Review                |        |    X     |          |       |
| View Platform Analytics            |   X*   |          |          |   X   |
| Moderate Users / Products / Orders |        |          |          |   X   |
+------------------------------------+--------+----------+----------+-------+
*Farmer views sales metrics specific to their farm. Admin views system-wide analytics.
```

---

## 5. Non-Functional Requirements (NFR)

1. **Security:**
   - Password hashing with **Argon2** (or **bcrypt** fallback).
   - Stateless **JWT** authentication with short-lived access tokens.
   - Server-side role guards and resource ownership authorization.
   - HTTP Security Headers using **Helmet**, CORS configuration, and IP Rate Limiting.
2. **Performance & Scalability:**
   - Server-side pagination for all list endpoints (Default page size: 20).
   - Optimized image delivery (thumbnail generation, URL-based cloud/CDN references).
   - Indexed PostgreSQL database queries for high-cardinality searches (Category, Price, Farmer ID, Order Status).
3. **Resilience & Offline Handling:**
   - Offline local caching for recently viewed products and local preferences using **Drift/SQLite** or **Flutter Secure Storage**.
   - Graceful REST polling fallback if WebSocket connectivity drops.
   - Strict transactional integrity during checkout (stock locking & re-validation).
4. **UI/UX Aesthetics ("Vayal 2 Veedu"):**
   - Palette: Agricultural Green (`#1E5631`), Fresh Orange (`#F9690E`), Warm White (`#FAFAFA`), Deep Neutral (`#1C2421`).
   - Clean, modern Material 3 design with responsive grid layouts and smooth micro-interactions.
