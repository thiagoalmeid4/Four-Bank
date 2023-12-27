package br.com.fourbank.api.dto.transaction.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class TransactionPixDtoRequest {

    private String pixKey;

    private BigDecimal value;
}
