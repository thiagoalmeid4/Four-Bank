package br.com.fourbank.api.dtos.customer.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.validator.constraints.br.CPF;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CustomerDtoSaveRequest {
    private String name;

    @Email(message = "Formato de email inválido")
    @NotNull(message = "Email deve ser preenchido")
    @NotBlank(message = "Email deve ser preenchido")
    private String email;

    private String phone;
    private String password;

    @NotNull(message = "Cpf deve ser preenchido")
    @NotBlank(message = "Cpf deve ser preenchido")
    @CPF(message = "Cpf inválido")
    private String cpf;
    private String date;

}
