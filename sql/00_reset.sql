-- 00_reset.sql
-- Ejecutar cuando se quiera reiniciar el ejercicio desde cero.
-- El orden respeta las dependencias de las tablas que se cargan.

DROP TABLE IF EXISTS public.city;
DROP TABLE IF EXISTS public.countrylanguage;
DROP TABLE IF EXISTS public.region;
DROP TABLE IF EXISTS public.country;
DROP TABLE IF EXISTS public.continent;
