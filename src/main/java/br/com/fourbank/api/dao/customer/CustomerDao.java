package br.com.fourbank.api.dao.customer;

import br.com.fourbank.api.dtos.customer.request.CustomerDtoSaveRequest;

public interface CustomerDao {
    void saveCustomer(CustomerDtoSaveRequest customer);
}
