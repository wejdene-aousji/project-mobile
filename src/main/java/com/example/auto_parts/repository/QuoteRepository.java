package com.example.auto_parts.repository;

import com.example.auto_parts.entity.Quote;
import com.example.auto_parts.entity.QuoteStatus;
import com.example.auto_parts.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuoteRepository extends JpaRepository<Quote, Long> {

    List<Quote> findByStatus(QuoteStatus status);
    List<Quote> findByUser(User user);
    List<Quote> findByUserAndStatus(User user, QuoteStatus status);
}
