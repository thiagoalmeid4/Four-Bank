package br.com.fourbank.api.dto.transaction.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class TransactionDtoResponse {

    private long idTransaction;

    private String customerNameOrigin;

    private String customerNameDestiny;

    private String dateTransaction;

    private String typeTransaction;

    private BigDecimal value;
}
