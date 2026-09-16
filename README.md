# PostgreSQL + Docker — Volcado de Datos y Modelado Relacional

**Autor:** Diego Mantilla

Este proyecto contiene la carga limpia de datos (`country`, `city` y `countrylanguage`), creación e inserción de `continent`, llaves foráneas/restricciones, validaciones de integridad y procedimientos para generar y restaurar volcados lógicos en PostgreSQL.

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

- **`sql/`**: Scripts SQL organizados secuencialmente.
- **`data/`**: Datos limpios y listos para importar.
- **`original/`**: Copia de respaldo de archivos recibidos originalmente.
- **`img/`**: Evidencias en capturas de pantalla.
- **`world_backup.sql`**: Volcado lógico completo listo para restauración.

---

## 2. Preparación Inicial

### 1. Copiar archivos al contenedor Docker
Desde la terminal de tu sistema operativo:
```bash
docker cp . postgres_db:/tmp/postgres-world
```

### 2. Conectarse a PostgreSQL
```bash
docker exec -it postgres_db bash
psql -U postgres
```

---

## 3. Guía Paso a Paso (Ejecución SQL)

Ejecuta los siguientes comandos dentro de la consola de `psql` en orden secuencial:

### Paso 1: Limpieza y Creación del Esquema
Reinicia la base de datos e inicializa las tablas principales:
```sql
\i /tmp/postgres-world/sql/00_reset.sql
\i /tmp/postgres-world/sql/01_schema.sql
```
![Esquema y Reset](img/resetAndSchema.png)

---

### Paso 2: Carga de Datos
Carga la información de países, ciudades e idiomas:
```sql
\i /tmp/postgres-world/data/country.sql
\i /tmp/postgres-world/data/city.sql
\i /tmp/postgres-world/data/countrylanguage.sql
```

| Países (`country`) | Ciudades (`city`) | Idiomas (`countrylanguage`) |
|---|---|---|
| ![Países](img/insertCountries.png) | ![Ciudades](img/insertCity.png) | ![Idiomas](img/insertCountryLanguage.png) |

**Verificar conteo de registros:**
```sql
SELECT COUNT(*) FROM country;
SELECT COUNT(*) FROM city;
SELECT COUNT(*) FROM countrylanguage;
```
![Comprobación Selects](img/verifySelects.png)

---

### Paso 3: Normalización de Continentes
Crea la tabla `continent` e inserta los continentes únicos extraídos de `country`:
```sql
\i /tmp/postgres-world/sql/02_continent.sql
```
![Continentes](img/continents.png)

---

### Paso 4: Llaves Foráneas y Restricciones
Establece las relaciones entre tablas e integridad referencial (`FOREIGN KEY`):
```sql
\i /tmp/postgres-world/sql/03_constraints.sql
```

| Aplicación de Constraints | Modelo de Relaciones |
|---|---|
| ![ALTER Constraints](img/alter.png) | ![Relaciones](img/relationsCountry.png) |

---

### Paso 5: Verificación de Integridad
Comprueba que no existan huérfanos, capitales inválidas o datos inconsistentes:
```sql
\i /tmp/postgres-world/sql/04_verify.sql
```
![Verificación Total](img/verifyAll.png)

---

## 4. Volcado y Restauración

### Exportar Volcado (`pg_dump`)
Desde la terminal del sistema:
```bash
docker bash -c "docker exec -t postgres_db pg_dump -U postgres postgres > world_backup.sql"
```

### Restaurar Volcado (`psql`)
Desde la terminal del sistema:
```bash
docker exec -i postgres_db psql -U postgres -d postgres < world_backup.sql
```
