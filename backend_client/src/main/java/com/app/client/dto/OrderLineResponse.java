package com.app.client.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderLineResponse {
    private Long productId;
    private String productCode;
    private String productName;
    private Integer quantity;
    private Double unitPrice;
    private Double subtotal;
}
