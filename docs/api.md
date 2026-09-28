# FarmDirect (Vayal 2 Veedu) — REST API Specification (`/api/v1/`)

## 1. Global API Standards

- **Base URL:** `/api/v1/`
- **Protocol:** HTTPS
- **Data Format:** Application/JSON
- **Authentication Header:** `Authorization: Bearer <JWT_ACCESS_TOKEN>`

### Standard Error Response Format
All endpoint errors strictly conform to the unified error response structure:

```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "The email or password provided is incorrect.",
    "details": null
  },
  "timestamp": "2026-09-22T18:30:00.000Z"
}
```

### Standard Success Response Wrapper
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully.",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

---

## 2. API Endpoint Matrix

### 2.1 Authentication & User Management (`/auth`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | Public | Register new user (`FARMER`, `CONSUMER`, `DELIVERY_PARTNER`) |
| `POST` | `/auth/login` | Public | Authenticate user & return Access Token + Refresh Token |
| `POST` | `/auth/refresh` | Public | Issue new Access Token using valid Refresh Token |
| `POST` | `/auth/logout` | Authenticated | Revoke Refresh Token & invalidate session |
| `GET`  | `/auth/me` | Authenticated | Retrieve authenticated user profile & role metadata |

### 2.2 Product Catalog (`/products`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET`  | `/products` | Public | List products (Query params: `category`, `minPrice`, `maxPrice`, `search`, `page`, `limit`, `sortBy`) |
| `GET`  | `/products/:id` | Public | Get detailed product information, images, and farmer details |
| `GET`  | `/categories` | Public | List all produce categories |

### 2.3 Farmer Portal (`/farmers`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET`  | `/farmers/me` | Farmer | Get farm profile details |
| `PUT`  | `/farmers/me` | Farmer | Update farm profile information |
| `GET`  | `/farmers/me/products` | Farmer | List all products belonging to authenticated farmer |
| `POST` | `/farmers/me/products` | Farmer | Create a new produce listing |
| `PUT`  | `/farmers/me/products/:id` | Farmer (Owner) | Update existing produce listing |
| `DELETE`| `/farmers/me/products/:id` | Farmer (Owner) | Delete produce listing |
| `GET`  | `/farmers/me/orders` | Farmer | List orders received for farmer's produce |
| `GET`  | `/farmers/me/sales` | Farmer | View sales history, earnings, and analytics |

### 2.4 Shopping Cart (`/cart`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET`  | `/cart` | Consumer | Retrieve consumer's shopping cart |
| `POST` | `/cart/items` | Consumer | Add product item to cart |
| `PUT`  | `/cart/items/:id` | Consumer | Update cart item quantity |
| `DELETE`| `/cart/items/:id` | Consumer | Remove item from cart |
| `DELETE`| `/cart` | Consumer | Clear entire shopping cart |

### 2.5 Order Management (`/orders`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/orders` | Consumer | Place a new order (Triggers server-side price recalculation & stock locking) |
| `GET`  | `/orders` | Authenticated | List orders (Consumer gets own orders; Farmer gets sales orders) |
| `GET`  | `/orders/:id` | Authenticated | Get full order details & status history |
| `PATCH`| `/orders/:id/status` | Farmer / Admin | Transition order status (`CONFIRMED`, `PREPARING`, `READY_FOR_PICKUP`) |
| `GET`  | `/orders/:id/tracking` | Consumer / Admin | Get real-time delivery status & milestone updates |

### 2.6 Delivery Management (`/delivery`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET`  | `/delivery/assignments` | Delivery | List available or assigned delivery jobs |
| `POST` | `/delivery/:id/accept` | Delivery | Accept delivery assignment for an order |
| `PATCH`| `/delivery/:id/status` | Delivery | Update delivery lifecycle (`PICKED_UP`, `OUT_FOR_DELIVERY`, `DELIVERED`) |

### 2.7 Ratings, Reviews & Wishlist (`/reviews`, `/wishlist`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET`  | `/products/:id/reviews` | Public | List reviews for a specific product |
| `POST` | `/reviews` | Consumer | Post review for a verified purchase (1-5 stars) |
| `GET`  | `/wishlist` | Consumer | View consumer's wishlist items |
| `POST` | `/wishlist/:productId` | Consumer | Add product to wishlist |
| `DELETE`| `/wishlist/:productId` | Consumer | Remove product from wishlist |

### 2.8 Push Notifications (`/notifications`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET`  | `/notifications` | Authenticated | List user notifications |
| `PATCH`| `/notifications/:id/read` | Authenticated | Mark notification as read |
| `POST` | `/notifications/device-token`| Authenticated | Register FCM token for push notifications |

### 2.9 Administrator Portal (`/admin`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET`  | `/admin/dashboard` | Admin | Get platform metrics (GMV, user counts, order statistics) |
| `GET`  | `/admin/users` | Admin | List all registered users across all roles |
| `PATCH`| `/admin/users/:id/status` | Admin | Activate / deactivate user account |
| `GET`  | `/admin/products` | Admin | Admin product catalog moderation |
| `GET`  | `/admin/orders` | Admin | Platform-wide order overview |
