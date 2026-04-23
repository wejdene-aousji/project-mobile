package com.example.auto_parts.controller.client;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderStatus;
import com.example.auto_parts.service.client.OrderClientService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/client/orders")
public class OrderClientController {

    private final OrderClientService orderClientService;

    public OrderClientController(OrderClientService orderClientService) {
        this.orderClientService = orderClientService;
    }

    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody Order order, Authentication auth) {
        return ResponseEntity.ok(orderClientService.createOrder(auth.getName(), order));
    }

    @GetMapping
    public ResponseEntity<List<Order>> getMyOrders(Authentication auth,
                                                   @RequestParam(required = false) OrderStatus status) {
        return ResponseEntity.ok(orderClientService.getMyOrders(auth.getName(), status));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(@PathVariable Long id, Authentication auth) {
        return ResponseEntity.ok(orderClientService.getOrderById(id, auth.getName()));
    }
}
