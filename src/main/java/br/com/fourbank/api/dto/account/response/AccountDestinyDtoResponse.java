package br.com.fourbank.api.dto.account.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class AccountDestinyDtoResponse {

    private Long idAccount;

    private Long idCustomer;

    private String nameCustomer;

}
