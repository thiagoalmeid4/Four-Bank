package br.com.fourbank.api.dto.transaction.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class TransactionHistoryDtoResponse {

    private String flag;
    private String dateTransaction;
    private BigDecimal value;
    private String originDestiny;
    private String typeTransaction;

}
