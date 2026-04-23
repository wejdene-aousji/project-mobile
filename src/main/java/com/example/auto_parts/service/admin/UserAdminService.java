package com.example.auto_parts.service.admin;

import com.example.auto_parts.entity.Role;
import com.example.auto_parts.entity.User;
import com.example.auto_parts.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserAdminService {

    private final UserRepository userRepository;

    public UserAdminService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // Get all customers
    public List<User> getAllClients() {
        return userRepository.findByRole(Role.CLIENT);
    }

    // Get customer by ID
    public User getClientById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    // Update customer
    public User updateClient(Long id, User user) {

        User client = getClientById(id);

        if(client != null && client.getRole() == Role.CLIENT){

            client.setFullName(user.getFullName());
            client.setEmail(user.getEmail());
            client.setPhone(user.getPhone());

            return userRepository.save(client);
        }

        return null;
    }

    // Delete customer
    public void deleteClient(Long id) {
        userRepository.deleteById(id);
    }

}