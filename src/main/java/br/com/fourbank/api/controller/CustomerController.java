package br.com.fourbank.api.controller;

import br.com.fourbank.api.dtos.customer.request.CustomerDtoSaveRequest;
import br.com.fourbank.api.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CustomerController {

    @Autowired
    private CustomerService service;

    @PostMapping(path = "/save-customer")
    public ResponseEntity<?> saveCustomer(@RequestBody CustomerDtoSaveRequest customer){

        service.saveCustomer(customer);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }
}
