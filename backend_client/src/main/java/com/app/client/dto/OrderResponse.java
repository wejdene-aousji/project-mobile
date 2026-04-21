package com.app.client.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderResponse {
    private Long orderId;
    private Double totalPrice;
    private String status;
    private String paymentMethod;
    private LocalDateTime createdAt;
    private List<OrderLineResponse> items;
}
