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

    // Add product
    @PostMapping
    public Product addProduct(@RequestBody Product product) {
        return productAdminService.addProduct(product);
    }

    // List products
    @GetMapping
    public List<Product> getAllProducts() {
        return productAdminService.getAllProducts();
    }

    // Product by ID
    @GetMapping("/{id}")
    public Product getProductById(@PathVariable Long id) {
        return productAdminService.getProductById(id);
    }

    // Update product
    @RequestMapping(value = "/{id}", method = {RequestMethod.PUT, RequestMethod.PATCH})
    public Product updateProduct(@PathVariable Long id, @RequestBody Product product) {
        return productAdminService.updateProduct(id, product);
    }

    // Delete product
    @DeleteMapping("/{id}")
    public void deleteProduct(@PathVariable Long id) {
        productAdminService.deleteProduct(id);
    }

    // Update stock
    @PutMapping("/{id}/stock")
    public Product updateStock(@PathVariable Long id, @RequestParam Integer quantity) {
        return productAdminService.updateStock(id, quantity);
    }

    // Get stock level
    @GetMapping("/{id}/stock")
    public Integer getStockLevel(@PathVariable Long id) {
        return productAdminService.getStockLevel(id);
    }
}