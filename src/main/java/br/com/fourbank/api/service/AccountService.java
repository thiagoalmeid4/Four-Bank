package br.com.fourbank.api.service;

import br.com.fourbank.api.dao.account.AccountDao;
import org.springframework.stereotype.Service;

import java.util.Random;

@Service
public class AccountService {

    private AccountDao accountDao;

    public AccountService(AccountDao accountDao){ this.accountDao = accountDao; }

    public void saveAccount(long customerId){

        String accountNumber = accountNumberGenerator();

        String accountAgency = accontAgencyGenerator();

        accountDao.saveAccount(customerId,accountNumber,accountAgency);
    }
    private String accountNumberGenerator(){

        Random random = new Random();

        long numberGenerated = 10_000_000 + random.nextInt(90_000_000);

        return String.valueOf(numberGenerated);

    }
    private String accontAgencyGenerator(){

        Random random = new Random();

        int agencyGenerated = 1_000 + random.nextInt(9_000);

       return String.valueOf(agencyGenerated);
    }
}