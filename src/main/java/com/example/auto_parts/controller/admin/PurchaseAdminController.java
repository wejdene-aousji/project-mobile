package com.example.auto_parts.controller.admin;

import com.example.auto_parts.entity.Purchase;
import com.example.auto_parts.service.admin.PurchaseAdminService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/purchases")
public class PurchaseAdminController {

    private final PurchaseAdminService purchaseAdminService;

    public PurchaseAdminController(PurchaseAdminService purchaseAdminService) {
        this.purchaseAdminService = purchaseAdminService;
    }

    // Create purchase
    @PostMapping
    public Purchase createPurchase(@RequestBody Purchase purchase) {
        return purchaseAdminService.createPurchase(purchase);
    }

    // Get all purchases
    @GetMapping
    public List<Purchase> getAllPurchases() {
        return purchaseAdminService.getAllPurchases();
    }

    // Update stock for a purchase
    @PutMapping("/{id}/stock")
    public void updatePurchaseStock(@PathVariable Long id) {
        purchaseAdminService.updatePurchaseStock(id);
    }

    // Update purchase
    @PutMapping("/{id}")
    public Purchase updatePurchase(
            @PathVariable Long id,
            @RequestBody Purchase purchase) {

        return purchaseAdminService.updatePurchase(id, purchase);
    }
}