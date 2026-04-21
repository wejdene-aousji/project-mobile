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

        double ht = product.getPurchasePrice() * 1.19;
        double ttc = ht * 1.4;

        product.setPriceHT(ht);
        product.setPriceTTC(ttc);

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

        if (product.getPurchasePrice() != null) {
            p.setPurchasePrice(product.getPurchasePrice());

            double ht = product.getPurchasePrice() * 1.19;
            double ttc = ht * 1.4;

            p.setPriceHT(ht);
            p.setPriceTTC(ttc);
        }

        if (product.getName() != null) p.setName(product.getName());
        if (product.getCode() != null) p.setCode(product.getCode());
        if (product.getStockQuantity() != null) p.setStockQuantity(product.getStockQuantity());
        if (product.getUrl() != null) p.setUrl(product.getUrl());

        return productRepository.save(p);
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