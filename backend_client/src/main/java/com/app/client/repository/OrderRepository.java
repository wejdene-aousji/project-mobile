package com.app.client.repository;

import com.app.client.entity.Order;
import com.app.client.entity.User;
import com.app.client.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByCustomerOrderByCreatedAtDesc(User customer);
    List<Order> findByCustomerAndStatusOrderByCreatedAtDesc(User customer, OrderStatus status);
}
