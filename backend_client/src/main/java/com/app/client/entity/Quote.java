package com.app.client.entity;

import com.app.client.enums.QuoteStatus;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "quotes")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Quote {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long quoteId;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Enumerated(EnumType.STRING)
    private QuoteStatus status;

    private String message;
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        if (this.status == null) this.status = QuoteStatus.PENDING;
    }
}