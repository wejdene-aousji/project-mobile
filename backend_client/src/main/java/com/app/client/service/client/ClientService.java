package com.app.client.service.client;

import com.app.client.dto.OrderLineResponse;
import com.app.client.dto.OrderRequest;
import com.app.client.dto.OrderResponse;
import com.app.client.dto.ProductResponse;
import com.app.client.dto.ProfileResponse;
import com.app.client.dto.QuoteRequest;
import com.app.client.dto.QuoteResponse;
import com.app.client.dto.UpdateProfileRequest;
import com.app.client.entity.Order;
import com.app.client.entity.OrderLine;
import com.app.client.entity.Product;
import com.app.client.entity.Quote;
import com.app.client.entity.User;
import com.app.client.enums.OrderStatus;
import com.app.client.enums.QuoteStatus;
import com.app.client.exception.AccessDeniedException;
import com.app.client.exception.InsufficientStockException;
import com.app.client.exception.ResourceNotFoundException;
import com.app.client.repository.OrderRepository;
import com.app.client.repository.ProductRepository;
import com.app.client.repository.QuoteRepository;
import com.app.client.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ClientService {

    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final QuoteRepository quoteRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public List<ProductResponse> getAllProducts(String search) {
        List<Product> products = (search != null && !search.isBlank())
                ? productRepository.findByStockQuantityGreaterThanAndNameContainingIgnoreCase(0, search.trim())
                : productRepository.findAvailableProducts();

        return products.stream()
                .map(this::toProductResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public ProductResponse getProductById(Long id) {
        return toProductResponse(findProductById(id));
    }

    @Transactional
    public OrderResponse createOrder(String email, OrderRequest request) {
        log.info("Creating order for user: {}", email);

        User user = findUserByEmail(email);

        Order order = Order.builder().customer(user).build();

        List<OrderLine> lines = request.getItems().stream().map(item -> {
            Product product = productRepository.findByIdWithLock(item.getProductId())
                    .orElseThrow(() -> new ResourceNotFoundException("Product", "id", item.getProductId()));

            if (product.getStockQuantity() < item.getQuantity()) {
                throw new InsufficientStockException(product.getName(), item.getQuantity(), product.getStockQuantity());
            }

            product.setStockQuantity(product.getStockQuantity() - item.getQuantity());
            productRepository.save(product);

            return OrderLine.builder()
                    .order(order)
                    .product(product)
                    .quantity(item.getQuantity())
                    .unitPrice(product.getPriceTTC())
                    .subtotal(product.getPriceTTC() * item.getQuantity())
                    .build();
        }).toList();

        order.setOrderLines(lines);
        order.setTotalPrice(lines.stream().mapToDouble(OrderLine::getSubtotal).sum());
        Order savedOrder = orderRepository.save(order);

        log.info("Order created successfully: orderId={}, total={}, items={}",
                savedOrder.getOrderId(), savedOrder.getTotalPrice(), lines.size());

        return toOrderResponse(savedOrder);
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> getMyOrders(String email, OrderStatus status) {
        User user = findUserByEmail(email);
        List<Order> orders = status != null
                ? orderRepository.findByCustomerAndStatusOrderByCreatedAtDesc(user, status)
                : orderRepository.findByCustomerOrderByCreatedAtDesc(user);

        return orders.stream()
                .map(this::toOrderResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public OrderResponse getOrderById(Long id, String email) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order", "id", id));

        if (!order.getCustomer().getEmail().equals(email)) {
            throw new AccessDeniedException("You can only view your own orders");
        }
        return toOrderResponse(order);
    }

    @Transactional
    public QuoteResponse createQuote(String email, QuoteRequest request) {
        log.info("Creating quote for user: {}", email);

        User user = findUserByEmail(email);

        Quote quote = Quote.builder()
                .user(user)
                .message(request.getMessage())
                .build();

        Quote savedQuote = quoteRepository.save(quote);
        log.info("Quote created successfully: quoteId={}", savedQuote.getQuoteId());

        return toQuoteResponse(savedQuote);
    }

    @Transactional(readOnly = true)
    public List<QuoteResponse> getMyQuotes(String email, QuoteStatus status) {
        User user = findUserByEmail(email);
        List<Quote> quotes = status != null
                ? quoteRepository.findByUserAndStatus(user, status)
                : quoteRepository.findByUser(user);

        return quotes.stream()
                .map(this::toQuoteResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public ProfileResponse getProfile(String email) {
        return toProfileResponse(findUserByEmail(email));
    }

    @Transactional
    public ProfileResponse updateProfile(String email, UpdateProfileRequest request) {
        User user = findUserByEmail(email);

        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setFullName(request.getFullName().trim());
        }

        if (request.getPhone() != null && !request.getPhone().isBlank()) {
            user.setPhone(request.getPhone().trim());
        }

        if (request.getPassword() != null && !request.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        User updatedUser = userRepository.save(user);
        log.info("Profile updated successfully: userId={}, email={}", updatedUser.getUserId(), updatedUser.getEmail());

        return toProfileResponse(updatedUser);
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
    }

    private Product findProductById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product", "id", id));
    }

    private ProductResponse toProductResponse(Product product) {
        return ProductResponse.builder()
                .productId(product.getProductId())
                .code(product.getCode())
                .name(product.getName())
                .stockQuantity(product.getStockQuantity())
                .priceHT(product.getPriceHT())
                .priceTTC(product.getPriceTTC())
                .url(product.getUrl())
                .build();
    }

    private OrderResponse toOrderResponse(Order order) {
        return OrderResponse.builder()
                .orderId(order.getOrderId())
                .totalPrice(order.getTotalPrice())
                .status(order.getStatus() != null ? order.getStatus().name() : null)
                .paymentMethod(order.getPaymentMethod())
                .createdAt(order.getCreatedAt())
                .items((order.getOrderLines() != null ? order.getOrderLines() : Collections.<OrderLine>emptyList())
                        .stream()
                        .map(this::toOrderLineResponse)
                        .toList())
                .build();
    }

    private OrderLineResponse toOrderLineResponse(OrderLine orderLine) {
        Product product = orderLine.getProduct();
        return OrderLineResponse.builder()
                .productId(product.getProductId())
                .productCode(product.getCode())
                .productName(product.getName())
                .quantity(orderLine.getQuantity())
                .unitPrice(orderLine.getUnitPrice())
                .subtotal(orderLine.getSubtotal())
                .build();
    }

    private QuoteResponse toQuoteResponse(Quote quote) {
        return QuoteResponse.builder()
                .quoteId(quote.getQuoteId())
                .status(quote.getStatus() != null ? quote.getStatus().name() : null)
                .message(quote.getMessage())
                .createdAt(quote.getCreatedAt())
                .build();
    }

    private ProfileResponse toProfileResponse(User user) {
        return ProfileResponse.builder()
                .userId(user.getUserId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole() != null ? user.getRole().name() : null)
                .createdAt(user.getCreatedAt())
                .build();
    }
}
