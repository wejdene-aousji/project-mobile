package com.app.client.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {
    private Long productId;
    private String code;
    private String name;
    private Integer stockQuantity;
    private Double priceHT;
    private Double priceTTC;
    private String url;
}
