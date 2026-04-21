package com.example.auto_parts.controller.admin;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderStatus;
import com.example.auto_parts.service.admin.SaleAdminService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/sales")
public class SaleAdminController {

    private final SaleAdminService saleAdminService;

    public SaleAdminController(SaleAdminService saleAdminService) {
        this.saleAdminService = saleAdminService;
    }

    // Create general sale
    @PostMapping
    public Order createSale(@RequestBody Order order) {
        return saleAdminService.createSale(order);
    }

    // Create online sale
    @PostMapping("/online")
    public Order createOnlineSale(@RequestBody Order order) {
        return saleAdminService.createOnlineSale(order);
    }

    // Create in-store sale
    @PostMapping("/store")
    public Order createInStoreSale(@RequestBody Order order) {
        return saleAdminService.createInStoreSale(order);
    }

    // Get all sales
    @GetMapping
    public List<Order> getAllSales() {
        return saleAdminService.getAllSales();
    }

    // Get sale by status
    @GetMapping("/status/{status}")
    public List<Order> getSalesByStatus(@PathVariable OrderStatus status) {
        return saleAdminService.getSalesByStatus(status);
    }

    // Cancel sale
    @PutMapping("/{id}/cancel")
    public Order cancelSale(@PathVariable Long id) {
        return saleAdminService.cancelSale(id);
    }
}