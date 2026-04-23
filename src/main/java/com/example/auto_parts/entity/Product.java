package com.example.auto_parts.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "products")

public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long productId;

    private String code;
    private String name;

    private Integer stockQuantity;
    private Double purchasePrice;
    private Double priceHT;
    private Double priceTTC;
    private String url;
    
    public Product() {
    }

    public Product(Long productId, String code, String name, Integer stockQuantity, Double purchasePrice,
            Double priceHT, Double priceTTC, String url) {
        this.productId = productId;
        this.code = code;
        this.name = name;
        this.stockQuantity = stockQuantity;
        this.purchasePrice = purchasePrice;
        this.priceHT = priceHT;
        this.priceTTC = priceTTC;
        this.url = url;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(Integer stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public Double getPurchasePrice() {
        return purchasePrice;
    }

    public void setPurchasePrice(Double purchasePrice) {
        this.purchasePrice = purchasePrice;
    }

    public Double getPriceHT() {
        return priceHT;
    }

    public void setPriceHT(Double priceHT) {
        this.priceHT = priceHT;
    }

    public Double getPriceTTC() {
        return priceTTC;
    }

    public void setPriceTTC(Double priceTTC) {
        this.priceTTC = priceTTC;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    
    
}