package com.app.client.service.auth;

import com.app.client.config.JwtService;
import com.app.client.dto.*;
import com.app.client.entity.User;
import com.app.client.enums.Role;
import com.app.client.exception.DuplicateResourceException;
import com.app.client.exception.ResourceNotFoundException;
import com.app.client.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        log.info("Registering new user: email={}", request.getEmail());

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("User", request.getEmail());
        }

        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(Role.CLIENT)
                .build();

        userRepository.save(user);
        String token = jwtService.generateToken(user);

        log.info("User registered successfully: userId={}, email={}", user.getUserId(), user.getEmail());

        return new AuthResponse(token, user.getRole().name(), user.getEmail(), user.getFullName());
    }

    public AuthResponse login(LoginRequest request) {
        log.info("Login attempt: email={}", request.getEmail());

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", request.getEmail()));

        String token = jwtService.generateToken(user);

        log.info("Login successful: userId={}, email={}", user.getUserId(), user.getEmail());

        return new AuthResponse(token, user.getRole().name(), user.getEmail(), user.getFullName());
    }
}
