# Q004 — Реализация программы

## 1. Полный исходный код `PasswordValidator.java`

```java
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
```

## 2. Пояснение технических решений

- **R01 (чтение строки и EOF).** Используется `BufferedReader.readLine()`, который читает одну строку, отбрасывает завершающий `\n` и (при CRLF) `\r`. Пробелы и табуляции внутри строки сохраняются. При EOF до строки `readLine()` возвращает `null` — это преобразуется в `""`. Последующие строки не читаются: программа завершается после обработки первой строки, что соответствует R01 («последующие строки игнорируются») и уточнению Z09 (дочитывать ввод до EOF не требуется).
- **R02 (длина в UTF-16).** Используется `String.length()`, как явно указано в requirements-v2. Для суррогатной пары длина увеличивается на 2, что соответствует T16 (эмодзи даёт `CHAR`, но длина остаётся в диапазоне).
- **R03–R05 (проверки символов).** Все проверки выполняются независимо, простым перебором `charAt`. Заглавные — только `A–Z`; цифры — только `0–9`; допустимые — только `A–Z`, `a–z`, `0–9`. Кириллица и прочие символы не проходят R03/R04 и дают `CHAR` (T08).
- **R06–R11 (вывод).** Коды добавляются в `StringBuilder` строго в порядке `LEN`, `UPPER`, `DIGIT`, `CHAR`; каждый — с `\n`. Если ошибок нет, добавляется `OK\n`. Вывод выполняется одним `System.out.print`, без приглашений и диагностики в stderr (Z13).
- **Кодировка.** `InputStreamReader` с `StandardCharsets.UTF_8` — для предсказуемой трактовки многобайтовых символов (например, кириллицы в T08). Для ASCII-входа результат идентичен.
- **Объём.** Код содержит менее 150 непустых строк (без комментариев), соответствует ограничению 50–150. Искусственного увеличения объёма нет: структура минимальна (чтение, валидация, три вспомогательных метода).
- **Один файл, без package, без внешних зависимостей** — как требуется.

## 3. Команды компиляции и запуска

Компиляция (Java 17):

```bash
javac PasswordValidator.java
```

Запуск (пример с T01):

```bash
printf 'Passw0rd\n' | java PasswordValidator
```

Ожидаемый вывод T01: `OK`.

Запуск T12 (EOF, пустой ввод):

```bash
printf '' | java PasswordValidator
```

Ожидаемый вывод T12: `LEN`, `UPPER`, `DIGIT` (каждый на своей строке).

Запуск T11 (пустая первая строка, затем непустая):

```bash
printf '\nPassw0rd\n' | java PasswordValidator
```

Ожидаемый вывод T11: `LEN`, `UPPER`, `DIGIT`.

## Оговорка о фактическом выполнении

Компиляция и запуск **не выполнялись** в рамках этого ответа. Утверждения о соответствии T01–T20 являются ожидаемыми по построению кода, а не подтверждёнными фактическим запуском. Фактические результаты должны быть получены на шаге D (проверка реализации) с сохранением evidence согласно C02/C04.