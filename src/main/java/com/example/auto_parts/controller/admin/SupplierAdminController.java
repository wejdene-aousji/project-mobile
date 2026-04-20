package com.example.auto_parts.controller.admin;

import com.example.auto_parts.entity.Supplier;
import com.example.auto_parts.service.admin.SupplierAdminService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/suppliers")
public class SupplierAdminController {

    private final SupplierAdminService supplierAdminService;

    public SupplierAdminController(SupplierAdminService supplierAdminService) {
        this.supplierAdminService = supplierAdminService;
    }

    // add supplier
    @PostMapping
    public Supplier addSupplier(@RequestBody Supplier supplier) {
        return supplierAdminService.addSupplier(supplier);
    }

    // get all suppliers
    @GetMapping
    public List<Supplier> getAllSuppliers() {
        return supplierAdminService.getAllSuppliers();
    }

    // update supplier
    @PutMapping("/{id}")
    public Supplier updateSupplier(@PathVariable Long id, @RequestBody Supplier supplier) {
        return supplierAdminService.updateSupplier(id, supplier);
    }

    // delete supplier
    @DeleteMapping("/{id}")
    public void deleteSupplier(@PathVariable Long id) {
        supplierAdminService.deleteSupplier(id);
    }
}