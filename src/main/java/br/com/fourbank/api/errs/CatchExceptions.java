package br.com.fourbank.api.errs;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.context.request.ServletWebRequest;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice
public class CatchExceptions extends ResponseEntityExceptionHandler{

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex,
            HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        
            List<ErrResponse> errors = new ArrayList<>();
            
            ex.getBindingResult().getFieldErrors().forEach(err -> {
                errors.add(new ErrResponse(err.getDefaultMessage(),HttpStatus.BAD_REQUEST.value(),
                ((ServletWebRequest) request).getRequest().getRequestURI(), LocalDateTime.now()));
            });

            return new ResponseEntity<Object>(errors,HttpStatus.BAD_REQUEST);
    }
    

}
