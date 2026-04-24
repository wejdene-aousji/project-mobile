package com.example.auto_parts.controller.client;

import com.example.auto_parts.entity.Quote;
import com.example.auto_parts.entity.QuoteStatus;
import com.example.auto_parts.service.client.QuoteClientService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/client/quotes")
public class QuoteClientController {

    private final QuoteClientService quoteClientService;

    public QuoteClientController(QuoteClientService quoteClientService) {
        this.quoteClientService = quoteClientService;
    }

    @PostMapping
    public ResponseEntity<Quote> createQuote(@RequestBody com.example.auto_parts.dto.QuoteRequest quoteRequest, Authentication auth) {
        return ResponseEntity.ok(quoteClientService.createQuote(auth.getName(), quoteRequest));
    }

    @GetMapping
    public ResponseEntity<List<Quote>> getMyQuotes(Authentication auth,
                                                   @RequestParam(required = false) QuoteStatus status) {
        return ResponseEntity.ok(quoteClientService.getMyQuotes(auth.getName(), status));
    }
}
