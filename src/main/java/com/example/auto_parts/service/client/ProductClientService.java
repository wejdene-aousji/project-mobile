package com.example.auto_parts.service.client;

import com.example.auto_parts.entity.Product;
import com.example.auto_parts.exception.ResourceNotFoundException;
import com.example.auto_parts.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductClientService {

    private final ProductRepository productRepository;

    public ProductClientService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public List<Product> getAllProducts(String search) {
        return (search != null && !search.isBlank())
                ? productRepository.findByStockQuantityGreaterThanAndNameContainingIgnoreCase(0, search.trim())
                : productRepository.findAvailableProducts();
    }

    public Product getProductById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product", "id", id));
    }
}
