-- 02_continent.sql
-- Tabla solicitada por el caso de uso.

CREATE TABLE public.continent (
    code serial4 NOT NULL,
    name text NULL,
    CONSTRAINT continent_pk PRIMARY KEY (code)
);

-- Los continentes se obtienen de country sin repetir registros.
INSERT INTO public.continent (name)
SELECT DISTINCT continent
FROM public.country
ORDER BY continent ASC;
