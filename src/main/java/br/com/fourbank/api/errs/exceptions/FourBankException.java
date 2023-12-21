package br.com.fourbank.api.errs.exceptions;

import lombok.Getter;

@Getter
public class FourBankException extends RuntimeException{

    private int status;

    public FourBankException(String message, int status) {
        super(message);
        this.status = status;
    }
}
