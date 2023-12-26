package br.com.fourbank.api.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import br.com.fourbank.api.dto.others.request.AuthDtoRequest;
import br.com.fourbank.api.service.AuthService;

@RestController
public class AuthController {
    
    @Autowired
    private AuthService authService;

    @PostMapping(path = "/get-token")
    public ResponseEntity<?> getToken(@RequestBody AuthDtoRequest authDtoRequest){
        return ResponseEntity.ok(authService.getToken(authDtoRequest));
    }
    
}
