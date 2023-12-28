package br.com.fourbank.api.dao.account.impl;

import br.com.fourbank.api.dao.account.AccountDao;
import br.com.fourbank.api.dto.account.response.AccountDestinyDtoResponse;
import br.com.fourbank.api.dto.account.response.AccountOriginDtoResponse;
import br.com.fourbank.api.dto.transaction.response.TransactionDtoResponse;
import br.com.fourbank.api.err.exceptions.FourBankException;

import java.math.BigDecimal;
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
    public Boolean checkAccountExistence(long customerId) {
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

        try {
            jdbcCall.getJdbcTemplate().getDataSource().getConnection().setAutoCommit(false);
            jdbcCall.execute(sqlParameterSource);

        } catch (Exception e) {
            try {
                jdbcCall.getJdbcTemplate().getDataSource().getConnection().rollback();

            } catch (Exception ex) {
                throw new FourBankException("Erro ao registrar chave pix", HttpStatus.INTERNAL_SERVER_ERROR.value());
            }

            e.printStackTrace();
            throw new FourBankException("Erro ao registrar chave pix", HttpStatus.INTERNAL_SERVER_ERROR.value());
        }
    }

    @Override
    public Long accountByAgencyNumber(String agency, String number) {
        String query = "SELECT NR_ID_CONTA FROM TB_CONTA WHERE NR_CONTA = ? AND NR_AGENCIA = ?";
        try {
            Long idAccount = jdbcTemplate.queryForObject(query, new Object[] { number, agency },
                    new int[] { Types.VARCHAR, Types.VARCHAR }, Long.class);
            return idAccount;
        } catch (Exception e) {
            return null;
        }

    }

    @Override
    public Long accountIdByCustomerId(Long customerId) {

        String query = "SELECT NR_ID_CONTA FROM TB_CONTA WHERE FK_NR_ID_CLIENTE = ?";

        Long idAccount = jdbcTemplate.queryForObject(query, new Object[] { customerId }, new int[] { Types.BIGINT },
                Long.class);

        return idAccount;
    }

    @Override
    public AccountDestinyDtoResponse accountByPixKey(String pixKey) {

        String query = "select nm_cliente, nr_id_cliente, tb_conta.nr_id_conta \n" +
                "from tb_cliente join tb_conta\n" +
                "on nr_id_cliente = fk_nr_id_cliente join tb_pix_chaves\n" +
                "on nr_id_conta = fk_nr_id_conta\n" +
                "where ds_chave = ?";
        try {
            var result = jdbcTemplate.queryForMap(query, new Object[] { pixKey }, new int[] { Types.VARCHAR });
            var account = new AccountDestinyDtoResponse();
            account.setIdAccount((Long) result.get("nr_id_conta"));
            account.setNameCustomer((String) result.get("nm_cliente"));
            account.setIdCustomer((Long) result.get("nr_id_cliente"));
            return account;
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public TransactionDtoResponse saveTransaction(long accountOrigin, long accountDestiny, BigDecimal value, int type) {

        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("realizar_transferencia");

        SqlParameterSource sqlParameterSource = new MapSqlParameterSource()
                .addValue("p_id_conta_origem", accountOrigin)
                .addValue("p_id_conta_destino", accountDestiny)
                .addValue("p_valor_transferencia", value.doubleValue())
                .addValue("p_tipo_transacao", type);

        try {
            jdbcCall.getJdbcTemplate().getDataSource().getConnection().setAutoCommit(false);
            var result = jdbcCall.execute(sqlParameterSource);
            var transactionDtoResponse = new TransactionDtoResponse();
            transactionDtoResponse.setCustomerNameDestiny((String) result.get("nome_cliente_destino"));
            transactionDtoResponse.setCustomerNameOrigin((String) result.get("nome_cliente_origem"));
            transactionDtoResponse.setDateTransaction(result.get("dt_transacao").toString());
            transactionDtoResponse.setValue(
                    new BigDecimal(Float.parseFloat(result.get("valor_transferencia").toString())).setScale(2));
            transactionDtoResponse.setIdTransaction((Long) result.get("id_transacao"));
            return transactionDtoResponse;
        } catch (Exception e) {
            try {
                jdbcCall.getJdbcTemplate().getDataSource().getConnection().rollback();

            } catch (Exception ex) {
                throw new FourBankException("Erro interno ao realizar transferência",
                        HttpStatus.INTERNAL_SERVER_ERROR.value());

            }
            e.printStackTrace();
            throw new FourBankException("Erro interno ao realizar transferência",
                    HttpStatus.INTERNAL_SERVER_ERROR.value());
        }

    }

    @Override
    public AccountOriginDtoResponse infoAccount(long idCustomer) {

        String query = "SELECT * FROM OBTER_SALDO_CONTA(?)";
        var result = jdbcTemplate.queryForMap(query, new Object[] { idCustomer }, new int[] { Types.BIGINT });

        var accountOrigin = new AccountOriginDtoResponse();
        accountOrigin.setAccountNumber((String) result.get("nr_conta"));
        accountOrigin.setAgency((String) result.get("nr_agencia"));
        accountOrigin.setValue((BigDecimal) result.get("saldo_conta"));

        return accountOrigin;
    }

}