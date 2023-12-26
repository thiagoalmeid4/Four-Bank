package br.com.fourbank.api.dao.customer.impl;

import br.com.fourbank.api.dao.customer.CustomerDao;
import br.com.fourbank.api.dto.customer.request.CustomerDtoSaveRequest;
import br.com.fourbank.api.err.exceptions.FourBankException;

import java.sql.Types;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

@Repository
public class CustomerDaoImpl implements CustomerDao {

    private JdbcTemplate jdbcTemplate;

    public CustomerDaoImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void saveCustomer(CustomerDtoSaveRequest customer) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("salvar_cliente");

        SqlParameterSource sqlParameterSource = new MapSqlParameterSource()
                .addValue("p_ds_email", customer.getEmail())
                .addValue("p_ds_senha", customer.getPassword())
                .addValue("p_dt_nascimento", customer.getDateBirth())
                .addValue("p_nm_cliente", customer.getDateBirth())
                .addValue("p_nr_cpf", customer.getCpf())
                .addValue("p_nr_telefone", customer.getPhone());

        try {
            jdbcCall.getJdbcTemplate().getDataSource().getConnection().setAutoCommit(false);
            jdbcCall.execute(sqlParameterSource);
        } catch (Exception e) {
            try {
                jdbcCall.getJdbcTemplate().getDataSource().getConnection().rollback();
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }
            e.printStackTrace();
            throw new FourBankException("Erro interno ao salvar cliente", HttpStatus.BAD_REQUEST.value());
        }
    }

    @Override
    public Boolean checkCpf(String cpf) {
        String query = "SELECT COUNT(1) FROM TB_CLIENTE WHERE NR_CPF = ?";
        int count = jdbcTemplate.queryForObject(query, new Object[] { cpf }, new int[] { Types.VARCHAR },
                Integer.class);
        return count > 0;
    }

    @Override
    public Boolean checkEmail(String email) {
        String query = "SELECT COUNT(1) FROM TB_CLIENTE WHERE DS_EMAIL = ?";
        int count = jdbcTemplate.queryForObject(query, new Object[] { email }, new int[] { Types.VARCHAR },
                Integer.class);
        return count > 0;
    }

    @Override
    public Boolean checkPhone(String phone) {
        String query = "SELECT COUNT(1) FROM TB_CLIENTE WHERE NR_TELEFONE = ?";
        int count = jdbcTemplate.queryForObject(query, new Object[] { phone }, new int[] { Types.VARCHAR },
                Integer.class);
        return count > 0;
    }

    @Override
    public Map<String, Object> getDataAuthentication(String login) {
        String query = "SELECT * FROM OBTER_DADOS_AUTENTICACAO(?)";
        try {
            Map<String, Object> result = jdbcTemplate.queryForMap(query, new Object[] { login });
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
