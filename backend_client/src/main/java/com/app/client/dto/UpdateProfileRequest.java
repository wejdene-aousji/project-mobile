package com.app.client.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateProfileRequest {

    @Size(min = 2, max = 100, message = "Full name must be between 2 and 100 characters")
    private String fullName;

    @Size(min = 8, max = 20, message = "Phone must be between 8 and 20 characters")
    private String phone;

    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;
}
