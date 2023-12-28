package br.com.fourbank.api.service;

import br.com.fourbank.api.dao.account.AccountDao;
import br.com.fourbank.api.dto.transaction.request.TransactionPixDtoRequest;
import br.com.fourbank.api.dto.transaction.response.TransactionDtoResponse;
import br.com.fourbank.api.enums.TypeTransaction;
import br.com.fourbank.api.err.exceptions.FourBankException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class TransactionService {

    private AccountDao accountDao;

    public TransactionService(AccountDao accountDao) {
        this.accountDao = accountDao;
    }

    public TransactionDtoResponse transaction(TransactionPixDtoRequest transactionPixDtoRequest, Long idCustomer) {

        var accountDestiny = accountDao.accountByPixKey(transactionPixDtoRequest.getPixKey());
        if (accountDestiny == null) {
            throw new FourBankException("Chave não encontrada", HttpStatus.NOT_FOUND.value());
        }
        checkBalance(idCustomer, transactionPixDtoRequest.getValue());
        var accountOrigin = accountDao.accountIdByCustomerId(idCustomer);
        var result = accountDao.saveTransaction(accountOrigin, accountDestiny.getIdAccount(),
                transactionPixDtoRequest.getValue(), TypeTransaction.PIX.getType());
        result.setTypeTransaction(TypeTransaction.PIX.getDescription());
        return result;
    }

    private void checkBalance(Long idCustomer, BigDecimal value) {
        var account = accountDao.infoAccount(idCustomer);

        if (account.getValue().compareTo(value) < 0) {
            throw new FourBankException("Saldo insuficiente", HttpStatus.FORBIDDEN.value());
        }
    }
}
