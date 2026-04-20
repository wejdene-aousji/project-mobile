package com.example.auto_parts.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "purchases")

public class Purchase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long purchaseId;

    private Long supplierId;

    private Double totalCost;

    private LocalDate purchaseDate;

    public Purchase() {
    }

    public Purchase(Long purchaseId, Long supplierId, Double totalCost, LocalDate purchaseDate) {
        this.purchaseId = purchaseId;
        this.supplierId = supplierId;
        this.totalCost = totalCost;
        this.purchaseDate = purchaseDate;
    }

    public Long getPurchaseId() {
        return purchaseId;
    }

    public void setPurchaseId(Long purchaseId) {
        this.purchaseId = purchaseId;
    }

    public Long getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Long supplierId) {
        this.supplierId = supplierId;
    }

    public Double getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(Double totalCost) {
        this.totalCost = totalCost;
    }

    public LocalDate getPurchaseDate() {
        return purchaseDate;
    }

    public void setPurchaseDate(LocalDate purchaseDate) {
        this.purchaseDate = purchaseDate;
    }


    
}