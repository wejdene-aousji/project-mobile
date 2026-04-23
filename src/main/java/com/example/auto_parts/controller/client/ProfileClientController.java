package com.example.auto_parts.controller.client;

import com.example.auto_parts.entity.User;
import com.example.auto_parts.service.client.ProfileClientService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/client/profile")
public class ProfileClientController {

    private final ProfileClientService profileClientService;

    public ProfileClientController(ProfileClientService profileClientService) {
        this.profileClientService = profileClientService;
    }

    @GetMapping
    public ResponseEntity<User> getProfile(Authentication auth) {
        return ResponseEntity.ok(profileClientService.getProfile(auth.getName()));
    }

    @PutMapping
    public ResponseEntity<User> updateProfile(@RequestBody User user, Authentication auth) {
        return ResponseEntity.ok(profileClientService.updateProfile(auth.getName(), user));
    }
}
