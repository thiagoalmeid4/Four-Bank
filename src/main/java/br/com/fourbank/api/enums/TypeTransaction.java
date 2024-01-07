package br.com.fourbank.api.enums;

public enum TypeTransaction {
    PIX(0, "PIX"),
    TED(1, "TED"),
    TAXA(2, "TAXA");

    private int type;
    private String description;

    private TypeTransaction(int type, String description){this.type = type; this.description = description;}

    public int getType() {return type;}

    public String getDescription() {
        return description;
    }
}
