package br.com.fourbank.api.service;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import br.com.fourbank.api.config.utils.TokenUtils;
import br.com.fourbank.api.dao.customer.CustomerDao;
import br.com.fourbank.api.dto.others.request.AuthDtoRequest;
import br.com.fourbank.api.dto.others.response.TokenJwtDtoResponse;
import br.com.fourbank.api.err.exceptions.FourBankException;

@Service
public class AuthService {

    private TokenUtils tokenUtils;

    private CustomerDao customerDao;

    private PasswordEncoder passwordEncoder;

    public AuthService(TokenUtils tokenUtils , CustomerDao customerDao, PasswordEncoder passwordEncoder) {
        this.tokenUtils = tokenUtils;
        this.customerDao = customerDao;
        this.passwordEncoder = passwordEncoder;
    }

    public TokenJwtDtoResponse getToken(AuthDtoRequest authDtoRequest) {
        var dataAuthentication = getDataAuthentication(authDtoRequest);
        return tokenUtils.getToken(dataAuthentication);
    }

    private Map<String, Object> getDataAuthentication(AuthDtoRequest authDtoRequest) {
        var dataAuthentication = customerDao.getDataAuthentication(authDtoRequest.getLogin());
        if (dataAuthentication == null) {
            throw new FourBankException("Login inválido", HttpStatus.UNAUTHORIZED.value());
        }
        checkPassword(authDtoRequest.getPassword(), dataAuthentication.get("senha").toString());
        return dataAuthentication;
    }

    private void checkPassword(String inputPassword, String dbPassword) {
        if (!passwordEncoder.matches(inputPassword, dbPassword)) {
            throw new FourBankException("Senha inválida", HttpStatus.UNAUTHORIZED.value());
        }
    }

}
