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

    // create general sale
    @PostMapping
    public Order createSale(@RequestBody Order order) {
        return saleAdminService.createSale(order);
    }

    // online sale
    @PostMapping("/online")
    public Order createOnlineSale(@RequestBody Order order) {
        return saleAdminService.createOnlineSale(order);
    }

    // in store sale
    @PostMapping("/store")
    public Order createInStoreSale(@RequestBody Order order) {
        return saleAdminService.createInStoreSale(order);
    }

    // get all sales
    @GetMapping
    public List<Order> getAllSales() {
        return saleAdminService.getAllSales();
    }

    @GetMapping("/status/{status}")
    public List<Order> getSalesByStatus(@PathVariable OrderStatus status) {
        return saleAdminService.getSalesByStatus(status);
    }
}