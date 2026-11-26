#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

SOURCE="${1:-src/PasswordValidator.java}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

CLASSES="$WORK_DIR/classes"
EXPECTED="$WORK_DIR/expected.txt"
ACTUAL="$WORK_DIR/actual.txt"

mkdir -p "$CLASSES"

passed=0
failed=0

echo "=== Password Validator Test Runner ==="
echo
echo "Source: $SOURCE"
sha256sum "$SOURCE"
echo

java -version 2>&1
javac -version 2>&1

echo
echo "Compilation:"
echo "javac --release 17 -encoding UTF-8 -d <classes> $SOURCE"

javac --release 17 -encoding UTF-8 \
    -d "$CLASSES" "$SOURCE"

echo "Compilation: PASS"

run_test() {
    local id="$1"
    local description="$2"
    local input="$3"
    local expected="$4"
    local exit_code=0

    printf '%s' "$expected" > "$EXPECTED"

    printf '%s' "$input" |
        java -cp "$CLASSES" PasswordValidator \
        > "$ACTUAL" || exit_code=$?

    echo
    echo "--- $id: $description ---"
    printf 'Input:    %q\n' "$input"
    printf 'Expected: %q\n' "$expected"
    printf 'Actual:   '
    sed -n 'l' "$ACTUAL"
    echo "Exit code: $exit_code"

    if [[ "$exit_code" -eq 0 ]] && cmp -s "$EXPECTED" "$ACTUAL"; then
        echo "Result: PASS"
        passed=$((passed + 1))
    else
        echo "Result: FAIL"
        diff -u "$EXPECTED" "$ACTUAL" || true
        failed=$((failed + 1))
    fi
}

run_test T01 "Minimum valid length" \
    $'Passw0rd\n' $'OK\n'

run_test T02 "Maximum valid length" \
    $'Abcdefgh12345678\n' $'OK\n'

run_test T03 "Length below minimum" \
    $'Abc1234\n' $'LEN\n'

run_test T04 "Length above maximum" \
    $'Abcdefgh123456789\n' $'LEN\n'

run_test T05 "Missing uppercase letter" \
    $'password1\n' $'UPPER\n'

run_test T06 "Missing digit" \
    $'Password\n' $'DIGIT\n'

run_test T07 "Space inside password" \
    $'Pass word1\n' $'CHAR\n'

run_test T08 "Cyrillic characters" \
    $'Пароль123\n' $'UPPER\nCHAR\n'

run_test T09 "Multiple violations" \
    $'abc\n' $'LEN\nUPPER\nDIGIT\n'

run_test T10 "Missing digit and invalid character" \
    $'Password!\n' $'DIGIT\nCHAR\n'

run_test T11 "Empty first line" \
    $'\nPassw0rd\n' $'LEN\nUPPER\nDIGIT\n'

run_test T12 "EOF before first line" \
    '' $'LEN\nUPPER\nDIGIT\n'

run_test T13 "Single empty line" \
    $'\n' $'LEN\nUPPER\nDIGIT\n'

run_test T14 "Tab inside password" \
    $'Pass\tw0rd\n' $'CHAR\n'

run_test T15 "Ignore second line" \
    $'Passw0rd\nInvalid!\n' $'OK\n'

run_test T16 "UTF-16 length boundary" \
    $'Abc123😀\n' $'CHAR\n'

run_test T17 "Missing uppercase and digit" \
    $'abcdefgh\n' $'UPPER\nDIGIT\n'

run_test T18 "Maximum length with invalid character" \
    $'Abcdefgh1234567!\n' $'CHAR\n'

run_test T19 "All four violations" \
    $'ab!\n' $'LEN\nUPPER\nDIGIT\nCHAR\n'

run_test T20 "Digit first and uppercase last" \
    $'1bcdefgH\n' $'OK\n'

echo
echo "=== Test Summary ==="
echo "Total:  $((passed + failed))"
echo "Passed: $passed"
echo "Failed: $failed"

if [[ "$failed" -ne 0 ]]; then
    exit 1
fi

exit 0
