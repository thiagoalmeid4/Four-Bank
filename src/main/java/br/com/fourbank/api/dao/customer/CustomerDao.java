package br.com.fourbank.api.dao.customer;

import java.util.Map;

import br.com.fourbank.api.dto.customer.request.CustomerDtoSaveRequest;

public interface CustomerDao {
    void saveCustomer(CustomerDtoSaveRequest customer);
    Boolean checkCpf(String cpf);
    Boolean checkEmail(String email);
    Boolean checkPhone(String phone); 
    Map<String, Object> getDataAuthentication(String login);
}
