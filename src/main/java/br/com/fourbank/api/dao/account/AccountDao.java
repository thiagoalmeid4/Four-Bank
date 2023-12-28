package br.com.fourbank.api.dao.account;

import br.com.fourbank.api.dto.account.response.AccountDestinyDtoResponse;
import br.com.fourbank.api.dto.account.response.AccountInfoDtoResponse;
import br.com.fourbank.api.dto.account.response.AccountOriginDtoResponse;
import br.com.fourbank.api.dto.transaction.response.TransactionDtoResponse;
import br.com.fourbank.api.dto.transaction.response.TransactionHistoryDtoResponse;

import java.math.BigDecimal;
import java.util.List;

public interface AccountDao {
    
    void saveAccount(long customerId,String accountNumber, String accountAgency);
    Boolean checkAccountExistence(long customerId);

    void savePixKey(long customerId, int typeKey);

    Long accountByAgencyNumber(String agency, String number);

    Long accountIdByCustomerId(Long customerId);

    AccountDestinyDtoResponse accountByPixKey(String pixKey);

    TransactionDtoResponse saveTransaction(long accountOrigin, long accountDestiny, BigDecimal value, int type);

    AccountOriginDtoResponse infoAccount(long idCustomer);

    List<TransactionHistoryDtoResponse> transactionHistory(long idCustomer);

    AccountInfoDtoResponse accountInfo(long idCustomer);

}
