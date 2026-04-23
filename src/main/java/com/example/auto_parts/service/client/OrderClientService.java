package com.example.auto_parts.service.client;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderLine;
import com.example.auto_parts.entity.OrderStatus;
import com.example.auto_parts.entity.Product;
import com.example.auto_parts.entity.User;
import com.example.auto_parts.exception.AccessDeniedException;
import com.example.auto_parts.exception.InsufficientStockException;
import com.example.auto_parts.exception.ResourceNotFoundException;
import com.example.auto_parts.repository.OrderRepository;
import com.example.auto_parts.repository.ProductRepository;
import com.example.auto_parts.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class OrderClientService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    public OrderClientService(OrderRepository orderRepository,
                              ProductRepository productRepository,
                              UserRepository userRepository) {
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Order createOrder(String email, Order requestOrder) {
        User user = findUserByEmail(email);

        Order order = new Order();
        order.setUser(user);
        order.setPaymentMethod("CASH_ON_DELIVERY");
        order.setStatus(OrderStatus.PENDING);

        if (requestOrder.getOrderLines() == null || requestOrder.getOrderLines().isEmpty()) {
            throw new IllegalArgumentException("Order must contain at least one item");
        }

        List<OrderLine> lines = requestOrder.getOrderLines().stream().map(item -> {
            if (item.getProduct() == null || item.getProduct().getProductId() == null) {
                throw new IllegalArgumentException("Product ID is required for each order line");
            }

            Product product = productRepository.findByIdWithLock(item.getProduct().getProductId())
                    .orElseThrow(() -> new ResourceNotFoundException("Product", "id", item.getProduct().getProductId()));

            if (product.getStockQuantity() < item.getQuantity()) {
                throw new InsufficientStockException(product.getName(), item.getQuantity(), product.getStockQuantity());
            }

            product.setStockQuantity(product.getStockQuantity() - item.getQuantity());
            productRepository.save(product);

            OrderLine line = new OrderLine();
            line.setOrder(order);
            line.setProduct(product);
            line.setQuantity(item.getQuantity());
            line.setUnitPrice(product.getPriceTTC());
            line.setSubtotal(product.getPriceTTC() * item.getQuantity());
            return line;
        }).toList();

        order.setOrderLines(lines);
        order.setTotalPrice(lines.stream().mapToDouble(OrderLine::getSubtotal).sum());

        return orderRepository.save(order);
    }

    @Transactional(readOnly = true)
    public List<Order> getMyOrders(String email, OrderStatus status) {
        User user = findUserByEmail(email);
        return status != null
                ? orderRepository.findByUserAndStatusOrderByCreatedAtDesc(user, status)
                : orderRepository.findByUserOrderByCreatedAtDesc(user);
    }

    @Transactional(readOnly = true)
    public Order getOrderById(Long id, String email) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order", "id", id));

        if (!order.getUser().getEmail().equals(email)) {
            throw new AccessDeniedException("You can only view your own orders");
        }

        return order;
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
    }
}
