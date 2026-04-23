package com.example.auto_parts.exception;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class InsufficientStockException extends RuntimeException {
    private String productName;
    private Integer requested;
    private Integer available;

    public InsufficientStockException(String productName, Integer requested, Integer available) {
        super(String.format("Insufficient stock for '%s': requested %d, available %d",
                productName, requested, available));
        this.productName = productName;
        this.requested = requested;
        this.available = available;
    }
}

