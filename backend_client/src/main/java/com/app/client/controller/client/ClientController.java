package com.app.client.controller.client;

import com.app.client.dto.OrderRequest;
import com.app.client.dto.OrderResponse;
import com.app.client.dto.ProductResponse;
import com.app.client.dto.ProfileResponse;
import com.app.client.dto.QuoteRequest;
import com.app.client.dto.QuoteResponse;
import com.app.client.dto.UpdateProfileRequest;
import com.app.client.enums.OrderStatus;
import com.app.client.enums.QuoteStatus;
import com.app.client.service.client.ClientService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/client")
@RequiredArgsConstructor
@Slf4j
public class ClientController {

    private final ClientService clientService;

    @GetMapping("/products")
    public ResponseEntity<List<ProductResponse>> getProducts(@RequestParam(required = false) String search) {
        log.debug("Fetching available products with search: {}", search);
        return ResponseEntity.ok(clientService.getAllProducts(search));
    }

    @GetMapping("/products/{id}")
    public ResponseEntity<ProductResponse> getProduct(@PathVariable Long id) {
        log.debug("Fetching product with id: {}", id);
        return ResponseEntity.ok(clientService.getProductById(id));
    }

    @PostMapping("/orders")
    public ResponseEntity<OrderResponse> createOrder(@RequestBody @Valid OrderRequest request,
                                                     Authentication auth) {
        log.info("Creating order for user: {}, items: {}", auth.getName(), request.getItems().size());
        return ResponseEntity.ok(clientService.createOrder(auth.getName(), request));
    }

    @GetMapping("/orders")
    public ResponseEntity<List<OrderResponse>> getMyOrders(Authentication auth,
                                                           @RequestParam(required = false) OrderStatus status) {
        log.debug("Fetching orders for user: {}, status: {}", auth.getName(), status);
        return ResponseEntity.ok(clientService.getMyOrders(auth.getName(), status));
    }

    @GetMapping("/orders/{id}")
    public ResponseEntity<OrderResponse> getOrderById(@PathVariable Long id, Authentication auth) {
        log.debug("Fetching order id: {} for user: {}", id, auth.getName());
        return ResponseEntity.ok(clientService.getOrderById(id, auth.getName()));
    }

    @PostMapping("/quotes")
    public ResponseEntity<QuoteResponse> createQuote(@RequestBody @Valid QuoteRequest request,
                                                     Authentication auth) {
        log.info("Creating quote for user: {}", auth.getName());
        return ResponseEntity.ok(clientService.createQuote(auth.getName(), request));
    }

    @GetMapping("/quotes")
    public ResponseEntity<List<QuoteResponse>> getMyQuotes(Authentication auth,
                                                           @RequestParam(required = false) QuoteStatus status) {
        log.debug("Fetching quotes for user: {}, status: {}", auth.getName(), status);
        return ResponseEntity.ok(clientService.getMyQuotes(auth.getName(), status));
    }

    @GetMapping("/profile")
    public ResponseEntity<ProfileResponse> getProfile(Authentication auth) {
        log.debug("Fetching profile for user: {}", auth.getName());
        return ResponseEntity.ok(clientService.getProfile(auth.getName()));
    }

    @PutMapping("/profile")
    public ResponseEntity<ProfileResponse> updateProfile(@RequestBody @Valid UpdateProfileRequest request,
                                                         Authentication auth) {
        log.info("Updating profile for user: {}", auth.getName());
        return ResponseEntity.ok(clientService.updateProfile(auth.getName(), request));
    }
}
