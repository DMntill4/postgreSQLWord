-- 01_schema.sql
-- Esquema solicitado para el ejercicio World.

CREATE TABLE public.country (
    code bpchar(3) NOT NULL,
    name text NOT NULL,
    continent text NOT NULL CHECK (
        continent IN (
            'Asia',
            'South America',
            'North America',
            'Oceania',
            'Antarctica',
            'Africa',
            'Europe',
            'Central America'
        )
    ),
    region text NOT NULL,
    surfacearea float4 NOT NULL CHECK (surfacearea >= 0),
    indepyear int2,
    population int4 NOT NULL,
    lifeexpectancy float4,
    gnp numeric(10,2),
    gnpold numeric(10,2),
    localname text NOT NULL,
    governmentform text NOT NULL,
    headofstate text,
    capital int4,
    code2 bpchar(2) NOT NULL,
    CONSTRAINT country_pk PRIMARY KEY (code)
);

CREATE TABLE public.city (
    id int4 NOT NULL,
    name text NOT NULL,
    countrycode bpchar(3) NOT NULL,
    district text NOT NULL,
    population int4 NOT NULL CHECK (population >= 0),
    CONSTRAINT city_pk PRIMARY KEY (id)
);

CREATE TABLE public.countrylanguage (
    countrycode bpchar(3) NOT NULL,
    language text NOT NULL,
    isofficial bool NOT NULL,
    percentage float4 NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
    CONSTRAINT countrylanguage_pk PRIMARY KEY (countrycode, language)
);
