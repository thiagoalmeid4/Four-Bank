--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

-- Started on 2023-12-26 11:42:33

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

-- FUNCTION: public.obter_saldo_conta(bigint)

-- DROP FUNCTION IF EXISTS public.obter_saldo_conta(bigint);

CREATE OR REPLACE FUNCTION public.obter_saldo_conta(
	p_id_usuario bigint)
    RETURNS TABLE(saldo_conta numeric, nr_conta character varying, nr_agencia character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    v_saldo_conta numeric(38,2);
BEGIN
    -- Obter saldo da conta
    SELECT c.vl_saldo_conta, c.nr_conta, c.nr_agencia
    INTO v_saldo_conta, nr_conta, nr_agencia
    FROM tb_conta c
    WHERE c.fk_nr_id_cliente = p_id_usuario;

    -- Verificar transações do tipo 1 dentro de um minuto
    IF EXISTS (
        SELECT 1
        FROM tb_transacoes t
        WHERE t.fk_nr_id_conta_destino = (SELECT nr_id_conta FROM tb_conta WHERE fk_nr_id_cliente = p_id_usuario)
            AND t.tp_transacao = 1
            AND t.dt_transacao::timestamp >= (CURRENT_TIMESTAMP - interval '1 minute')::timestamp
    ) THEN
        -- Subtrair valor das transações de tipo 1 dentro de um minuto se for uma entrada
        SELECT v_saldo_conta - COALESCE(SUM(t.vl_transacao), 0)
        INTO v_saldo_conta
        FROM tb_transacoes t
        WHERE t.fk_nr_id_conta_destino = (SELECT nr_id_conta FROM tb_conta WHERE fk_nr_id_cliente = p_id_usuario)
            AND t.tp_transacao = 1
            AND t.dt_transacao::timestamp >= (CURRENT_TIMESTAMP - interval '1 minute')::timestamp;
    END IF;

    RETURN QUERY SELECT v_saldo_conta, nr_conta, nr_agencia;

END;
$BODY$;

ALTER FUNCTION public.obter_saldo_conta(bigint)
    OWNER TO postgres;

-- FUNCTION: public.obter_lista_transacoes(bigint)

-- DROP FUNCTION IF EXISTS public.obter_lista_transacoes(bigint);

-- FUNCTION: public.obter_transacoes_cliente(bigint)

-- DROP FUNCTION IF EXISTS public.obter_transacoes_cliente(bigint);

CREATE OR REPLACE FUNCTION public.obter_transacoes_cliente(
    p_id_cliente bigint)
RETURNS TABLE(
    entrada_saida character varying,
    origem_destino character varying,
    valor numeric,
    tipo character varying,
    data_transferencia text)
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
ROWS 1000
AS $BODY$
BEGIN
    RETURN QUERY
    WITH todas_transacoes AS (
        SELECT
            CASE
                WHEN t.fk_nr_id_conta_destino = c.nr_id_conta THEN 'Entrada'::character varying
                WHEN t.fk_nr_id_conta_origem = c.nr_id_conta THEN 'Saída'::character varying
            END AS entrada_saida,
            CASE
                WHEN t.fk_nr_id_conta_destino = c.nr_id_conta THEN
                    (SELECT nm_cliente FROM tb_cliente WHERE nr_id_cliente = t.fk_nr_id_conta_origem)::character varying
                WHEN t.fk_nr_id_conta_origem = c.nr_id_conta THEN
                    (SELECT nm_cliente FROM tb_cliente WHERE nr_id_cliente = t.fk_nr_id_conta_destino)::character varying
            END AS origem_destino,
            t.vl_transacao AS valor,
            CASE
                WHEN t.tp_transacao = 0 THEN 'PIX'::character varying
                WHEN t.tp_transacao = 1 THEN 'TED'::character varying
            END AS tipo,
            TO_CHAR(t.dt_transacao::timestamp, 'YYYY-MM-DD HH24:MI:SS') AS data_transferencia
        FROM
            tb_transacoes t
        LEFT JOIN
            tb_conta c ON t.fk_nr_id_conta_origem = c.nr_id_conta OR t.fk_nr_id_conta_destino = c.nr_id_conta
        WHERE
            c.fk_nr_id_cliente = p_id_cliente
    )

    SELECT *
    FROM todas_transacoes
    WHERE NOT (
        todas_transacoes.tipo = 'TED'
        AND todas_transacoes.entrada_saida = 'Entrada'
        AND CURRENT_TIMESTAMP - todas_transacoes.data_transferencia::timestamp <= interval '1 minute'
    )
    ORDER BY todas_transacoes.data_transferencia DESC;

END;
$BODY$;


ALTER FUNCTION public.obter_transacoes_cliente(bigint)
    OWNER TO postgres;


-- FUNCTION: public.realizar_transferencia(bigint, bigint, numeric, integer)

-- DROP FUNCTION IF EXISTS public.realizar_transferencia(bigint, bigint, numeric, integer);

-- FUNCTION: public.realizar_transferencia(bigint, bigint, numeric, integer)

-- DROP FUNCTION IF EXISTS public.realizar_transferencia(bigint, bigint, numeric, integer);
CREATE OR REPLACE FUNCTION public.realizar_transferencia(
    p_id_conta_origem bigint,
    p_id_conta_destino bigint,
    p_valor_transferencia numeric,
    p_tipo_transacao integer)
RETURNS TABLE(
    nome_cliente_origem character varying,
    nome_cliente_destino character varying,
    dt_transacao timestamp,
    tipo_transacao integer,
    valor_transferencia numeric,
    id_transacao bigint)
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
ROWS 1000

AS $BODY$
BEGIN
    -- Obter nomes dos clientes de origem e destino
    SELECT
        c1.nm_cliente,
        (SELECT c2.nm_cliente
         FROM tb_conta cd
         JOIN tb_cliente c2 ON cd.fk_nr_id_cliente = c2.nr_id_cliente
         WHERE cd.nr_id_conta = p_id_conta_destino) AS nm_cliente_destino
    INTO
        nome_cliente_origem,
        nome_cliente_destino
    FROM
        tb_conta co
    JOIN
        tb_cliente c1 ON co.fk_nr_id_cliente = c1.nr_id_cliente
    WHERE
        co.nr_id_conta = p_id_conta_origem;

    -- Debitar o valor da conta de origem
    UPDATE tb_conta
    SET vl_saldo_conta = vl_saldo_conta - p_valor_transferencia
    WHERE nr_id_conta = p_id_conta_origem;

    -- Somar o valor na conta de destino
    UPDATE tb_conta
    SET vl_saldo_conta = vl_saldo_conta + p_valor_transferencia
    WHERE nr_id_conta = p_id_conta_destino;

    -- Inserir a transação na tabela tb_transacoes
    INSERT INTO tb_transacoes(tp_transacao, vl_transacao, fk_nr_id_conta_origem, fk_nr_id_conta_destino, dt_transacao)
    VALUES (p_tipo_transacao, p_valor_transferencia, p_id_conta_origem, p_id_conta_destino, CURRENT_TIMESTAMP)
    RETURNING nr_id_transacao, CURRENT_TIMESTAMP, p_tipo_transacao, p_valor_transferencia INTO id_transacao, dt_transacao, tipo_transacao, valor_transferencia;

    -- Retornar os resultados
    RETURN QUERY SELECT nome_cliente_origem, nome_cliente_destino, dt_transacao, tipo_transacao, valor_transferencia, id_transacao;

END;
$BODY$;


ALTER FUNCTION public.realizar_transferencia(bigint, bigint, numeric, integer)
    OWNER TO postgres;
-- FUNCTION: public.registrar_chave_pix(bigint, integer)

-- DROP FUNCTION IF EXISTS public.registrar_chave_pix(bigint, integer);

CREATE OR REPLACE FUNCTION public.registrar_chave_pix(
	p_cliente_id bigint,
	p_tipo_chave integer)
    RETURNS TABLE(chave_id bigint, nr_id_conta_result bigint, ds_chave_result character varying, tp_chave_result character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    v_chave_id_result BIGINT;
    v_nr_id_conta_result BIGINT;
BEGIN
    -- Verificar o tipo de chave e registrar conforme necessário
    CASE p_tipo_chave
        WHEN 0 THEN
            -- Registrar chave CPF
            INSERT INTO tb_pix_chaves (fk_nr_id_conta, ds_chave, tp_chave)
            VALUES ((SELECT nr_id_conta FROM tb_conta WHERE fk_nr_id_cliente = p_cliente_id), (SELECT nr_cpf FROM tb_cliente WHERE nr_id_cliente = p_cliente_id), 'CPF')
            RETURNING nr_id_chave, fk_nr_id_conta INTO v_chave_id_result, v_nr_id_conta_result;
        WHEN 1 THEN
            -- Registrar chave e-mail
            INSERT INTO tb_pix_chaves (fk_nr_id_conta, ds_chave, tp_chave)
            VALUES ((SELECT nr_id_conta FROM tb_conta WHERE fk_nr_id_cliente = p_cliente_id), (SELECT ds_email FROM tb_cliente WHERE nr_id_cliente = p_cliente_id), 'E-mail')
            RETURNING nr_id_chave, fk_nr_id_conta INTO v_chave_id_result, v_nr_id_conta_result;
        WHEN 2 THEN
            -- Registrar chave telefone
            INSERT INTO tb_pix_chaves (fk_nr_id_conta, ds_chave, tp_chave)
            VALUES ((SELECT nr_id_conta FROM tb_conta WHERE fk_nr_id_cliente = p_cliente_id), (SELECT nr_telefone FROM tb_cliente WHERE nr_id_cliente = p_cliente_id), 'Telefone')
            RETURNING nr_id_chave, fk_nr_id_conta INTO v_chave_id_result, v_nr_id_conta_result;
        WHEN 3 THEN
            -- Gerar chave aleatória
            INSERT INTO tb_pix_chaves (fk_nr_id_conta, ds_chave, tp_chave)
            VALUES ((SELECT nr_id_conta FROM tb_conta WHERE fk_nr_id_cliente = p_cliente_id), md5(random()::text), 'Aleatória')
            RETURNING nr_id_chave, fk_nr_id_conta INTO v_chave_id_result, v_nr_id_conta_result;
        ELSE
            -- Tipo de chave inválido
            RAISE EXCEPTION 'Tipo de chave inválido: %', p_tipo_chave;
    END CASE;

    -- Retornar os detalhes da chave PIX registrada
    RETURN QUERY
    SELECT v_chave_id_result, v_nr_id_conta_result, ds_chave, tp_chave
    FROM tb_pix_chaves
    WHERE nr_id_chave = v_chave_id_result;
END;
$BODY$;

ALTER FUNCTION public.registrar_chave_pix(bigint, integer)
    OWNER TO postgres;

--
-- TOC entry 224 (class 1255 OID 117959)
-- Name: obter_dados_autenticacao(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.obter_dados_autenticacao(p_identificador character varying) RETURNS TABLE(cliente_id bigint, cpf character varying, senha character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        nr_id_cliente,
        nr_cpf,
        ds_senha
    FROM
        tb_cliente
    WHERE
        p_identificador IN (nr_cpf, ds_email, nr_telefone);
END;
$$;


ALTER FUNCTION public.obter_dados_autenticacao(p_identificador character varying) OWNER TO postgres;

--
-- TOC entry 222 (class 1255 OID 117956)
-- Name: salvar_cliente(character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.salvar_cliente(p_ds_email character varying, p_ds_senha character varying, p_dt_nascimento character varying, p_nm_cliente character varying, p_nr_cpf character varying, p_nr_telefone character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cliente_id BIGINT;
BEGIN
    -- Inserir um novo cliente e retornar o ID inserido
    INSERT INTO tb_cliente (
        ds_email, ds_senha, dt_cadastro,
        dt_nascimento, nm_cliente, nr_cpf,
        nr_telefone
    )
    VALUES (
        p_ds_email, p_ds_senha, current_timestamp,
        p_dt_nascimento, p_nm_cliente, p_nr_cpf,
        p_nr_telefone
    )
    RETURNING nr_id_cliente INTO v_cliente_id;

    -- Retornar o ID do cliente inserido
    RETURN v_cliente_id;
END;
$$;


ALTER FUNCTION public.salvar_cliente(p_ds_email character varying, p_ds_senha character varying, p_dt_nascimento character varying, p_nm_cliente character varying, p_nr_cpf character varying, p_nr_telefone character varying) OWNER TO postgres;

--
-- TOC entry 223 (class 1255 OID 117958)
-- Name: salvar_conta(bigint, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.salvar_conta(p_nr_id_cliente bigint, p_nr_conta character varying, p_nr_agencia character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Inserir uma nova conta com saldo inicial de 100
    INSERT INTO tb_conta (
        fk_nr_id_cliente, nr_conta, nr_agencia, vl_saldo_conta
    )
    VALUES (
        p_nr_id_cliente, p_nr_conta, p_nr_agencia, 100.0
    );
END;
$$;


ALTER FUNCTION public.salvar_conta(p_nr_id_cliente bigint, p_nr_conta character varying, p_nr_agencia character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 117886)
-- Name: tb_cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_cliente (
    nr_id_cliente bigint NOT NULL,
    ds_email character varying(255) NOT NULL,
    ds_senha character varying(255) NOT NULL,
    dt_cadastro character varying(255) NOT NULL,
    dt_nascimento character varying(255) NOT NULL,
    nm_cliente character varying(255) NOT NULL,
    nr_cpf character varying(255) NOT NULL,
    nr_telefone character varying(255) NOT NULL
);


ALTER TABLE public.tb_cliente OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 117885)
-- Name: tb_cliente_nr_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_cliente_nr_id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_cliente_nr_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 214
-- Name: tb_cliente_nr_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_cliente_nr_id_cliente_seq OWNED BY public.tb_cliente.nr_id_cliente;


--
-- TOC entry 217 (class 1259 OID 117899)
-- Name: tb_conta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_conta (
    vl_saldo_conta numeric(38,2),
    fk_nr_id_cliente bigint,
    nr_id_conta bigint NOT NULL,
    nr_agencia character varying(255) NOT NULL,
    nr_conta character varying(255) NOT NULL
);


ALTER TABLE public.tb_conta OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 117898)
-- Name: tb_conta_nr_id_conta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_conta_nr_id_conta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_conta_nr_id_conta_seq OWNER TO postgres;

--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 216
-- Name: tb_conta_nr_id_conta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_conta_nr_id_conta_seq OWNED BY public.tb_conta.nr_id_conta;


--
-- TOC entry 219 (class 1259 OID 117914)
-- Name: tb_pix_chaves; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_pix_chaves (
    fk_nr_id_conta bigint NOT NULL,
    nr_id_chave bigint NOT NULL,
    ds_chave character varying(255) NOT NULL,
    tp_chave character varying(255) NOT NULL
);


ALTER TABLE public.tb_pix_chaves OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 117913)
-- Name: tb_pix_chaves_nr_id_chave_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_pix_chaves_nr_id_chave_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_pix_chaves_nr_id_chave_seq OWNER TO postgres;

--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 218
-- Name: tb_pix_chaves_nr_id_chave_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_pix_chaves_nr_id_chave_seq OWNED BY public.tb_pix_chaves.nr_id_chave;


--
-- TOC entry 221 (class 1259 OID 117925)
-- Name: tb_transacoes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_transacoes (
    tp_transacao integer,
    vl_transacao numeric(38,2),
    fk_nr_id_conta_destino bigint,
    fk_nr_id_conta_origem bigint,
    nr_id_transacao bigint NOT NULL,
    dt_transacao character varying(255)
);


ALTER TABLE public.tb_transacoes OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 117924)
-- Name: tb_transacoes_nr_id_transacao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_transacoes_nr_id_transacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_transacoes_nr_id_transacao_seq OWNER TO postgres;

--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 220
-- Name: tb_transacoes_nr_id_transacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_transacoes_nr_id_transacao_seq OWNED BY public.tb_transacoes.nr_id_transacao;


--
-- TOC entry 3191 (class 2604 OID 117889)
-- Name: tb_cliente nr_id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_cliente ALTER COLUMN nr_id_cliente SET DEFAULT nextval('public.tb_cliente_nr_id_cliente_seq'::regclass);


--
-- TOC entry 3192 (class 2604 OID 117902)
-- Name: tb_conta nr_id_conta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_conta ALTER COLUMN nr_id_conta SET DEFAULT nextval('public.tb_conta_nr_id_conta_seq'::regclass);


--
-- TOC entry 3193 (class 2604 OID 117917)
-- Name: tb_pix_chaves nr_id_chave; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_pix_chaves ALTER COLUMN nr_id_chave SET DEFAULT nextval('public.tb_pix_chaves_nr_id_chave_seq'::regclass);


--
-- TOC entry 3194 (class 2604 OID 117928)
-- Name: tb_transacoes nr_id_transacao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_transacoes ALTER COLUMN nr_id_transacao SET DEFAULT nextval('public.tb_transacoes_nr_id_transacao_seq'::regclass);


--
-- TOC entry 3196 (class 2606 OID 117895)
-- Name: tb_cliente tb_cliente_ds_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT tb_cliente_ds_email_key UNIQUE (ds_email);


--
-- TOC entry 3198 (class 2606 OID 117897)
-- Name: tb_cliente tb_cliente_nr_cpf_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT tb_cliente_nr_cpf_key UNIQUE (nr_cpf);


--
-- TOC entry 3200 (class 2606 OID 117893)
-- Name: tb_cliente tb_cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT tb_cliente_pkey PRIMARY KEY (nr_id_cliente);


--
-- TOC entry 3202 (class 2606 OID 117908)
-- Name: tb_conta tb_conta_fk_nr_id_cliente_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT tb_conta_fk_nr_id_cliente_key UNIQUE (fk_nr_id_cliente);


--
-- TOC entry 3204 (class 2606 OID 117910)
-- Name: tb_conta tb_conta_nr_agencia_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT tb_conta_nr_agencia_key UNIQUE (nr_agencia);


--
-- TOC entry 3206 (class 2606 OID 117912)
-- Name: tb_conta tb_conta_nr_conta_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT tb_conta_nr_conta_key UNIQUE (nr_conta);


--
-- TOC entry 3208 (class 2606 OID 117906)
-- Name: tb_conta tb_conta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT tb_conta_pkey PRIMARY KEY (nr_id_conta);


--
-- TOC entry 3210 (class 2606 OID 117923)
-- Name: tb_pix_chaves tb_pix_chaves_ds_chave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_pix_chaves
    ADD CONSTRAINT tb_pix_chaves_ds_chave_key UNIQUE (ds_chave);


--
-- TOC entry 3212 (class 2606 OID 117921)
-- Name: tb_pix_chaves tb_pix_chaves_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_pix_chaves
    ADD CONSTRAINT tb_pix_chaves_pkey PRIMARY KEY (nr_id_chave);


--
-- TOC entry 3214 (class 2606 OID 117930)
-- Name: tb_transacoes tb_transacoes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_transacoes
    ADD CONSTRAINT tb_transacoes_pkey PRIMARY KEY (nr_id_transacao);


--
-- TOC entry 3215 (class 2606 OID 117931)
-- Name: tb_conta fkisi7dx2ykpwm8ffcgmb3463c7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT fkisi7dx2ykpwm8ffcgmb3463c7 FOREIGN KEY (fk_nr_id_cliente) REFERENCES public.tb_cliente(nr_id_cliente);


--
-- TOC entry 3217 (class 2606 OID 117941)
-- Name: tb_transacoes fkjaaice5rifrn2243de81pa2no; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_transacoes
    ADD CONSTRAINT fkjaaice5rifrn2243de81pa2no FOREIGN KEY (fk_nr_id_conta_destino) REFERENCES public.tb_conta(nr_id_conta);


--
-- TOC entry 3218 (class 2606 OID 117946)
-- Name: tb_transacoes fkjyppglec3337btj314mjdperw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_transacoes
    ADD CONSTRAINT fkjyppglec3337btj314mjdperw FOREIGN KEY (fk_nr_id_conta_origem) REFERENCES public.tb_conta(nr_id_conta);


--
-- TOC entry 3216 (class 2606 OID 117936)
-- Name: tb_pix_chaves fkop5lkkamm4essj4p3p44s9lw7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_pix_chaves
    ADD CONSTRAINT fkop5lkkamm4essj4p3p44s9lw7 FOREIGN KEY (fk_nr_id_conta) REFERENCES public.tb_conta(nr_id_conta);


-- Completed on 2023-12-26 11:42:34

--
-- PostgreSQL database dump complete
--

