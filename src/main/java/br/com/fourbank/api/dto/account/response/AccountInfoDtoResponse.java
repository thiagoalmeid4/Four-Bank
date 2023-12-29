package br.com.fourbank.api.dto.account.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class AccountInfoDtoResponse {

    private String customerName;
    private String accountNumber;
    private String accountAgency;
    private BigDecimal value;
    
}
