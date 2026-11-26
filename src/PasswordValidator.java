import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

/**
 * Консольный валидатор пароля.
 * Реализует требования R01–R11 из requirements-v2.md.
 */
public class PasswordValidator {

    public static void main(String[] args) throws IOException {
        String password = readPassword();
        StringBuilder out = new StringBuilder();
        boolean ok = validate(password, out);
        if (ok) {
            out.append("OK\n");
        }
        System.out.print(out);
        System.out.flush();
    }

    /**
     * R01: читает одну строку; разделитель не включается;
     * при EOF до строки возвращается "".
     * Читаем через InputStreamReader, чтобы корректно обработать CRLF:
     * BufferedReader.readLine() отбрасывает \r\n и \n.
     */
    private static String readPassword() throws IOException {
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(System.in, StandardCharsets.UTF_8));
        String line = reader.readLine();
        return line == null ? "" : line;
    }

    /**
     * Проверяет пароль. Возвращает true, если ошибок нет.
     * Коды ошибок добавляются в out в порядке LEN, UPPER, DIGIT, CHAR (R11).
     */
    private static boolean validate(String password, StringBuilder out) {
        boolean hasError = false;

        // R02, R07: длина 8..16 в единицах UTF-16 (String.length())
        int len = password.length();
        if (len < 8 || len > 16) {
            out.append("LEN\n");
            hasError = true;
        }

        // R03, R08: хотя бы одна заглавная латинская буква A-Z
        if (!containsUpperLatin(password)) {
            out.append("UPPER\n");
            hasError = true;
        }

        // R04, R09: хотя бы одна цифра 0-9
        if (!containsDigit(password)) {
            out.append("DIGIT\n");
            hasError = true;
        }

        // R05, R10: только A-Z, a-z, 0-9
        if (!onlyAllowedChars(password)) {
            out.append("CHAR\n");
            hasError = true;
        }

        return !hasError;
    }

    private static boolean containsUpperLatin(String s) {
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c >= 'A' && c <= 'Z') {
                return true;
            }
        }
        return false;
    }

    private static boolean containsDigit(String s) {
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c >= '0' && c <= '9') {
                return true;
            }
        }
        return false;
    }

    private static boolean onlyAllowedChars(String s) {
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            boolean allowed = (c >= 'A' && c <= 'Z')
                              || (c >= 'a' && c <= 'z')
                              || (c >= '0' && c <= '9');
            if (!allowed) {
                return false;
            }
        }
        return true;
    }
}
