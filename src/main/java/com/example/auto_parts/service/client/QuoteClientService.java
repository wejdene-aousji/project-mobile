package com.example.auto_parts.service.client;

import com.example.auto_parts.entity.Quote;
import com.example.auto_parts.entity.QuoteLine;
import com.example.auto_parts.entity.Product;
import com.example.auto_parts.dto.QuoteRequest;
import com.example.auto_parts.dto.QuoteLineRequest;
import com.example.auto_parts.repository.ProductRepository;
import com.example.auto_parts.entity.QuoteStatus;
import com.example.auto_parts.entity.User;
import com.example.auto_parts.exception.ResourceNotFoundException;
import com.example.auto_parts.repository.QuoteRepository;
import com.example.auto_parts.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class QuoteClientService {

    private final QuoteRepository quoteRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    public QuoteClientService(QuoteRepository quoteRepository, UserRepository userRepository, ProductRepository productRepository) {
        this.quoteRepository = quoteRepository;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
    }

    @Transactional
    public Quote createQuote(String email, QuoteRequest request) {
        User user = findUserByEmail(email);

        Quote quote = new Quote();
        quote.setUser(user);
        quote.setMessage(request.getMessage());

        if (request.getLines() != null && !request.getLines().isEmpty()) {
            List<QuoteLine> lines = new java.util.ArrayList<>();
            for (QuoteLineRequest lr : request.getLines()) {
                Product product = productRepository.findById(lr.getProductId())
                        .orElseThrow(() -> new ResourceNotFoundException("Product", "id", lr.getProductId()));

                QuoteLine ql = new QuoteLine();
                ql.setProduct(product);
                ql.setQuantity(lr.getQuantity() == null ? 1 : lr.getQuantity());
                double unitPrice = product.getPriceTTC() == null ? 0.0 : product.getPriceTTC();
                ql.setUnitPrice(unitPrice);
                ql.setSubtotal(ql.getQuantity() * unitPrice);
                ql.setQuote(quote);
                lines.add(ql);
            }
            quote.setQuoteLines(lines);
        }

        return quoteRepository.save(quote);
    }

    @Transactional(readOnly = true)
    public List<Quote> getMyQuotes(String email, QuoteStatus status) {
        User user = findUserByEmail(email);
        return status != null
                ? quoteRepository.findByUserAndStatus(user, status)
                : quoteRepository.findByUser(user);
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
    }
}
