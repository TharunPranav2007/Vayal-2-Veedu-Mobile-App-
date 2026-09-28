# FarmDirect (Vayal 2 Veedu) — User Flows & Screen Map

## 1. Complete Screen Map by Role

```
                     +---------------------------+
                     |    COMMON & AUTHENTICATION |
                     +---------------------------+
                     |  - Splash Screen          |
                     |  - Onboarding Screen      |
                     |  - Role Selection Screen  |
                     |  - Login Screen           |
                     |  - Register Screen        |
                     |  - Forgot Password Screen |
                     |  - Profile Screen         |
                     |  - Settings Screen        |
                     |  - Notifications Screen   |
                     +---------------------------+
                                   |
         +-------------------------+-------------------------+-------------------------+
         |                         |                         |                         |
         v                         v                         v                         v
+------------------+      +------------------+      +------------------+      +------------------+
|   FARMER ROLE    |      |  CONSUMER ROLE   |      |  DELIVERY ROLE   |      |    ADMIN ROLE    |
+------------------+      +------------------+      +------------------+      +------------------+
| - Farmer Dash    |      | - Consumer Home  |      | - Delivery Dash  |      | - Admin Dash     |
| - Farm Profile   |      | - Search & Filter|      | - Assigned Orders|      | - Users Manager  |
| - Farm Details   |      | - Categories     |      | - Delivery Detail|      | - Farmers Mgr    |
| - My Products    |      | - Product List   |      | - Delivery Status|      | - Consumers Mgr  |
| - Add Product    |      | - Product Detail |      |                  |      | - Products Mgr   |
| - Edit Product   |      | - Farmer Detail  |      |                  |      | - Orders Mgr     |
| - Product Detail |      | - Cart Screen    |      |                  |      | - Delivery Mon   |
| - Stock Mgmt     |      | - Wishlist Screen|      |                  |      | - Platform Activ |
| - Received Orders|      | - Checkout       |      |                  |      +------------------+
| - Order Details  |      | - Payment Screen |      +------------------+
| - Sales History  |      | - Order Confirm  |
+------------------+      | - Order History  |
                          | - Order Detail   |
                          | - Live Tracking  |
                          | - Review & Rating|
                          +------------------+
```

---

## 2. Dynamic Navigation Map & Route Guarding (`go_router`)

```
/ (Splash) ──► Unauthenticated? ──► /onboarding ──► /login or /register
             │
             ├──► Authenticated FARMER? ─────────► /farmer/dashboard
             ├──► Authenticated CONSUMER? ───────► /consumer/home
             ├──► Authenticated DELIVERY_PARTNER? ► /delivery/dashboard
             └──► Authenticated ADMIN? ──────────► /admin/dashboard
```

### Route Guard Implementation Logic
`go_router` evaluates user authentication state & user role on every navigation attempt:
- `redirect: (context, state) =>`:
  1. If `!isLoggedIn` and target route != `/login`, `/register`, `/forgot-password`, `/onboarding` ──► Redirect to `/login`.
  2. If `isLoggedIn` and user attempts to access routes outside their assigned role (e.g. `CONSUMER` trying to access `/farmer/*` or `/admin/*`) ──► Redirect to home dashboard for their authenticated role.

---

## 3. End-to-End Workflow Specifications

### 3.1 Farmer Produce Listing Workflow
1. **Farmer Authentication:** Farmer logs into app, redirected to `/farmer/dashboard`.
2. **Access Product Management:** Taps "Add Product" button.
3. **Form Input:** Enters product name, description, selects category, price per unit (e.g., ₹40 / kg), and available inventory stock.
4. **Image Selection:** Uses `image_picker` to capture or select produce images.
5. **Backend Processing:** Client sends multipart request (`POST /api/v1/farmers/me/products`). Backend validates DTO, stores image via storage abstraction, creates `Product` record in PostgreSQL.
6. **State Update:** Farmer UI updates instantly via Riverpod `AsyncNotifier`, displaying new listing under "My Products".

### 3.2 Consumer Purchase & Order Workflow
1. **Product Discovery:** Consumer browses home feed, searches "Organic Tomatoes", applies price/locality filters.
2. **Product Details & Cart:** Consumer selects item, views farmer details & stock, clicks "Add to Cart".
3. **Cart & Checkout:** Consumer views `/cart`, verifies subtotal, delivery fee, enters shipping address.
4. **Server-Side Price Validation:** Consumer clicks "Place Order". Backend recalculates prices from `products` table, verifies stock availability.
5. **Order Creation:** Backend executes Prisma transaction: creates `Order`, creates `OrderItem` records, locks stock, creates `Payment` record (COD / Test Payment).
6. **Confirmation & Real-Time Tracking:** Consumer receives order confirmation screen and can track order status live via WebSocket events.

### 3.3 Delivery Fulfillment Workflow
1. **Order Acceptance by Farmer:** Farmer receives order notification, prepares produce, marks order `READY_FOR_PICKUP`.
2. **Delivery Partner Assignment:** System assigns order to available Delivery Partner. Partner receives FCM push notification.
3. **Delivery Lifecycle Updates:**
   - Partner taps "Accept Delivery" (`ASSIGNED` ──► `ACCEPTED`).
   - Partner arrives at farm, collects produce, marks `PICKED_UP`.
   - Partner taps "Start Delivery" (`OUT_FOR_DELIVERY`).
   - Partner delivers produce to consumer home, receives payment if COD, marks `DELIVERED`.
4. **Consumer Review:** Upon `DELIVERED` status, consumer receives notification prompting them to rate (1-5 stars) and review the purchased produce.
