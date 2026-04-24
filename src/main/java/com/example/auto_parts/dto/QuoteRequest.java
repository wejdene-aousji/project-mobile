package com.example.auto_parts.dto;

import java.util.List;

public class QuoteRequest {
    private String message;
    private List<QuoteLineRequest> lines;

    public QuoteRequest() {}

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<QuoteLineRequest> getLines() {
        return lines;
    }

    public void setLines(List<QuoteLineRequest> lines) {
        this.lines = lines;
    }
}
