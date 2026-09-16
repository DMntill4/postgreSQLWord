-- 04_verify.sql
-- Consultas de comprobación posteriores a la carga.

\echo '=== CANTIDAD DE REGISTROS ==='
SELECT 'country' AS tabla, COUNT(*) AS registros FROM public.country
UNION ALL
SELECT 'city', COUNT(*) FROM public.city
UNION ALL
SELECT 'countrylanguage', COUNT(*) FROM public.countrylanguage
UNION ALL
SELECT 'continent', COUNT(*) FROM public.continent;

\echo '=== CONTINENTES SIN REPETIR EN COUNTRY ==='
SELECT DISTINCT continent
FROM public.country
ORDER BY continent ASC;

\echo '=== CIUDADES SIN PAIS ==='
SELECT c.*
FROM public.city c
LEFT JOIN public.country co ON co.code = c.countrycode
WHERE co.code IS NULL;

\echo '=== IDIOMAS SIN PAIS ==='
SELECT cl.*
FROM public.countrylanguage cl
LEFT JOIN public.country co ON co.code = cl.countrycode
WHERE co.code IS NULL;

\echo '=== CAPITALES SIN CIUDAD ==='
SELECT co.code, co.name, co.capital
FROM public.country co
LEFT JOIN public.city ci ON ci.id = co.capital
WHERE co.capital IS NOT NULL
  AND ci.id IS NULL;

\echo '=== DUPLICADOS DE CONTINENTE ==='
SELECT name, COUNT(*)
FROM public.continent
GROUP BY name
HAVING COUNT(*) > 1;

\echo '=== VALORES INVALIDOS DE POBLACION EN CITY ==='
SELECT * FROM public.city WHERE population < 0;

\echo '=== VALORES INVALIDOS DE PORCENTAJE ==='
SELECT * FROM public.countrylanguage WHERE percentage < 0 OR percentage > 100;

\echo '=== CARACTERES DE REEMPLAZO ==='
-- Si esta consulta devuelve registros, el archivo de datos todavía contiene U+FFFD (�).
SELECT code, name, localname, headofstate
FROM public.country
WHERE name LIKE '%�%'
   OR localname LIKE '%�%'
   OR headofstate LIKE '%�%';

SELECT id, name, district
FROM public.city
WHERE name LIKE '%�%'
   OR district LIKE '%�%';

SELECT countrycode, language
FROM public.countrylanguage
WHERE language LIKE '%�%';
