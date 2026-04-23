package com.example.auto_parts.controller.admin;

import com.example.auto_parts.service.admin.StatsAdminService;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/admin/stats")
public class StatsAdminController {

    private final StatsAdminService statsAdminService;

    public StatsAdminController(StatsAdminService statsAdminService) {
        this.statsAdminService = statsAdminService;
    }

    // Daily sales
    @GetMapping("/daily-sales")
    public Map<LocalDate, Long> getDailySalesStats() {
        return statsAdminService.getDailySalesStats();
    }

    // Daily revenue
    @GetMapping("/daily-revenue")
    public Map<LocalDate, Double> getDailyRevenue() {
        return statsAdminService.getDailyRevenue();
    }

    // Period revenue
    @GetMapping("/period-revenue")
    public Double getPeriodRevenue(
            @RequestParam LocalDate start,
            @RequestParam LocalDate end) {
        return statsAdminService.getPeriodRevenue(start, end);
    }

    // Top selling
    @GetMapping("/top-products")
    public Map<Long, Integer> getTopSellingArticles() {
        return statsAdminService.getTopSellingArticles();
    }

    // Low selling
    @GetMapping("/low-products")
    public Map<Long, Integer> getLowSellingArticles() {
        return statsAdminService.getLowSellingArticles();
    }
}