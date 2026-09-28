# FarmDirect (Vayal 2 Veedu) — Database ER Design & Prisma Schema

## 1. Entity-Relationship (ER) Architecture

The database architecture is built on **PostgreSQL** using **Prisma ORM**. The schema strictly models all four domain roles, product catalog, cart lifecycle, order fulfillment, payments, delivery tracking, customer reviews, wishlists, and notifications.

### Entity List & Core Relations
- `User` 1 ── 0..1 `FarmerProfile`
- `User` 1 ── 0..1 `ConsumerProfile`
- `User` 1 ── 0..1 `DeliveryProfile`
- `User` 1 ── 0..* `Address`
- `User` 1 ── 0..* `DeviceToken`
- `FarmerProfile` 1 ── 0..* `Product`
- `Category` 1 ── 0..* `Product`
- `Product` 1 ── 0..* `ProductImage`
- `ConsumerProfile` 1 ── 0..1 `Cart`
- `Cart` 1 ── 0..* `CartItem`
- `Product` 1 ── 0..* `CartItem`
- `ConsumerProfile` 1 ── 0..* `Order`
- `FarmerProfile` 1 ── 0..* `Order`
- `Order` 1 ── 1..* `OrderItem`
- `Order` 1 ── 0..1 `Payment`
- `Order` 1 ── 0..1 `Delivery`
- `DeliveryProfile` 1 ── 0..* `Delivery`
- `Order` 1 ── 0..* `OrderStatusHistory`
- `ConsumerProfile` 1 ── 0..* `Review`
- `Product` 1 ── 0..* `Review`
- `ConsumerProfile` 1 ── 0..1 `Wishlist`
- `Wishlist` 1 ── 0..* `WishlistItem`
- `User` 1 ── 0..* `Notification`

---

## 2. Complete Prisma Schema Draft (`schema.prisma`)

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

enum Role {
  FARMER
  CONSUMER
  DELIVERY_PARTNER
  ADMIN
}

enum OrderStatus {
  PLACED
  CONFIRMED
  PREPARING
  READY_FOR_PICKUP
  PICKED_UP
  OUT_FOR_DELIVERY
  DELIVERED
  CANCELLED
}

enum PaymentStatus {
  PENDING
  SUCCESS
  FAILED
  REFUNDED
}

enum PaymentMethod {
  CASH_ON_DELIVERY
  TEST_PAYMENT_GATEWAY
  ONLINE_UPI
  CARD
}

enum DeliveryStatus {
  ASSIGNED
  ACCEPTED
  PICKED_UP
  IN_TRANSIT
  DELIVERED
  FAILED
}

model User {
  id              String           @id @default(uuid())
  email           String           @unique
  phone           String           @unique
  passwordHash    String
  role            Role
  name            String
  profileImageUrl String?
  isActive        Boolean          @default(true)
  createdAt       DateTime         @default(now())
  updatedAt       DateTime         @updatedAt

  farmerProfile   FarmerProfile?
  consumerProfile ConsumerProfile?
  deliveryProfile DeliveryProfile?
  addresses       Address[]
  deviceTokens    DeviceToken[]
  notifications   Notification[]
  refreshTokens   RefreshToken[]

  @@index([email])
  @@index([phone])
  @@index([role])
}

model RefreshToken {
  id        String   @id @default(uuid())
  token     String   @unique
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  isRevoked Boolean  @default(false)
  expiresAt DateTime
  createdAt DateTime @default(now())
}

model Address {
  id           String    @id @default(uuid())
  userId       String
  user         User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  street       String
  city         String
  state        String
  postalCode   String
  landmark     String?
  latitude     Float?
  longitude    Float?
  isDefault    Boolean   @default(false)
  createdAt    DateTime  @default(now())

  orders       Order[]
}

model FarmerProfile {
  id             String    @id @default(uuid())
  userId         String    @unique
  user           User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  farmName       String
  farmAddress    String
  farmLatitude   Float?
  farmLongitude  Float?
  bio            String?
  isVerified     Boolean   @default(false)
  createdAt      DateTime  @default(now())
  updatedAt      DateTime  @updatedAt

  products       Product[]
  orders         Order[]
}

model ConsumerProfile {
  id             String         @id @default(uuid())
  userId         String         @unique
  user           User           @relation(fields: [userId], references: [id], onDelete: Cascade)
  createdAt      DateTime       @default(now())
  updatedAt      DateTime       @updatedAt

  cart           Cart?
  orders         Order[]
  reviews        Review[]
  wishlist       Wishlist?
}

model DeliveryProfile {
  id             String         @id @default(uuid())
  userId         String         @unique
  user           User           @relation(fields: [userId], references: [id], onDelete: Cascade)
  vehicleType    String
  vehicleNumber  String
  licenseNumber  String
  isAvailable    Boolean        @default(true)
  createdAt      DateTime       @default(now())
  updatedAt      DateTime       @updatedAt

  deliveries     Delivery[]
}

model Category {
  id           String    @id @default(uuid())
  name         String    @unique
  slug         String    @unique
  description  String?
  imageUrl     String?
  createdAt    DateTime  @default(now())

  products     Product[]
}

model Product {
  id             String         @id @default(uuid())
  farmerId       String
  farmer         FarmerProfile  @relation(fields: [farmerId], references: [id], onDelete: Cascade)
  categoryId     String
  category       Category       @relation(fields: [categoryId], references: [id])
  name           String
  description    String
  price          Decimal        @db.Decimal(10, 2)
  unit           String         // e.g. "kg", "bunch", "liter"
  stock          Decimal        @db.Decimal(10, 2)
  isPublished    Boolean        @default(true)
  averageRating  Float          @default(0.0)
  totalReviews   Int            @default(0)
  createdAt      DateTime       @default(now())
  updatedAt      DateTime       @updatedAt

  images         ProductImage[]
  cartItems      CartItem[]
  orderItems     OrderItem[]
  reviews        Review[]
  wishlistItems  WishlistItem[]

  @@index([farmerId])
  @@index([categoryId])
  @@index([isPublished])
  @@index([price])
}

model ProductImage {
  id        String   @id @default(uuid())
  productId String
  product   Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  url       String
  isPrimary Boolean  @default(false)
}

model Cart {
  id         String     @id @default(uuid())
  consumerId String     @unique
  consumer   ConsumerProfile @relation(fields: [consumerId], references: [id], onDelete: Cascade)
  createdAt  DateTime   @default(now())
  updatedAt  DateTime   @updatedAt

  items      CartItem[]
}

model CartItem {
  id        String   @id @default(uuid())
  cartId    String
  cart      Cart     @relation(fields: [cartId], references: [id], onDelete: Cascade)
  productId String
  product   Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  quantity  Decimal  @db.Decimal(10, 2)
  createdAt DateTime @default(now())

  @@unique([cartId, productId])
}

model Order {
  id               String               @id @default(uuid())
  orderNumber      String               @unique
  consumerId       String
  consumer         ConsumerProfile      @relation(fields: [consumerId], references: [id])
  farmerId         String
  farmer           FarmerProfile        @relation(fields: [farmerId], references: [id])
  addressId        String
  deliveryAddress  Address              @relation(fields: [addressId], references: [id])
  subtotal         Decimal              @db.Decimal(10, 2)
  deliveryFee      Decimal              @db.Decimal(10, 2)
  discount         Decimal              @default(0.00) @db.Decimal(10, 2)
  totalAmount      Decimal              @db.Decimal(10, 2)
  status           OrderStatus          @default(PLACED)
  createdAt        DateTime             @default(now())
  updatedAt        DateTime             @updatedAt

  items            OrderItem[]
  payment          Payment?
  delivery         Delivery?
  statusHistory    OrderStatusHistory[]

  @@index([consumerId])
  @@index([farmerId])
  @@index([status])
}

model OrderItem {
  id          String   @id @default(uuid())
  orderId     String
  order       Order    @relation(fields: [orderId], references: [id], onDelete: Cascade)
  productId   String
  product     Product  @relation(fields: [productId], references: [id])
  productName String
  unitPrice   Decimal  @db.Decimal(10, 2)
  quantity    Decimal  @db.Decimal(10, 2)
  totalPrice  Decimal  @db.Decimal(10, 2)
}

model OrderStatusHistory {
  id        String      @id @default(uuid())
  orderId   String
  order     Order       @relation(fields: [orderId], references: [id], onDelete: Cascade)
  status    OrderStatus
  note      String?
  changedBy String?     // User ID or SYSTEM
  createdAt DateTime    @default(now())
}

model Payment {
  id            String        @id @default(uuid())
  orderId       String        @unique
  order         Order         @relation(fields: [orderId], references: [id], onDelete: Cascade)
  method        PaymentMethod
  status        PaymentStatus @default(PENDING)
  transactionId String?
  amount        Decimal       @db.Decimal(10, 2)
  createdAt     DateTime      @default(now())
  updatedAt     DateTime      @updatedAt
}

model Delivery {
  id                String          @id @default(uuid())
  orderId           String          @unique
  order             Order           @relation(fields: [orderId], references: [id], onDelete: Cascade)
  deliveryPartnerId String?
  deliveryPartner   DeliveryProfile? @relation(fields: [deliveryPartnerId], references: [id])
  status            DeliveryStatus  @default(ASSIGNED)
  pickupTime        DateTime?
  deliveredTime     DateTime?
  createdAt         DateTime        @default(now())
  updatedAt         DateTime        @updatedAt
}

model Review {
  id         String          @id @default(uuid())
  consumerId String
  consumer   ConsumerProfile @relation(fields: [consumerId], references: [id], onDelete: Cascade)
  productId  String
  product    Product         @relation(fields: [productId], references: [id], onDelete: Cascade)
  rating     Int             // 1 to 5
  comment    String?
  createdAt  DateTime        @default(now())

  @@unique([consumerId, productId])
}

model Wishlist {
  id         String         @id @default(uuid())
  consumerId String         @unique
  consumer   ConsumerProfile @relation(fields: [consumerId], references: [id], onDelete: Cascade)
  createdAt  DateTime       @default(now())

  items      WishlistItem[]
}

model WishlistItem {
  id         String   @id @default(uuid())
  wishlistId String
  wishlist   Wishlist @relation(fields: [wishlistId], references: [id], onDelete: Cascade)
  productId  String
  product    Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  createdAt  DateTime @default(now())

  @@unique([wishlistId, productId])
}

model DeviceToken {
  id        String   @id @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  token     String   @unique
  deviceOs  String?  // android / ios
  createdAt DateTime @default(now())
}

model Notification {
  id        String   @id @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  title     String
  body      String
  data      Json?
  isRead    Boolean  @default(false)
  createdAt DateTime @default(now())
}
```
