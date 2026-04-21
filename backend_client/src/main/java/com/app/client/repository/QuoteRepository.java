package com.app.client.repository;

import com.app.client.entity.Quote;
import com.app.client.entity.User;
import com.app.client.enums.QuoteStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface QuoteRepository extends JpaRepository<Quote, Long> {
    List<Quote> findByUser(User user);
    List<Quote> findByUserAndStatus(User user, QuoteStatus status);
}
