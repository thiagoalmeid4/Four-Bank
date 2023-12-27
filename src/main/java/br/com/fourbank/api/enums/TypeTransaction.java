package br.com.fourbank.api.enums;

public enum TypeTransaction {
    PIX(0),
    TED(1);

    private int type;

    private TypeTransaction(int type){this.type = type;}

    public int getType() {return type;}
}
