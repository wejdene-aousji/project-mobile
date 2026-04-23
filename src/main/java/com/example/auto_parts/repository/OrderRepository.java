package com.example.auto_parts.repository;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderStatus;
import com.example.auto_parts.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByStatus(OrderStatus status);
    List<Order> findByUserOrderByCreatedAtDesc(User user);
    List<Order> findByUserAndStatusOrderByCreatedAtDesc(User user, OrderStatus status);
}
