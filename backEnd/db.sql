SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE TABLE public.configuration (
    key character varying(50) NOT NULL,
    value character varying(255) NOT NULL
);

ALTER TABLE public.configuration OWNER TO username;

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT configuration_pkey PRIMARY KEY (key);

CREATE TABLE public.joueurs (
    id integer NOT NULL,
    nom character varying(255) NOT NULL,
    mu double precision DEFAULT 25.0,
    sigma double precision DEFAULT 8.333,
    score_trueskill double precision GENERATED ALWAYS AS ((mu - ((3)::double precision * sigma))) STORED,
    tier character(1) DEFAULT 'U'::bpchar,
    CONSTRAINT joueurs_tier_check CHECK ((tier = ANY (ARRAY['S'::bpchar, 'A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'U'::bpchar])))
);

ALTER TABLE public.joueurs OWNER TO username;

CREATE SEQUENCE public.joueurs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.joueurs_id_seq OWNER TO username;
ALTER SEQUENCE public.joueurs_id_seq OWNED BY public.joueurs.id;

CREATE TABLE public.participations (
    joueur_id integer NOT NULL,
    tournoi_id integer NOT NULL,
    score integer NOT NULL,
    mu double precision,
    sigma double precision,
    new_score_trueskill double precision,
    new_tier character(1),
    position integer,
    old_mu double precision,
    old_sigma double precision
);

ALTER TABLE public.participations OWNER TO username;

CREATE TABLE public.tournois (
    id integer NOT NULL,
    date date NOT NULL
);

ALTER TABLE public.tournois OWNER TO username;

CREATE SEQUENCE public.tournois_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE public.tournois_id_seq OWNER TO username;
ALTER SEQUENCE public.tournois_id_seq OWNED BY public.tournois.id;

ALTER TABLE ONLY public.joueurs ALTER COLUMN id SET DEFAULT nextval('public.joueurs_id_seq'::regclass);
ALTER TABLE ONLY public.tournois ALTER COLUMN id SET DEFAULT nextval('public.tournois_id_seq'::regclass);

COPY public.configuration (key, value) FROM stdin;
tau	0.083
\.

COPY public.joueurs (id, nom, mu, sigma, tier) FROM stdin;
1	Rosalyan	67.897	3.002	S
2	J_sk8	56.241	0.922	S
3	Elite	57.361	0.968	S
4	Rayou	54.330	1.531	A
5	Vakaeltraz	55.534	0.858	S
6	Melwin	52.161	0.963	A
7	Lu_K	53.521	1.223	A
8	Clem	50.655	0.986	A
9	Daytona_69	48.588	1.482	B
10	JeanCube	50.280	1.956	A
11	Oleas	56.247	4.235	U
12	Thaumas	51.464	2.719	B
13	Ether-Zero	52.986	4.335	U
14	Tomwilson	49.867	4.522	U
15	Brook1l	42.095	2.266	B
16	Hardox	40.936	2.108	C
17	ColorOni	47.302	4.294	U
18	Kemoory	40.009	2.128	C
19	Camou	42.971	3.181	C
20	Fozlo	38.571	1.949	C
21	Kaysuan	43.312	5.890	U
22	PastPlayer	42.099	5.725	U
23	Tomy	35.993	4.691	U
\.

COPY public.participations (joueur_id, tournoi_id, score) FROM stdin;
\.

COPY public.tournois (id, date) FROM stdin;
\.

SELECT pg_catalog.setval('public.joueurs_id_seq', 26, true);
SELECT pg_catalog.setval('public.tournois_id_seq', 5, true);

ALTER TABLE ONLY public.joueurs ADD CONSTRAINT joueurs_nom_key UNIQUE (nom);
ALTER TABLE ONLY public.joueurs ADD CONSTRAINT joueurs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.participations ADD CONSTRAINT participations_pkey PRIMARY KEY (joueur_id, tournoi_id);
ALTER TABLE ONLY public.tournois ADD CONSTRAINT tournois_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.participations ADD CONSTRAINT participations_joueur_id_fkey FOREIGN KEY (joueur_id) REFERENCES public.joueurs(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.participations ADD CONSTRAINT participations_tournoi_id_fkey FOREIGN KEY (tournoi_id) REFERENCES public.tournois(id) ON DELETE CASCADE;
