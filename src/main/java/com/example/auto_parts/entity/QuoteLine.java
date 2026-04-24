package com.example.auto_parts.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;

@Entity
@Table(name = "quote_lines")
public class QuoteLine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long quoteLineId;

    @ManyToOne
    @JoinColumn(name = "quote_id")
    @JsonBackReference
    private Quote quote;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    private Integer quantity;
    private Double unitPrice;
    private Double subtotal;

    public QuoteLine() {
    }

    public Long getQuoteLineId() {
        return quoteLineId;
    }

    public void setQuoteLineId(Long quoteLineId) {
        this.quoteLineId = quoteLineId;
    }

    public Quote getQuote() {
        return quote;
    }

    public void setQuote(Quote quote) {
        this.quote = quote;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(Double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public Double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(Double subtotal) {
        this.subtotal = subtotal;
    }
}
