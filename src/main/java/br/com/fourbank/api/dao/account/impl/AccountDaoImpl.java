package br.com.fourbank.api.dao.account.impl;

import br.com.fourbank.api.dao.account.AccountDao;
import br.com.fourbank.api.err.exceptions.FourBankException;

import java.sql.Types;

import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

@Repository
public class AccountDaoImpl implements AccountDao {

    private JdbcTemplate jdbcTemplate;

    public AccountDaoImpl(JdbcTemplate jdbcTemplate) {
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

        try {
            simpleJdbcCall.getJdbcTemplate().getDataSource().getConnection().setAutoCommit(false);
            simpleJdbcCall.execute(sqlParameterSource);

        } catch (Exception e) {

            try {
                simpleJdbcCall.getJdbcTemplate().getDataSource().getConnection().rollback();

            } catch (Exception ex) {

                throw new RuntimeException();
            }
            e.printStackTrace();
            throw new FourBankException("Erro interno ao salvar conta", HttpStatus.BAD_REQUEST.value());
        }

    }

    @Override
    public boolean checkAccountExistence(long customerId) {
        String query = "SELECT COUNT(1) FROM TB_CONTA WHERE FK_NR_ID_CLIENTE = ?";
        int count = jdbcTemplate.queryForObject(query, new Object[] { customerId }, new int[] { Types.BIGINT },
                Integer.class);
        return count > 0;
    }

    @Override
    public void savePixKey(long customerId, int typeKey) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("registrar_chave_pix");

        SqlParameterSource sqlParameterSource = new MapSqlParameterSource()
                .addValue("p_cliente_id", customerId)
                .addValue("p_tipo_chave", typeKey);

        try{
            jdbcCall.getJdbcTemplate().getDataSource().getConnection().setAutoCommit(false);
            jdbcCall.execute(sqlParameterSource);

        }catch (Exception e){
            try{
                jdbcCall.getJdbcTemplate().getDataSource().getConnection().rollback();

            }catch(Exception ex){
                throw new FourBankException("Erro ao registrar chave pix", HttpStatus.INTERNAL_SERVER_ERROR.value());
            }

            e.printStackTrace();
            throw new FourBankException("Erro ao registrar chave pix", HttpStatus.INTERNAL_SERVER_ERROR.value());
        }
    }

}
