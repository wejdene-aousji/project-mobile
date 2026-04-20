package com.example.auto_parts.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "quotes")

public class Quote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long quoteId;

    private Long userId;

    private String status; // PENDING, ACCEPTED, REJECTED
    private String message;

    private LocalDateTime createdAt = LocalDateTime.now();

    public Quote() {
    }

    public Quote(Long quoteId, Long userId, String status, String message, LocalDateTime createdAt) {
        this.quoteId = quoteId;
        this.userId = userId;
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

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
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

    
}