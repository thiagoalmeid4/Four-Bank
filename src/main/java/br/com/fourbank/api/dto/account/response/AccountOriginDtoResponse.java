package br.com.fourbank.api.dto.account.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class AccountOriginDtoResponse {

    private String agency;

    private String accountNumber;

    private BigDecimal value;
}
