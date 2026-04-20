package com.example.auto_parts.repository;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByStatus(OrderStatus status);
}