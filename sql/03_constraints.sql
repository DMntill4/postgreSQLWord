-- 03_constraints.sql
-- Las llaves foráneas se agregan después de cargar los datos.
-- Esto permite cargar los archivos INSERT primero y validar después.

ALTER TABLE public.city
    ADD CONSTRAINT city_country_fk
    FOREIGN KEY (countrycode)
    REFERENCES public.country(code);

ALTER TABLE public.countrylanguage
    ADD CONSTRAINT countrylanguage_country_fk
    FOREIGN KEY (countrycode)
    REFERENCES public.country(code);

ALTER TABLE public.country
    ADD CONSTRAINT country_capital_fk
    FOREIGN KEY (capital)
    REFERENCES public.city(id);
