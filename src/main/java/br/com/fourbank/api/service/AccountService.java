package br.com.fourbank.api.service;

import br.com.fourbank.api.dao.account.AccountDao;
import br.com.fourbank.api.dto.account.response.AccountDestinyDtoResponse;
import br.com.fourbank.api.dto.account.response.AccountInfoDtoResponse;
import br.com.fourbank.api.dto.pix.response.PixKeyDtoResponse;
import br.com.fourbank.api.enums.TypePixKey;
import br.com.fourbank.api.err.exceptions.FourBankException;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Random;

@Service
public class AccountService {

    private AccountDao accountDao;

    public AccountService(AccountDao accountDao) {
        this.accountDao = accountDao;
    }

    public void saveAccount(long customerId) {

        checkAccountExistence(customerId);

        String accountNumber = accountNumberGenerator();

        String accountAgency = accontAgencyGenerator();

        accountDao.saveAccount(customerId, accountNumber, accountAgency);
    }

    public void savePixKey(long customerId, String typeKey) {

        int type = TypePixKey.valueOf(typeKey.toUpperCase()).getType();

        accountDao.savePixKey(customerId, type);
    }

    public AccountDestinyDtoResponse getAccountByPixKey(String pixKey) {
        var account = accountDao.accountByPixKey(pixKey);
        if (account == null) {
            throw new FourBankException("Chave não encontrada", HttpStatus.NOT_FOUND.value());
        }
        return account;
    }

    public AccountInfoDtoResponse accountInfo(long idCustomer) {
        return accountDao.accountInfo(idCustomer);
    }

    public List<PixKeyDtoResponse> pixKeysOfCustomer(Long idCustomer){
        var result  = accountDao.pixKeysOfCustomer(idCustomer);
        return result;
    }

    private String accountNumberGenerator() {

        Random random = new Random();

        long numberGenerated = 10_000_000 + random.nextInt(90_000_000);

        return String.valueOf(numberGenerated);

    }

    private String accontAgencyGenerator() {

        Random random = new Random();

        int agencyGenerated = 1_000 + random.nextInt(9_000);

        return String.valueOf(agencyGenerated);
    }

    private void checkAccountExistence(long customerId) {

        if (accountDao.checkAccountExistence(customerId)) {
            throw new FourBankException("Você ja possui uma conta", HttpStatus.CONFLICT.value());
        }

    }

}