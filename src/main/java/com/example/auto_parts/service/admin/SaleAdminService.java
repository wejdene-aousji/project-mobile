package com.example.auto_parts.service.admin;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderStatus;
import com.example.auto_parts.repository.OrderRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SaleAdminService {

    private final OrderRepository orderRepository;

    public SaleAdminService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    // CREATE SALE (GENERAL)
    public Order createSale(Order order) {
        order.setStatus(order.getStatus() != null ? order.getStatus() : OrderStatus.CONFIRMED);
        return orderRepository.save(order);
    }

    // ONLINE SALE
    public Order createOnlineSale(Order order) {
        order.setPaymentMethod("ONLINE");
        order.setStatus(OrderStatus.CONFIRMED);
        return orderRepository.save(order);
    }

    // IN STORE SALE
    public Order createInStoreSale(Order order) {
        order.setPaymentMethod("CASH");
        order.setStatus(OrderStatus.CONFIRMED);
        return orderRepository.save(order);
    }

    // GET ALL SALES
    public List<Order> getAllSales() {
        return orderRepository.findAll();
    }

    // GET SALES BY STATUS
    public List<Order> getSalesByStatus(OrderStatus status) {
        return orderRepository.findByStatus(status);
    }
}