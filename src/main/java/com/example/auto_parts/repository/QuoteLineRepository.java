package com.example.auto_parts.repository;

import com.example.auto_parts.entity.QuoteLine;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuoteLineRepository extends JpaRepository<QuoteLine, Long> {

}
