package com.example.auto_parts.service.admin;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.auto_parts.entity.Product;
import com.example.auto_parts.entity.Purchase;
import com.example.auto_parts.entity.PurchaseLine;
import com.example.auto_parts.repository.ProductRepository;
import com.example.auto_parts.repository.PurchaseRepository;

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

    // Update stock
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

    // Update purchase + stock update
    public Purchase updatePurchase(Long id, Purchase updatedPurchase) {

        Purchase existingPurchase = purchaseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase not found"));

        Map<Long, PurchaseLine> oldMap = existingPurchase.getLines()
                .stream()
                .collect(Collectors.toMap(
                        l -> l.getProduct().getProductId(),
                        l -> l
                ));

        double total = 0;

        List<PurchaseLine> newLines = new ArrayList<>();

        for (PurchaseLine newLine : updatedPurchase.getLines()) {

            Long productId = newLine.getProduct().getProductId();

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product not found"));

            PurchaseLine oldLine = oldMap.get(productId);

            int oldQty = (oldLine != null) ? oldLine.getQuantity() : 0;
            int newQty = newLine.getQuantity();

            int delta = newQty - oldQty;

            // PURCHASE = STOCK UP
            product.setStockQuantity(product.getStockQuantity() + delta);
            productRepository.save(product);

            PurchaseLine lineToSave = (oldLine != null) ? oldLine : new PurchaseLine();

            lineToSave.setPurchase(existingPurchase);
            lineToSave.setProduct(product);
            lineToSave.setQuantity(newQty);

            double unitCost = product.getPriceTTC();
            double subtotal = unitCost * newQty;

            lineToSave.setUnitCost(unitCost);
            lineToSave.setSubtotal(subtotal);

            total += subtotal;

            newLines.add(lineToSave);
        }

        // handle deleted lines
        for (PurchaseLine oldLine : existingPurchase.getLines()) {

            boolean exists = updatedPurchase.getLines().stream()
                    .anyMatch(l -> l.getProduct().getProductId()
                            .equals(oldLine.getProduct().getProductId()));

            if (!exists) {

                Product product = oldLine.getProduct();

                product.setStockQuantity(
                        product.getStockQuantity() - oldLine.getQuantity()
                );

                productRepository.save(product);
            }
        }

        existingPurchase.getLines().clear();
        existingPurchase.getLines().addAll(newLines);

        existingPurchase.setTotalCost(total);

        return purchaseRepository.save(existingPurchase);
    }

}