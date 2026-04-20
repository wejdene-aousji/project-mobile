package com.example.auto_parts.service.admin;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderLine;
import com.example.auto_parts.repository.OrderRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class StatsAdminService {

    private final OrderRepository orderRepository;

    public StatsAdminService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    // DAILY SALES (nombre de commandes par jour)
    public Map<LocalDate, Long> getDailySalesStats() {
        return orderRepository.findAll()
                .stream()
                .collect(Collectors.groupingBy(
                        order -> order.getCreatedAt().toLocalDate(),
                        Collectors.counting()
                ));
    }

    // DAILY REVENUE
    public Map<LocalDate, Double> getDailyRevenue() {
        return orderRepository.findAll()
                .stream()
                .collect(Collectors.groupingBy(
                        order -> order.getCreatedAt().toLocalDate(),
                        Collectors.summingDouble(Order::getTotalPrice)
                ));
    }

    // PERIOD REVENUE
    public Double getPeriodRevenue(LocalDate start, LocalDate end) {
        return orderRepository.findAll()
                .stream()
                .filter(o -> {
                    LocalDate date = o.getCreatedAt().toLocalDate();
                    return !date.isBefore(start) && !date.isAfter(end);
                })
                .mapToDouble(Order::getTotalPrice)
                .sum();
    }

    // TOP SELLING ARTICLES
    public Map<Long, Integer> getTopSellingArticles() {
        Map<Long, Integer> map = new HashMap<>();

        for (Order order : orderRepository.findAll()) {
            for (OrderLine line : order.getOrderLines()) {

                Long productId = line.getProduct().getProductId();
                map.put(productId,
                        map.getOrDefault(productId, 0) + line.getQuantity());
            }
        }

        return map.entrySet()
                .stream()
                .sorted((a, b) -> b.getValue() - a.getValue())
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue,
                        (a, b) -> a,
                        LinkedHashMap::new
                ));
    }

    // LOW SELLING ARTICLES
    public Map<Long, Integer> getLowSellingArticles() {
        return getTopSellingArticles()
                .entrySet()
                .stream()
                .sorted(Map.Entry.comparingByValue())
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue,
                        (a, b) -> a,
                        LinkedHashMap::new
                ));
    }
}