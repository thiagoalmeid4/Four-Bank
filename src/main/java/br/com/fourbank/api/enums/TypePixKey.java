package br.com.fourbank.api.enums;

public enum TypePixKey {
    
    CPF (0),
    EMAIL (1),
    PHONE (2),
    RANDOM (3);
    
    private int type;

    private TypePixKey(int type) {
        this.type = type;
    }

    public int getType() {
        return type;
    }
}
