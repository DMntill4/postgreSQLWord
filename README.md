# PostgreSQL + Docker — Volcado de Datos y Modelado Relacional

**Autor:** Diego Mantilla

Este proyecto contiene la creación de estructura, carga limpia de datos (`country`, `city` y `countrylanguage`), la creación e inserción dinámica de `continent`, llaves foráneas/restricciones, validaciones de integridad y procedimientos para la generación y restauración de volcados lógicos en PostgreSQL.

---

## 1. Estructura del Proyecto

```text
postgres-world/
├── README.md
├── world_backup.sql
├── data/
│   ├── city.sql
│   ├── country.sql
│   └── countrylanguage.sql
├── img/
│   ├── alter.png
│   ├── continents.png
│   ├── insertCity.png
│   ├── insertCountries.png
│   ├── insertCountryLanguage.png
│   ├── relationsCountry.png
│   ├── resetAndSchema.png
│   ├── verifyAll.png
│   └── verifySelects.png
├── original/
│   ├── city.sql
│   ├── country.sql
│   └── countrylanguage.sql
└── sql/
    ├── 00_reset.sql
    ├── 01_schema.sql
    ├── 02_continent.sql
    ├── 03_constraints.sql
    └── 04_verify.sql
```

---

## 2. Descripción de Carpetas y Archivos

- **`sql/`**: Instrucciones SQL estructuradas por etapas (reset, esquema, continentes, restricciones y verificaciones).
- **`data/`**: Los archivos de datos limpios y listos para importar en PostgreSQL (`country`, `city`, `countrylanguage`).
- **`original/`**: Copia de respaldo de los archivos entregados originalmente antes del proceso de corrección.
- **`img/`**: Capturas de pantalla que sirven como evidencia visual de la ejecución de los comandos y consultas.
- **`world_backup.sql`**: Volcado lógico completo preparado a partir del estado final verificado del proyecto.

---

## 3. Antes de Empezar: Terminal vs. PostgreSQL

Existen dos entornos donde se ejecutan los comandos:

### 1. Terminal de Windows / Linux / PowerShell
Aquí ejecutas comandos de sistema y Docker, como por ejemplo:
```bash
docker exec -it postgres_db bash
```

### 2. Consola interactiva de PostgreSQL (`psql`)
Aparece una vez conectado a la base de datos:
```text
postgres=#
```
Aquí ejecutas sentencias SQL (como `SELECT * FROM country;`) y metapandos propios de `psql` que inician con `\i` o `\dt`.

---

## 4. Entrar al Contenedor PostgreSQL

Desde la **terminal de tu sistema operativo**:

```bash
docker exec -it postgres_db bash
```
*(Asegúrate de que `postgres_db` sea el nombre exacto de tu contenedor de Docker).*

---

## 5. Entrar a PostgreSQL

Una vez dentro del contenedor:

```bash
psql -U postgres
```

O especificando la base de datos si utilizas una diferente de la por defecto:
```bash
psql -U postgres -d world
```

Para listar las tablas existentes:
```sql
\dt
```

---

## 6. Copiar Archivos al Contenedor

Para que PostgreSQL pueda ejecutar los scripts mediante `\i`, copia la carpeta del proyecto dentro del contenedor desde la **terminal normal**:

```bash
docker cp . postgres_db:/tmp/postgres-world
```

---

## 7. Reiniciar el Ejercicio (`00_reset.sql`)

Si deseas limpiar la base de datos y comenzar desde cero, ejecuta dentro de `psql`:

```sql
\i /tmp/postgres-world/sql/00_reset.sql
```

El orden de eliminación respeta la integridad referencial:
1. `city`
2. `countrylanguage`
3. `country`
4. `continent`

---

## 8. Crear las Tablas Principales (`01_schema.sql`)

Dentro de `psql`:

```sql
\i /tmp/postgres-world/sql/01_schema.sql
```

Crea las tablas básicas: `country`, `city` y `countrylanguage` sin claves foráneas activas para facilitar la carga limpia inicial.

![Creación de Esquema y Reset](img/resetAndSchema.png)

---

## 9. Cargar los Datos (`data/`)

El orden estricto de carga es:

1. **Países (`country`)**:
```sql
\i /tmp/postgres-world/data/country.sql
```
![Inserción de Países](img/insertCountries.png)

2. **Ciudades (`city`)**:
```sql
\i /tmp/postgres-world/data/city.sql
```
![Inserción de Ciudades](img/insertCity.png)

3. **Idiomas por país (`countrylanguage`)**:
```sql
\i /tmp/postgres-world/data/countrylanguage.sql
```
![Inserción de Idiomas](img/insertCountryLanguage.png)

---

## 10. Comprobar Carga Inicial de Datos

Verifica la cantidad total de registros en la base de datos:

```sql
SELECT COUNT(*) FROM country;
SELECT COUNT(*) FROM city;
SELECT COUNT(*) FROM countrylanguage;
```

![Comprobación de Selects](img/verifySelects.png)

---

## 11. Crear e Insertar Continentes (`02_continent.sql`)

Crea la tabla normalizada de continentes e inserta dinámicamente los valores únicos encontrados en la tabla `country`:

```sql
\i /tmp/postgres-world/sql/02_continent.sql
```

![Creación e Inserción de Continentes](img/continents.png)

---

## 12. Agregar Restricciones y Llaves Foráneas (`03_constraints.sql`)

Con los datos ya cargados y validados, se activan las claves primarias y foráneas (`FOREIGN KEY`):

```sql
\i /tmp/postgres-world/sql/03_constraints.sql
```

Se configuran las relaciones entre:
- `city.countrycode` ➔ `country.code`
- `countrylanguage.countrycode` ➔ `country.code`
- `country.capital` ➔ `city.id`

![Alter Table Constraints](img/alter.png)

![Relaciones de Tablas](img/relationsCountry.png)

---

## 13. Verificación e Integridad Total (`04_verify.sql`)

Ejecuta el script SQL de verificación:

```sql
\i /tmp/postgres-world/sql/04_verify.sql
```

Comprueba que no existan huérfanos, capitales inválidas, continentes duplicados o datos fuera de rango.

![Verificación de Integridad Total](img/verifyAll.png)

---

## 14. Auditoría Automática con Python (`tools/check_data.py`)

Desde la **terminal normal**:

```bash
python tools/check_data.py
```

### Resultado de la Auditoría:

```text
=== AUDITORIA ===
country:          239
city:             4078
countrylanguage:  983

OK    country code duplicado: 0
OK    city id duplicado: 0
OK    countrylanguage PK duplicada: 0
OK    city -> country inexistente: 0
OK    countrylanguage -> country inexistente: 0
OK    percentage fuera de 0..100: 0
OK    city.population negativo: 0
OK    country.surfacearea negativo: 0
OK    caracteres U+FFFD en datos: 0

Caracteres U+FFFD por archivo:
  country.sql: 0
  city.sql: 0
  countrylanguage.sql: 0
```

---

## 15. Generar Volcado Lógico de Datos (`world_backup.sql`)

Para extraer una copia completa de respaldo en un solo archivo `.sql`, ejecuta en la **terminal normal**:

```bash
docker exec -t postgres_db pg_dump -U postgres postgres > world_backup.sql
```

---

## 16. Restaurar el Volcado (`world_backup.sql`)

Para restaurar en una base de datos limpia desde la **terminal normal**:

```bash
docker exec -i postgres_db psql -U postgres -d postgres < world_backup.sql
```

---

## 17. Flujo Completo Resumido

```bash
# 1. Entrar al contenedor
docker exec -it postgres_db bash

# 2. Entrar a PostgreSQL
psql -U postgres

# 3. Ejecutar secuencia completa
\i /tmp/postgres-world/sql/00_reset.sql
\i /tmp/postgres-world/sql/01_schema.sql
\i /tmp/postgres-world/data/country.sql
\i /tmp/postgres-world/data/city.sql
\i /tmp/postgres-world/data/countrylanguage.sql
\i /tmp/postgres-world/sql/02_continent.sql
\i /tmp/postgres-world/sql/03_constraints.sql
\i /tmp/postgres-world/sql/04_verify.sql
```
