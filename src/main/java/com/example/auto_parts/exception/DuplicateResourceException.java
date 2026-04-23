package com.example.auto_parts.exception;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class DuplicateResourceException extends RuntimeException {
    private String resourceName;
    private String fieldValue;

    public DuplicateResourceException(String resourceName, String fieldValue) {
        super(String.format("%s already exists with value: %s", resourceName, fieldValue));
        this.resourceName = resourceName;
        this.fieldValue = fieldValue;
    }
}

