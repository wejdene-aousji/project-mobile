package com.app.client.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "products")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Product {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long productId;

    private String code;
    private String name;
    private Integer stockQuantity;
    private Double purchasePrice;
    private Double priceHT;
    private Double priceTTC;
    private String url;
}