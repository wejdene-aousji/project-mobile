package com.app.client.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.app.client.enums.Role;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userId;

    private String fullName;

    @Column(unique = true, nullable = false)
    private String email;

    @JsonIgnore
    private String password;
    private String phone;

    @Enumerated(EnumType.STRING)
    private Role role;

    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    @Override
    @JsonIgnore
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    @JsonIgnore
    @Override public String getUsername() { return email; }
    @JsonIgnore
    @Override public boolean isAccountNonExpired() { return true; }
    @JsonIgnore
    @Override public boolean isAccountNonLocked() { return true; }
    @JsonIgnore
    @Override public boolean isCredentialsNonExpired() { return true; }
    @JsonIgnore
    @Override public boolean isEnabled() { return true; }
}
