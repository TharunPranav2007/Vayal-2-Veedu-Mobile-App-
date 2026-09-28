# FarmDirect (Vayal 2 Veedu) — Role Permissions & Authorization Matrix

## 1. Role-Permission Matrix

| Resource / Action | FARMER | CONSUMER | DELIVERY_PARTNER | ADMIN |
| :--- | :---: | :---: | :---: | :---: |
| **Authentication & Profile** |
| Register / Login | YES | YES | YES | YES |
| Manage Personal Profile | OWN | OWN | OWN | ALL |
| Manage Farm Details | OWN | NO | NO | READ / WRITE |
| Manage Delivery Vehicle Info | NO | NO | OWN | READ / WRITE |
| **Product Management** |
| View Product Catalog | YES | YES | YES | YES |
| Create Product Listing | YES | NO | NO | YES |
| Update / Delete Product | OWN | NO | NO | ALL |
| Toggle Stock Availability | OWN | NO | NO | ALL |
| **Cart & Wishlist** |
| Manage Shopping Cart | NO | OWN | NO | NO |
| Manage Wishlist | NO | OWN | NO | NO |
| **Order Lifecycle** |
| Place Order | NO | YES | NO | NO |
| View Orders | OWN (Sales) | OWN (Purchases) | ASSIGNED | ALL |
| Accept / Process Order | OWN | NO | NO | ALL |
| Update Order Status (Preparing) | OWN | NO | NO | ALL |
| Update Delivery Status | NO | NO | ASSIGNED | ALL |
| Cancel Order | NO | OWN (Before Confirm) | NO | ALL |
| **Reviews & Ratings** |
| Post Review | NO | OWN (Purchased) | NO | NO |
| Moderate Reviews | NO | NO | NO | ALL |
| **Platform Administration** |
| View Platform Dashboard | NO | NO | NO | YES |
| User Status Toggle (Activate/Deactivate)| NO | NO | NO | YES |
| Platform Configuration | NO | NO | NO | YES |

---

## 2. Backend Authorization Guard Architecture

Backend authorization is enforced at two distinct levels in NestJS:

```
[Incoming HTTP Request]
          │
          ▼
[JwtAuthGuard] (Verifies JWT signature & attaches req.user)
          │
          ▼
[RolesGuard] (Verifies req.user.role satisfies @Roles() decorator)
          │
          ▼
[ResourceOwnershipGuard] (Verifies req.user.id owns target entity ID)
          │
          ▼
[Controller Handler]
```

### 2.1 Role Guard Code Architecture (`RolesGuard`)
```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) {
      return true;
    }
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.includes(user.role);
  }
}
```

### 2.2 Resource Ownership Guard Logic
To prevent unauthorized cross-user data access (Insecure Direct Object Reference - IDOR):
- **Farmer Products:** `product.farmerId === req.user.farmerProfile.id || req.user.role === Role.ADMIN`
- **Consumer Cart/Orders/Wishlist:** `order.consumerId === req.user.consumerProfile.id || req.user.role === Role.ADMIN`
- **Delivery Partner Assignments:** `delivery.deliveryPartnerId === req.user.deliveryProfile.id || req.user.role === Role.ADMIN`
