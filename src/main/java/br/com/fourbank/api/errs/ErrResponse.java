package br.com.fourbank.api.errs;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class ErrResponse {
    
    private String message;
    private int status;
    private String path;
    private LocalDateTime timestamp;

}
