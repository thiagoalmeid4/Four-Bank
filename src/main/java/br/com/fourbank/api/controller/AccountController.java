package br.com.fourbank.api.controller;

import br.com.fourbank.api.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping(path = "/save-pix-key")
    public ResponseEntity<?>savePixKey(@RequestParam ("type_key") String typeKey){
        var customerId = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        accountService.savePixKey(Long.parseLong(customerId.toString()), typeKey);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @GetMapping(path = "/find-account/pix")
    public ResponseEntity<?>getAccountByPix(@RequestParam ("key") String pixKey){
        var account = accountService.getAccountByPixKey(pixKey);
        return new ResponseEntity<>(account, HttpStatus.OK);
    }

    @GetMapping(path = "/account-info")
    public ResponseEntity<?> accountInfo(){
        var idCustomer = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        var response = accountService.accountInfo(Long.parseLong(idCustomer.toString()));
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping(path = "/my-pix-keys")
    public ResponseEntity<?>pixKeysOfCustomer(){
        var idCustomer = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        var response = accountService.pixKeysOfCustomer(Long.parseLong(idCustomer.toString()));

        return new ResponseEntity<>(response, HttpStatus.OK);
    }
    
}
