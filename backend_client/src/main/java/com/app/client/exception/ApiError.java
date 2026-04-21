package com.app.client.exception;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiError {
    private int statusCode;
    private String message;
    private LocalDateTime timestamp;
    private String path;

    public static ApiError of(int statusCode, String message, String path) {
        return new ApiError(statusCode, message, LocalDateTime.now(), path);
    }
}
