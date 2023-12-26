package br.com.fourbank.api.controller;

import br.com.fourbank.api.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AccountController {
    @Autowired
    private AccountService accountService;

    @PostMapping(path = "/save-account")
    public ResponseEntity<?> saveAccount(){
        var customerId = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        accountService.saveAccount(Long.parseLong(customerId.toString()));
        return new ResponseEntity<>(HttpStatus.CREATED);
    }
}
