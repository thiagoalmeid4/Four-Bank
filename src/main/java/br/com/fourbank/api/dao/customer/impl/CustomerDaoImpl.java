package br.com.fourbank.api.dao.customer.impl;

import br.com.fourbank.api.dao.customer.CustomerDao;
import br.com.fourbank.api.dtos.customer.request.CustomerDtoSaveRequest;
import br.com.fourbank.api.errs.exceptions.FourBankException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.sql.SQLException;

@Repository
public class CustomerDaoImpl implements CustomerDao {

    private JdbcTemplate jdbcTemplate;

    public CustomerDaoImpl(JdbcTemplate jdbcTemplate){
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void saveCustomer(CustomerDtoSaveRequest customer) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withFunctionName("salvar_cliente");

        SqlParameterSource sqlParameterSource = new MapSqlParameterSource()
                .addValue("p_ds_email",customer.getEmail())
                .addValue("p_ds_senha",customer.getPassword())
                .addValue("p_dt_nascimento",customer.getDate())
                .addValue("p_nm_cliente",customer.getDate())
                .addValue("p_nr_cpf",customer.getCpf())
                .addValue("p_nr_telefone",customer.getPhone());

        try{
   //         jdbcCall.getJdbcTemplate().getDataSource().getConnection().setAutoCommit(false);
            jdbcCall.execute();
        }catch (Exception e){
 //           try {
//                jdbcCall.getJdbcTemplate().getDataSource().getConnection().rollback();
 //           } catch (SQLException ex) {
 //               throw new RuntimeException(ex);
  //          }
            e.printStackTrace();
            throw new FourBankException("Erro interno ao salvar cliente", HttpStatus.BAD_REQUEST.value());
        }
    }
}
