package com.example.auto_parts.controller.admin;

import com.example.auto_parts.entity.Product;
import com.example.auto_parts.service.admin.ProductAdminService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/products")
public class ProductAdminController {

    private final ProductAdminService productAdminService;

    public ProductAdminController(ProductAdminService productAdminService) {
        this.productAdminService = productAdminService;
    }

    // Ajouter produit
    @PostMapping
    public Product addProduct(@RequestBody Product product) {
        return productAdminService.addProduct(product);
    }

    // Liste produits
    @GetMapping
    public List<Product> getAllProducts() {
        return productAdminService.getAllProducts();
    }

    // Produit par ID
    @GetMapping("/{id}")
    public Product getProductById(@PathVariable Long id) {
        return productAdminService.getProductById(id);
    }

    // Update produit
    @PutMapping("/{id}")
    public Product updateProduct(@PathVariable Long id, @RequestBody Product product) {
        return productAdminService.updateProduct(id, product);
    }

    // Delete produit
    @DeleteMapping("/{id}")
    public void deleteProduct(@PathVariable Long id) {
        productAdminService.deleteProduct(id);
    }
}