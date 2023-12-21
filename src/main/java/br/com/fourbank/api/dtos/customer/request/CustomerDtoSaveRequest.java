package br.com.fourbank.api.dtos.customer.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CustomerDtoSaveRequest {
    private String name;
    private String email;
    private String phone;
    private String password;
    private String cpf;
    private String date;

}
