package br.com.fourbank.api.dao.account.impl;

import br.com.fourbank.api.dao.account.AccountDao;
import br.com.fourbank.api.err.exceptions.FourBankException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

@Repository
public class AccountDaoImpl implements AccountDao {

    private JdbcTemplate jdbcTemplate;

    public AccountDaoImpl(JdbcTemplate jdbcTemplate){
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void saveAccount(long customerId, String accountNumber, String accountAgency) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("salvar_conta");

        SqlParameterSource sqlParameterSource = new MapSqlParameterSource()
                .addValue("p_nr_id_cliente", customerId)
                .addValue("p_nr_conta", accountNumber)
                .addValue("p_nr_agencia", accountAgency);

        try{
            simpleJdbcCall.getJdbcTemplate().getDataSource().getConnection().setAutoCommit(false);
            simpleJdbcCall.execute(sqlParameterSource);

        }catch (Exception e){

            try{
                simpleJdbcCall.getJdbcTemplate().getDataSource().getConnection().rollback();

            }catch (Exception ex){

                throw new RuntimeException();
            }
            e.printStackTrace();
            throw new FourBankException("Erro interno ao salvar conta", HttpStatus.BAD_REQUEST.value());
        }

    }
}
