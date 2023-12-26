package br.com.fourbank.api.dto.others.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class AuthDtoRequest {
    
    public String login;
    public String password;

}
