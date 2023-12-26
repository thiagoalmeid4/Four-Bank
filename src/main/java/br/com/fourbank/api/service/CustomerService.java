package br.com.fourbank.api.service;

import br.com.fourbank.api.dao.customer.CustomerDao;
import br.com.fourbank.api.dto.customer.request.CustomerDtoSaveRequest;
import br.com.fourbank.api.err.ErrResponse;
import br.com.fourbank.api.err.exceptions.FourBankException;

import java.util.ArrayList;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class CustomerService {

    private CustomerDao customerDao;
    private PasswordEncoder passwordEncoder;

    public  CustomerService(CustomerDao customerDao, PasswordEncoder passwordEncoder){
        this.customerDao = customerDao;
        this.passwordEncoder = passwordEncoder;
    }

    public void saveCustomer(CustomerDtoSaveRequest customer){
        checkBeforeSaving(customer);
        customer.setPassword(passwordEncoder.encode(customer.getPassword()));
        customerDao.saveCustomer(customer);
    }

    private void checkBeforeSaving(CustomerDtoSaveRequest customer){
        var errors = new ArrayList<ErrResponse>();
        if(customerDao.checkCpf(customer.getCpf())){
            errors.add(new ErrResponse("CPF já registrado", HttpStatus.CONFLICT.value()));
        }
        if(customerDao.checkEmail(customer.getEmail())){
            errors.add(new ErrResponse("Email já registrado", HttpStatus.CONFLICT.value()));
        }
        if(customerDao.checkPhone(customer.getPhone())){
            errors.add(new ErrResponse("Telefone já registrado", HttpStatus.CONFLICT.value()));
        }
        if(errors.size() > 0){
            throw new FourBankException(errors, HttpStatus.CONFLICT.value());
        }   
    }

}
