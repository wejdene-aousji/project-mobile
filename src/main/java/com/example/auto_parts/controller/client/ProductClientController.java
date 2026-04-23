package com.example.auto_parts.controller.client;

import com.example.auto_parts.entity.Product;
import com.example.auto_parts.service.client.ProductClientService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/client/products")
public class ProductClientController {

    private final ProductClientService productClientService;

    public ProductClientController(ProductClientService productClientService) {
        this.productClientService = productClientService;
    }

    @GetMapping
    public ResponseEntity<List<Product>> getProducts(@RequestParam(required = false) String search) {
        return ResponseEntity.ok(productClientService.getAllProducts(search));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        return ResponseEntity.ok(productClientService.getProductById(id));
    }
}
