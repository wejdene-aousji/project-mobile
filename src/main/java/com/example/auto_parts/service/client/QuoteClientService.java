package com.example.auto_parts.service.client;

import com.example.auto_parts.entity.Quote;
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

    public QuoteClientService(QuoteRepository quoteRepository, UserRepository userRepository) {
        this.quoteRepository = quoteRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Quote createQuote(String email, Quote requestQuote) {
        User user = findUserByEmail(email);

        Quote quote = new Quote();
        quote.setUser(user);
        quote.setMessage(requestQuote.getMessage());

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
