package com.example.auto_parts.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonManagedReference;

@Entity
@Table(name = "quotes")

public class Quote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long quoteId;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Enumerated(EnumType.STRING)
    private QuoteStatus status = QuoteStatus.PENDING; // PENDING, ACCEPTED, REJECTED

    private String message;

    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "quote", cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<QuoteLine> quoteLines;

    public Quote() {
    }

    public Quote(Long quoteId, QuoteStatus status, String message, LocalDateTime createdAt) {
        this.quoteId = quoteId;
        this.status = status;
        this.message = message;
        this.createdAt = createdAt;
    }

    public Long getQuoteId() {
        return quoteId;
    }

    public void setQuoteId(Long quoteId) {
        this.quoteId = quoteId;
    }

    public QuoteStatus getStatus() {
        return status;
    }

    public void setStatus(QuoteStatus status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public List<QuoteLine> getQuoteLines() {
        return quoteLines;
    }

    public void setQuoteLines(List<QuoteLine> quoteLines) {
        this.quoteLines = quoteLines;
    }

    
}