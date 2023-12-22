package br.com.fourbank.api.err;

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

    public ErrResponse(String message, int status){
        this.message = message;
        this.status = status;
        this.path = "";
        this.timestamp = LocalDateTime.now();
    }

}
