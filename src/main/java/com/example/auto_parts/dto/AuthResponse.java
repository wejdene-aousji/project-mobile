package com.example.auto_parts.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthResponse {
    private Long userId;
    private String token;
    private String role;
    private String email;
    private String fullName;
    private String phone;
}
