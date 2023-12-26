package br.com.fourbank.api.config.utils;

import java.util.Date;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;

import br.com.fourbank.api.dto.others.response.TokenJwtDtoResponse;

@Component
public class TokenUtils {

    @Value("${api.issuer}")
    private String issuer;

    @Value("${api.secret.key}")
    private String secretKey;

    @Value("${api.expiry.time}")
    private Long expiryTime;

    public TokenJwtDtoResponse getToken(Map<String, Object> dataAuthentication) {
        String token = JWT.create()
                .withIssuer(issuer)
                .withSubject(dataAuthentication.get("cpf").toString())
                .withClaim("customer_id", dataAuthentication.get("cliente_id").toString())
                .withClaim("cpf", dataAuthentication.get("cpf").toString())
                .withClaim("password", dataAuthentication.get("senha").toString())
                .withExpiresAt(new Date(System.currentTimeMillis() + (1000 * expiryTime)))
                .sign(Algorithm.HMAC256(secretKey));
        return new TokenJwtDtoResponse(token);
    }

    public DecodedJWT verifyToken(String token) {
        return JWT.require(Algorithm.HMAC256(secretKey))
                .withIssuer(issuer)
                .build()
                .verify(token);
    }
    
}
