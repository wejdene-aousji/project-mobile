package com.example.auto_parts.controller.admin;

import com.example.auto_parts.entity.User;
import com.example.auto_parts.service.admin.UserAdminService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/customers")
public class UserAdminController {

    private final UserAdminService userAdminService;

    public UserAdminController(UserAdminService userAdminService) {
        this.userAdminService = userAdminService;
    }

    // liste clients
    @GetMapping
    public List<User> getAllClients() {
        return userAdminService.getAllClients();
    }

    // client par id
    @GetMapping("/{id}")
    public User getClientById(@PathVariable Long id) {
        return userAdminService.getClientById(id);
    }

    // update client
    @PutMapping("/{id}")
    public User updateClient(@PathVariable Long id, @RequestBody User user) {
        return userAdminService.updateClient(id, user);
    }

    // delete client
    @DeleteMapping("/{id}")
    public void deleteClient(@PathVariable Long id) {
        userAdminService.deleteClient(id);
    }

}