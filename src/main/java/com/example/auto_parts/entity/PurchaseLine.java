package com.example.auto_parts.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "purchase_lines")

public class PurchaseLine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long purchaseLineId;

    private Long purchaseId;
    private Long productId;

    private Integer quantity;
    private Double unitCost;
    private Double subtotal;

    public PurchaseLine() {
    }

    public PurchaseLine(Long purchaseLineId, Long purchaseId, Long productId, Integer quantity, Double unitCost, Double subtotal) {
        this.purchaseLineId = purchaseLineId;
        this.purchaseId = purchaseId;
        this.productId = productId;
        this.quantity = quantity;
        this.unitCost = unitCost;
        this.subtotal = subtotal;
    }

    public Long getPurchaseLineId() {
        return purchaseLineId;
    }

    public void setPurchaseLineId(Long purchaseLineId) {
        this.purchaseLineId = purchaseLineId;
    }

    public Long getPurchaseId() {
        return purchaseId;
    }

    public void setPurchaseId(Long purchaseId) {
        this.purchaseId = purchaseId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Double getUnitCost() {
        return unitCost;
    }

    public void setUnitCost(Double unitCost) {
        this.unitCost = unitCost;
    }

    public Double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(Double subtotal) {
        this.subtotal = subtotal;
    }

}