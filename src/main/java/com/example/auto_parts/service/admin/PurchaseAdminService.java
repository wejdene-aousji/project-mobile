package com.example.auto_parts.service.admin;

import com.example.auto_parts.entity.Product;
import com.example.auto_parts.entity.Purchase;
import com.example.auto_parts.entity.PurchaseLine;
import com.example.auto_parts.repository.ProductRepository;
import com.example.auto_parts.repository.PurchaseRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PurchaseAdminService {

    private final PurchaseRepository purchaseRepository;
    private final ProductRepository productRepository;

    public PurchaseAdminService(PurchaseRepository purchaseRepository,
                                ProductRepository productRepository) {
        this.purchaseRepository = purchaseRepository;
        this.productRepository = productRepository;
    }

    // Create purchase + stock update
    public Purchase createPurchase(Purchase purchase) {

        double total = 0;

        for (PurchaseLine line : purchase.getLines()) {

            Product product = productRepository.findById(
                    line.getProduct().getProductId()
            ).orElseThrow(() -> new RuntimeException("Product not found"));

            line.setPurchase(purchase);

            double subtotal = line.getQuantity() * line.getUnitCost();
            line.setSubtotal(subtotal);

            total += subtotal;

            // Stock update
            product.setStockQuantity(product.getStockQuantity() + line.getQuantity());
            productRepository.save(product);
        }

        purchase.setTotalCost(total);

        return purchaseRepository.save(purchase);
    }

    // Get all purchases
    public List<Purchase> getAllPurchases() {
        return purchaseRepository.findAll();
    }

    // Update stock after purchase deletion
    public void updatePurchaseStock(Long purchaseId) {

        Purchase purchase = purchaseRepository.findById(purchaseId)
                .orElseThrow(() -> new RuntimeException("Purchase not found"));

        for (PurchaseLine line : purchase.getLines()) {

            Product product = line.getProduct();

            product.setStockQuantity(
                    product.getStockQuantity() + line.getQuantity()
            );

            productRepository.save(product);
        }
    }
}