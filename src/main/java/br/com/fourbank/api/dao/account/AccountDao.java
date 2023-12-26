package br.com.fourbank.api.dao.account;

public interface AccountDao {
    
    void saveAccount(long customerId,String accountNumber, String accountAgency);
    boolean checkAccountExistence(long customerId);

}
