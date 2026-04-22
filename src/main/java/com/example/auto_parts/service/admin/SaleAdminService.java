package com.example.auto_parts.service.admin;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.auto_parts.entity.Order;
import com.example.auto_parts.entity.OrderLine;
import com.example.auto_parts.entity.OrderStatus;
import com.example.auto_parts.entity.Product;
import com.example.auto_parts.entity.User;
import com.example.auto_parts.repository.OrderRepository;
import com.example.auto_parts.repository.ProductRepository;
import com.example.auto_parts.repository.UserRepository;

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

    // Create sale + stock update
    public Order createSale(Order order) {

        User user = userRepository.findById(order.getUser().getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        order.setUser(user);
        order.setCreatedAt(LocalDateTime.now());

        double total = 0;

        for (OrderLine line : order.getOrderLines()) {

            Product product = productRepository.findById(line.getProduct().getProductId())
                    .orElseThrow(() -> new RuntimeException("Product not found"));

            // Check stock
            if (line.getQuantity() > product.getStockQuantity()) {
                throw new RuntimeException(
                        "Stock insuffisant pour le produit : " + product.getName()
                );
            }

            // Update stock
            product.setStockQuantity(product.getStockQuantity() - line.getQuantity());
            productRepository.save(product);

            line.setProduct(product);
            line.setOrder(order);

            double unitPrice = product.getPriceTTC();
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

    // Create online sale
    public Order createOnlineSale(Order order) {
        order.setPaymentMethod("ONLINE");
        order.setStatus(OrderStatus.CONFIRMED);
        return createSale(order);
    }

    // Create in-store sale
    public Order createInStoreSale(Order order) {
        order.setPaymentMethod("CASH");
        order.setStatus(OrderStatus.CONFIRMED);
        return createSale(order);
    }

    // Get all sales
    public List<Order> getAllSales() {
        return orderRepository.findAll();
    }

    // Get sales by status
    public List<Order> getSalesByStatus(OrderStatus status) {
        return orderRepository.findByStatus(status);
    }

    // Cancel sale + stock update
    public Order cancelSale(Long orderId) {

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        // Verify if already canceled
        if (order.getStatus() == OrderStatus.CANCELED) {
            throw new RuntimeException("Order already canceled");
        }

        // Restore stock
        for (OrderLine line : order.getOrderLines()) {

            Product product = line.getProduct();

            product.setStockQuantity(
                    product.getStockQuantity() + line.getQuantity()
            );

            productRepository.save(product);
        }

        // Change status
        order.setStatus(OrderStatus.CANCELED);

        return orderRepository.save(order);
    }

    
    // Update sale + stock update
    public Order updateSale(Long id, Order updatedOrder) {

        Order existingOrder = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        Map<Long, OrderLine> oldMap = existingOrder.getOrderLines()
                .stream()
                .collect(Collectors.toMap(
                        l -> l.getProduct().getProductId(),
                        l -> l
                ));

        double total = 0;

        List<OrderLine> newLines = new ArrayList<>();

        for (OrderLine newLine : updatedOrder.getOrderLines()) {

            Long productId = newLine.getProduct().getProductId();

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product not found"));

            OrderLine oldLine = oldMap.get(productId);

            int oldQty = (oldLine != null) ? oldLine.getQuantity() : 0;
            int newQty = newLine.getQuantity();

            int delta = newQty - oldQty;

            // STOCK ADJUSTMENT
            if (delta > 0 && product.getStockQuantity() < delta) {
                throw new RuntimeException("Stock insuffisant pour " + product.getName());
            }

            product.setStockQuantity(product.getStockQuantity() - delta);
            productRepository.save(product);

            // BUILD LINE
            OrderLine lineToSave = (oldLine != null) ? oldLine : new OrderLine();

            lineToSave.setOrder(existingOrder);
            lineToSave.setProduct(product);
            lineToSave.setQuantity(newQty);

            double unitPrice = product.getPriceTTC();
            double subtotal = unitPrice * newQty;

            lineToSave.setUnitPrice(unitPrice);
            lineToSave.setSubtotal(subtotal);

            total += subtotal;

            newLines.add(lineToSave);
        }

        // RESTORE deleted lines
        for (OrderLine oldLine : existingOrder.getOrderLines()) {

            boolean exists = updatedOrder.getOrderLines().stream()
                    .anyMatch(l -> l.getProduct().getProductId()
                            .equals(oldLine.getProduct().getProductId()));

            if (!exists) {

                Product product = oldLine.getProduct();

                product.setStockQuantity(
                        product.getStockQuantity() + oldLine.getQuantity()
                );

                productRepository.save(product);
            }
        }

        existingOrder.getOrderLines().clear();
        existingOrder.getOrderLines().addAll(newLines);

        existingOrder.setTotalPrice(total);

        return orderRepository.save(existingOrder);
    }

    // Delete sale
    public void deleteSale(Long id) {

        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        // delete order (cascade supprime orderLines si cascade = ALL)
        orderRepository.delete(order);
    }

}