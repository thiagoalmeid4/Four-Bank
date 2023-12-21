package br.com.fourbank.api.service;

import br.com.fourbank.api.dao.customer.CustomerDao;
import br.com.fourbank.api.dtos.customer.request.CustomerDtoSaveRequest;
import org.springframework.stereotype.Service;

@Service
public class CustomerService {

    private CustomerDao customerDao;

    public  CustomerService(CustomerDao customerDao){
        this.customerDao = customerDao;
    }

    public void saveCustomer(CustomerDtoSaveRequest customer){

        customerDao.saveCustomer(customer);
    }
}
