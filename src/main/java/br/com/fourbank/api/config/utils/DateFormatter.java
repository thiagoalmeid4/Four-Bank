package br.com.fourbank.api.config.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DateFormatter {

    public static String formatarData(String dataOriginal) {
        try {
            SimpleDateFormat formatoOriginal = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date data = formatoOriginal.parse(dataOriginal);

            SimpleDateFormat formatoNovo = new SimpleDateFormat("dd 'de' MMM yyyy HH:mm:ss");
            return formatoNovo.format(data);
        } catch (ParseException e) {
            e.printStackTrace();
            return null;
        }
    }
}
