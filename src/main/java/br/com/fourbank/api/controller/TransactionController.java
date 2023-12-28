package br.com.fourbank.api.controller;

import br.com.fourbank.api.dto.transaction.request.TransactionPixDtoRequest;
import br.com.fourbank.api.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/transaction")
public class TransactionController {
    @Autowired
    private TransactionService transactionService;

    @PostMapping(path = "/pix")
    public ResponseEntity<?> pixTransaction(@RequestBody TransactionPixDtoRequest pixDtoRequest){
        var idCustomer = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        var response = transactionService.transaction(pixDtoRequest, Long.parseLong(idCustomer.toString()));

        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping(path = "/history")
    public ResponseEntity<?> transactionHistory(){
        var idCustomer = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        var response = transactionService.transactionHistory(Long.parseLong(idCustomer.toString()));

        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}
