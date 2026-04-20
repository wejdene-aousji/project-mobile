package com.example.auto_parts.service.admin;

import com.example.auto_parts.entity.Product;
import com.example.auto_parts.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductAdminService {

    private final ProductRepository productRepository;

    public ProductAdminService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public Product addProduct(Product product) {
        return productRepository.save(product);
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Product getProductById(Long id) {
        return productRepository.findById(id).orElse(null);
    }

    public Product updateProduct(Long id, Product product) {
    Product p = getProductById(id);

    if (p != null) {
        p.setName(product.getName());
        p.setCode(product.getCode());
        p.setPriceHT(product.getPriceHT());
        p.setPriceTTC(product.getPriceTTC());
        p.setPurchasePrice(product.getPurchasePrice());
        p.setStockQuantity(product.getStockQuantity());
        p.setUrl(product.getUrl());

        return productRepository.save(p);
    }

    return null;
}

    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    // mettre à jour le stock
    public Product updateStock(Long id, Integer quantity) {
        Product product = getProductById(id);

        if (product != null) {
            product.setStockQuantity(quantity);
            return productRepository.save(product);
        }

        return null;
    }

    // obtenir le niveau du stock
    public Integer getStockLevel(Long id) {
    Product product = getProductById(id);

    if (product != null) {
        return product.getStockQuantity();
    }

    return null;
}
}