package br.com.fourbank.api.service;

import br.com.fourbank.api.config.utils.DateFormatter;
import br.com.fourbank.api.dao.account.AccountDao;
import br.com.fourbank.api.dto.transaction.request.TransactionPixDtoRequest;
import br.com.fourbank.api.dto.transaction.request.TransactionTedDtoRequest;
import br.com.fourbank.api.dto.transaction.response.TransactionDtoResponse;
import br.com.fourbank.api.dto.transaction.response.TransactionHistoryDtoResponse;
import br.com.fourbank.api.enums.TypeTransaction;
import br.com.fourbank.api.err.exceptions.FourBankException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class TransactionService {

    private AccountDao accountDao;

    public TransactionService(AccountDao accountDao) {
        this.accountDao = accountDao;
    }

    public TransactionDtoResponse transaction(TransactionPixDtoRequest transactionPixDtoRequest, Long idCustomer) {
        checkValue(transactionPixDtoRequest.getValue());
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

    public TransactionDtoResponse transactionTed(TransactionTedDtoRequest ted, Long idCustomer){
        checkValue(ted.getValue());
        var accountDestiny = accountDao.accountByAgencyNumber(ted.getAgency(), ted.getAccountNumber());
        if(accountDestiny == null){
            throw new FourBankException("Conta não encontrada",HttpStatus.NOT_FOUND.value());
        }
        checkBalance(idCustomer,ted.getValue());
        var accountOrigin = accountDao.accountIdByCustomerId(idCustomer);
        var result = accountDao.saveTransaction(accountOrigin, accountDestiny,
                ted.getValue(), TypeTransaction.TED.getType());
        result.setTypeTransaction(TypeTransaction.TED.getDescription());
        return result;
    }

    public List<TransactionHistoryDtoResponse> transactionHistory(Long idCustomer) {
        var result = accountDao.transactionHistory(idCustomer);
        result.stream().forEach(transaction -> {
            transaction.setDateTransaction(DateFormatter.formatarData(transaction.getDateTransaction()));
        });
        result.stream().forEach(transaction -> {
            if(transaction.getOriginDestiny() == null && transaction.getTypeTransaction().equals("TAXA")){
                transaction.setOriginDestiny("SERVIÇO DE TRANSFERÊNCIA - TED");
            }
        });
        return result;
    }

    private void checkBalance(Long idCustomer, BigDecimal value) {
        var account = accountDao.infoAccount(idCustomer);

        if (account.getValue().compareTo(value) < 0) {
            throw new FourBankException("Saldo insuficiente", HttpStatus.FORBIDDEN.value());
        }
    }

    private void checkValue(BigDecimal value) {
        if (value.compareTo(BigDecimal.ZERO) <= 0) {
            throw new FourBankException("Valor inválido", HttpStatus.BAD_REQUEST.value());
        }
    }
}
