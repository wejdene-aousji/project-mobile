# Auto Parts Backend

Spring Boot backend for the auto parts application.

## Requirements

- Java 17
- MySQL

Database name:

```text
auto_parts
```

Base URL:

```text
http://localhost:8080
```

Run:

```powershell
.\mvnw.cmd spring-boot:run
```

## Authentication

Authentication is based on JWT.

Public endpoints:

`POST /api/auth/register`

`POST /api/auth/login`

Protected routes:

`/api/client/**`

`/admin/**`

Register request:

```json
{
  "fullName": "Ali Test",
  "email": "ali@test.com",
  "password": "123456",
  "phone": "12345678"
}
```

Login request:

```json
{
  "email": "ali@test.com",
  "password": "123456"
}
```

Login response:

```json
{
  "token": "jwt_here",
  "role": "CLIENT",
  "email": "ali@test.com",
  "fullName": "Ali Test"
}
```

Use the token in protected requests:

```text
Authorization: Bearer YOUR_TOKEN
```

## Main Endpoints

### Products

`GET /api/client/products`

`GET /api/client/products/{id}`

`POST /admin/products`

`GET /admin/products`

`GET /admin/products/{id}`

`PUT /admin/products/{id}`

`PATCH /admin/products/{id}`

`DELETE /admin/products/{id}`

`PUT /admin/products/{id}/stock?quantity=10`

`GET /admin/products/{id}/stock`

### Orders and Sales

`POST /api/client/orders`

`GET /api/client/orders`

`GET /api/client/orders/{id}`

`POST /admin/sales`

`POST /admin/sales/online`

`POST /admin/sales/store`

`GET /admin/sales`

`GET /admin/sales/status/{status}`

`PUT /admin/sales/{id}/cancel`

Client order body:

```json
{
  "orderLines": [
    {
      "product": {
        "productId": 1
      },
      "quantity": 2
    }
  ]
}
```

### Quotes

`POST /api/client/quotes`

`GET /api/client/quotes`

`GET /admin/quotes`

`PUT /admin/quotes/{id}/approve`

`PUT /admin/quotes/{id}/reject`

`GET /admin/quotes/status/{status}`

Client quote body:

```json
{
  "message": "I need a quote for brake pads"
}
```

### Profile and Customers

`GET /api/client/profile`

`PUT /api/client/profile`

`GET /admin/customers`

`GET /admin/customers/{id}`

`PUT /admin/customers/{id}`

`DELETE /admin/customers/{id}`

Profile update body:

```json
{
  "fullName": "Ali Updated",
  "phone": "99887766",
  "password": "newpass123"
}
```

### Suppliers

`POST /admin/suppliers`

`GET /admin/suppliers`

`PUT /admin/suppliers/{id}`

`DELETE /admin/suppliers/{id}`

### Purchases

`POST /admin/purchases`

`GET /admin/purchases`

`PUT /admin/purchases/{id}/stock`

### Statistics

`GET /admin/stats/daily-sales`

`GET /admin/stats/daily-revenue`

`GET /admin/stats/period-revenue?start=2026-04-01&end=2026-04-30`

`GET /admin/stats/top-products`

`GET /admin/stats/low-products`

## Notes

- `register` creates a client account
- `login` works for both `CLIENT` and `ADMIN`
- `password` is not returned in JSON
