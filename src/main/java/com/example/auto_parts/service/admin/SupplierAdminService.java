package com.example.auto_parts.service.admin;

import com.example.auto_parts.entity.Supplier;
import com.example.auto_parts.repository.SupplierRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SupplierAdminService {

    private final SupplierRepository supplierRepository;

    public SupplierAdminService(SupplierRepository supplierRepository) {
        this.supplierRepository = supplierRepository;
    }

    // Add supplier
    public Supplier addSupplier(Supplier supplier) {
        return supplierRepository.save(supplier);
    }

    // List suppliers
    public List<Supplier> getAllSuppliers() {
        return supplierRepository.findAll();
    }

    // Update supplier
    public Supplier updateSupplier(Long id, Supplier supplier) {

        Supplier s = supplierRepository.findById(id).orElse(null);

        if (s != null) {
            s.setName(supplier.getName());
            s.setPhone(supplier.getPhone());
            s.setEmail(supplier.getEmail());
            s.setAddress(supplier.getAddress());

            return supplierRepository.save(s);
        }

        return null;
    }

    // Delete supplier
    public void deleteSupplier(Long id) {
        supplierRepository.deleteById(id);
    }
}