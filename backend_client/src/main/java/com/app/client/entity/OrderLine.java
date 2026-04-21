package com.app.client.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "order_lines")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class OrderLine {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long orderLineId;

    @ManyToOne
    @JoinColumn(name = "order_id")
    private Order order;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    private Integer quantity;
    private Double unitPrice;
    private Double subtotal;
}