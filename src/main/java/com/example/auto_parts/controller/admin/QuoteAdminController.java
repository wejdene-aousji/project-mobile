package com.example.auto_parts.controller.admin;

import com.example.auto_parts.entity.Quote;
import com.example.auto_parts.entity.QuoteStatus;
import com.example.auto_parts.service.admin.QuoteAdminService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/quotes")
public class QuoteAdminController {

    private final QuoteAdminService quoteAdminService;

    public QuoteAdminController(QuoteAdminService quoteAdminService) {
        this.quoteAdminService = quoteAdminService;
    }

    // GET ALL QUOTES
    @GetMapping
    public List<Quote> getAllQuotes() {
        return quoteAdminService.getAllQuotes();
    }

    // APPROVE QUOTE
    @PutMapping("/{id}/approve")
    public Quote approveQuote(@PathVariable Long id) {
        return quoteAdminService.approveQuote(id);
    }

    // REJECT QUOTE
    @PutMapping("/{id}/reject")
    public Quote rejectQuote(@PathVariable Long id) {
        return quoteAdminService.rejectQuote(id);
    }

    // GET QUOTES BY STATUS
    @GetMapping("/status/{status}")
    public List<Quote> getQuotesByStatus(@PathVariable QuoteStatus status) {
        return quoteAdminService.getQuotesByStatus(status);
    }
}