package com.example.auto_parts.service.admin;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderLine;
import com.example.auto_parts.entity.OrderStatus;
import com.example.auto_parts.entity.Product;
import com.example.auto_parts.entity.User;
import com.example.auto_parts.repository.OrderRepository;
import com.example.auto_parts.repository.ProductRepository;
import com.example.auto_parts.repository.UserRepository;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SaleAdminService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    public SaleAdminService(OrderRepository orderRepository,
                            UserRepository userRepository,
                            ProductRepository productRepository) {
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
    }

    public Order createSale(Order order) {

        User user = userRepository.findById(order.getUser().getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        order.setUser(user);
        order.setCreatedAt(LocalDateTime.now());

        double total = 0;

        for (OrderLine line : order.getOrderLines()) {

    Product product = productRepository.findById(line.getProduct().getProductId())
            .orElseThrow(() -> new RuntimeException("Product not found"));

    // 🚨 CHECK STOCK
    if (line.getQuantity() > product.getStockQuantity()) {
        throw new RuntimeException(
                "Stock insuffisant pour le produit : " + product.getName()
        );
    }

    // 🔥 UPDATE PRODUCT STOCK
    product.setStockQuantity(product.getStockQuantity() - line.getQuantity());
    productRepository.save(product);

    line.setProduct(product);
    line.setOrder(order);

double unitPrice = product.getPriceHT(); // ou priceTTC selon ton choix
line.setUnitPrice(unitPrice);

double subtotal = line.getQuantity() * unitPrice;
line.setSubtotal(subtotal);    line.setSubtotal(subtotal);

    total += subtotal;
}
        order.setTotalPrice(total);

        if (order.getStatus() == null) {
            order.setStatus(OrderStatus.CONFIRMED);
        }

        return orderRepository.save(order);
    }

    public Order createOnlineSale(Order order) {
        order.setPaymentMethod("ONLINE");
        order.setStatus(OrderStatus.CONFIRMED);
        return createSale(order);
    }

    public Order createInStoreSale(Order order) {
        order.setPaymentMethod("CASH");
        order.setStatus(OrderStatus.CONFIRMED);
        return createSale(order);
    }

    public List<Order> getAllSales() {
        return orderRepository.findAll();
    }

    public List<Order> getSalesByStatus(OrderStatus status) {
        return orderRepository.findByStatus(status);
    }
}