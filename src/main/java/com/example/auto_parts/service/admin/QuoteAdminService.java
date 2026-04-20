package com.example.auto_parts.service.admin;

import com.example.auto_parts.entity.Quote;
import com.example.auto_parts.entity.QuoteStatus;
import com.example.auto_parts.repository.QuoteRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class QuoteAdminService {

    private final QuoteRepository quoteRepository;

    public QuoteAdminService(QuoteRepository quoteRepository) {
        this.quoteRepository = quoteRepository;
    }

    // GET ALL QUOTES
    public List<Quote> getAllQuotes() {
        return quoteRepository.findAll();
    }

    // APPROVE QUOTE
    public Quote approveQuote(Long id) {

        Quote quote = quoteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Quote not found"));

        quote.setStatus(QuoteStatus.ACCEPTED);

        return quoteRepository.save(quote);
    }

    // REJECT QUOTE
    public Quote rejectQuote(Long id) {

        Quote quote = quoteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Quote not found"));

        quote.setStatus(QuoteStatus.REJECTED);
        return quoteRepository.save(quote);
    }

    public List<Quote> getQuotesByStatus(QuoteStatus status) {
        return quoteRepository.findByStatus(status);
    }
}