#!/usr/bin/env python3
"""Audita los SQL de datos sin conectarse a PostgreSQL."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
FILES = ["country.sql", "city.sql", "countrylanguage.sql"]


def row_fields(line):
    s = line.strip().rstrip(",;")
    if not s.startswith("(") or not s.endswith(")"):
        return None
    s = s[1:-1]
    fields, current = [], []
    quoted = False
    i = 0
    while i < len(s):
        ch = s[i]
        if quoted:
            current.append(ch)
            if ch == "'":
                if i + 1 < len(s) and s[i + 1] == "'":
                    current.append("'")
                    i += 1
                else:
                    quoted = False
        else:
            if ch == "'":
                quoted = True
                current.append(ch)
            elif ch == ",":
                fields.append("".join(current).strip())
                current = []
            else:
                current.append(ch)
        i += 1
    fields.append("".join(current).strip())
    return fields


def rows(filename):
    result = []
    for lineno, line in enumerate((DATA / filename).read_text(encoding="utf-8").splitlines(), 1):
        if line.lstrip().startswith("("):
            parsed = row_fields(line)
            if parsed is None:
                raise ValueError(f"Fila no interpretable: {filename}:{lineno}")
            result.append((lineno, parsed))
    return result


def unquote(value):
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1].replace("''", "'")
    return value


def main():
    parsed = {name: rows(name) for name in FILES}
    country = parsed["country.sql"]
    city = parsed["city.sql"]
    language = parsed["countrylanguage.sql"]

    country_codes = [unquote(r[1][0]) for r in country]
    city_ids = [int(r[1][0]) for r in city]
    city_country_codes = [unquote(r[1][2]) for r in city]
    language_country_codes = [unquote(r[1][0]) for r in language]
    language_keys = [(unquote(r[1][0]), unquote(r[1][1])) for r in language]

    print("=== AUDITORIA ===")
    print(f"country:          {len(country)}")
    print(f"city:             {len(city)}")
    print(f"countrylanguage:  {len(language)}")
    print()

    checks = []
    checks.append(("country code duplicado", len(country_codes) - len(set(country_codes))))
    checks.append(("city id duplicado", len(city_ids) - len(set(city_ids))))
    checks.append(("countrylanguage PK duplicada", len(language_keys) - len(set(language_keys))))
    checks.append(("city -> country inexistente", sum(x not in set(country_codes) for x in city_country_codes)))
    checks.append(("countrylanguage -> country inexistente", sum(x not in set(country_codes) for x in language_country_codes)))

    invalid_pct = 0
    for _, r in language:
        p = float(r[3])
        invalid_pct += not (0 <= p <= 100)
    checks.append(("percentage fuera de 0..100", invalid_pct))

    invalid_pop = sum(int(r[1][4]) < 0 for r in city)
    checks.append(("city.population negativo", invalid_pop))

    invalid_area = sum(float(r[1][4]) < 0 for r in country)
    checks.append(("country.surfacearea negativo", invalid_area))

    replacement_counts = {}
    for name in FILES:
        text = (DATA / name).read_text(encoding="utf-8")
        replacement_counts[name] = text.count("�")
    checks.append(("caracteres U+FFFD en datos", sum(replacement_counts.values())))

    for label, value in checks:
        print(f"{'OK' if value == 0 else 'ERROR':5} {label}: {value}")

    print("\nCaracteres U+FFFD por archivo:")
    for name, count in replacement_counts.items():
        print(f"  {name}: {count}")

    print("\nContinentes encontrados:")
    continents = sorted({unquote(r[1][2]) for r in country})
    for item in continents:
        print(f"  - {item}")

    if any(value for _, value in checks if "U+FFFD" not in _):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
