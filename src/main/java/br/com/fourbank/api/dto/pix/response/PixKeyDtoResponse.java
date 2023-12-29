package br.com.fourbank.api.dto.pix.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class PixKeyDtoResponse {

    private String pixKey;

    private String typePixKey;
}
