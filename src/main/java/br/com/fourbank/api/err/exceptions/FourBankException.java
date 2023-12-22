package br.com.fourbank.api.err.exceptions;

import java.util.List;

import br.com.fourbank.api.err.ErrResponse;
import lombok.Getter;

@Getter
public class FourBankException extends RuntimeException{
    
    private int status;

    private List<ErrResponse> errors;

    public FourBankException(String message, int status) {
        super(message);
        this.status = status;
    }

    public FourBankException(List<ErrResponse> errors, int status) {
        this.errors = errors;
        this.status = status;
    }


}
