# Client Backend API

Spring Boot backend for the customer side of the auto parts application.

## Tech Stack

- Java 17
- Spring Boot
- Spring Security + JWT
- Spring Data JPA
- MySQL

## Run The Project

1. Create a MySQL database named `auto_parts`.
2. Update database credentials in `src/main/resources/application.properties` if needed.
3. Start the Spring Boot application from your IDE.
4. Default base URL:

```text
http://localhost:8080
```

## Authentication Flow

1. Call `POST /api/auth/register` to create a customer account.
2. Call `POST /api/auth/login` to get a JWT token.
3. Send the token in protected requests:

```text
Authorization: Bearer YOUR_TOKEN
```

## Endpoints

### Auth

- `POST /api/auth/register`
- `POST /api/auth/login`

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

### Client

- `GET /api/client/products`
- `GET /api/client/products/{id}`
- `POST /api/client/orders`
- `GET /api/client/orders`
- `GET /api/client/orders/{id}`
- `POST /api/client/quotes`
- `GET /api/client/quotes`
- `GET /api/client/profile`
- `PUT /api/client/profile`

Optional query params:

- `GET /api/client/products?search=oil`
- `GET /api/client/orders?status=PENDING`
- `GET /api/client/quotes?status=ACCEPTED`

Create order request:

```json
{
  "items": [
    {
      "productId": 1,
      "quantity": 2
    }
  ]
}
```

Create quote request:

```json
{
  "message": "I need a quote for bulk purchase of brake pads."
}
```

Update profile request:

```json
{
  "fullName": "Ali Updated",
  "phone": "99887766",
  "password": "newpass123"
}
```

## Important Business Rules

- Online orders are always created with `CASH_ON_DELIVERY`.
- Customers can only access their own orders.
- Products must have enough stock before an order is created.

## Postman Test Order

1. `POST /api/auth/register`
2. `POST /api/auth/login`
3. Copy the JWT token
4. Add `Bearer Token` authorization in Postman
5. `GET /api/client/products`
6. `GET /api/client/profile`
7. `PUT /api/client/profile`
8. `POST /api/client/quotes`
9. `POST /api/client/orders`
10. `GET /api/client/orders`
11. `GET /api/client/orders/{id}`

## Notes For Teammates

- Frontend teammate needs the base URL, endpoint list, JWT flow, and sample JSON bodies.
- Admin/backend teammate should align shared data like users, orders, order status, and quotes.
- Product data must already exist in the database before testing order creation.
