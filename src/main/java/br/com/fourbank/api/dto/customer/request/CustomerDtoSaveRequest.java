package br.com.fourbank.api.dto.customer.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.validator.constraints.br.CPF;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CustomerDtoSaveRequest {

    @NotNull(message = "Nome deve ser informado")
    private String name;

    @Email(message = "Formato de email inválido")
    @NotNull(message = "Email deve ser informado")
    private String email;

    @NotNull(message = "Telefone deve ser informado")
    @Pattern(regexp = "\\(\\d{2}\\)\\s\\d{4,5}-\\d{4}", message = "Formato de telefone inválido")
    private String phone;

    @NotNull(message = "Senha deve ser informada")
    @Size(min = 6, max = 20, message = "Senha deve conter entre 6 e 20 caracteres")
    private String password;

    @NotNull(message = "Cpf deve ser informado")
    @CPF(message = "Cpf inválido")
    private String cpf;
    
    @NotNull(message = "Data de nascimento deve ser informada")
    @Pattern(regexp = "\\d{2}/\\d{2}/\\d{4}", message = "Formato de data de nascimento inválido")
    private String dateBirth;

}
