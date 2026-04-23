package com.example.auto_parts.service.client;

import com.example.auto_parts.entity.User;
import com.example.auto_parts.exception.ResourceNotFoundException;
import com.example.auto_parts.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ProfileClientService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public ProfileClientService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public User getProfile(String email) {
        return findUserByEmail(email);
    }

    @Transactional
    public User updateProfile(String email, User requestUser) {
        User user = findUserByEmail(email);

        if (requestUser.getFullName() != null && !requestUser.getFullName().isBlank()) {
            user.setFullName(requestUser.getFullName().trim());
        }

        if (requestUser.getPhone() != null && !requestUser.getPhone().isBlank()) {
            user.setPhone(requestUser.getPhone().trim());
        }

        if (requestUser.getPassword() != null && !requestUser.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(requestUser.getPassword()));
        }

        return userRepository.save(user);
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
    }
}
