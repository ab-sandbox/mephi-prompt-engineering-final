# Матрица прослеживаемости — v1

Требования: `docs/requirements-v2.md`.
Сценарии: `tests/scenarios-v1.md`.
Финальная реализация: `src/PasswordValidator.java` (v1).
Результаты регрессии: `evidence/tests-final.log` (20 PASS, 0 FAIL).

| R-ID | Требование (кратко)                                              | T-ID (покрывающие)                          | Статус | Evidence                                            |
|------|------------------------------------------------------------------|---------------------------------------------|--------|-----------------------------------------------------|
| R01  | Чтение одной строки, EOF → `""`, последующие строки игнорируются | T11, T12, T13, T14, T15                     | PASS   | `evidence/tests-final.log` (соответствующие секции) |
| R02  | Длина 8–16 в UTF-16 (`String.length()`)                          | T01, T02, T03, T04, T16, T17, T18, T20      | PASS   | `evidence/tests-final.log`                          |
| R03  | Хотя бы одна заглавная `A-Z`                                     | T01, T02, T05, T08, T17, T20                | PASS   | `evidence/tests-final.log`                          |
| R04  | Хотя бы одна цифра `0-9`                                         | T01, T02, T06, T10, T17, T20                | PASS   | `evidence/tests-final.log`                          |
| R05  | Только `A-Z`, `a-z`, `0-9`                                       | T01, T02, T07, T08, T10, T14, T16, T18, T19 | PASS   | `evidence/tests-final.log`                          |
| R06  | `OK` при отсутствии ошибок                                       | T01, T02, T15, T20                          | PASS   | `evidence/tests-final.log`                          |
| R07  | `LEN` при нарушении длины                                        | T03, T04, T09, T11, T12, T13, T19           | PASS   | `evidence/tests-final.log`                          |
| R08  | `UPPER` при отсутствии заглавной                                 | T05, T08, T09, T11, T12, T13, T17, T19      | PASS   | `evidence/tests-final.log`                          |
| R09  | `DIGIT` при отсутствии цифры                                     | T06, T09, T10, T11, T12, T13, T17, T19      | PASS   | `evidence/tests-final.log`                          |
| R10  | `CHAR` при недопустимом символе                                  | T07, T08, T10, T14, T16, T18, T19           | PASS   | `evidence/tests-final.log`                          |
| R11  | Порядок `LEN`→`UPPER`→`DIGIT`→`CHAR`, без `OK` при ошибках       | T08, T09, T10, T11, T12, T13, T17, T19      | PASS   | `evidence/tests-final.log` (порядок строк в Actual) |

## Итог

Все требования R01–R11 покрыты тестовыми сценариями.
Непроверенных требований нет.

Отдельный сценарий с разделителем строк CRLF
не выполнялся.
