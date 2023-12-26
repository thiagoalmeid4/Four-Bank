PGDMP         /                {            FourBank    15.4    15.4 %    #           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            $           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            %           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            &           1262    109560    FourBank    DATABASE     �   CREATE DATABASE "FourBank" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE "FourBank";
                postgres    false            �            1255    117959 +   obter_dados_autenticacao(character varying)    FUNCTION     �  CREATE FUNCTION public.obter_dados_autenticacao(p_identificador character varying) RETURNS TABLE(cliente_id bigint, cpf character varying, senha character varying)
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
 R   DROP FUNCTION public.obter_dados_autenticacao(p_identificador character varying);
       public          postgres    false            �            1255    117956 �   salvar_cliente(character varying, character varying, character varying, character varying, character varying, character varying)    FUNCTION       CREATE FUNCTION public.salvar_cliente(p_ds_email character varying, p_ds_senha character varying, p_dt_nascimento character varying, p_nm_cliente character varying, p_nr_cpf character varying, p_nr_telefone character varying) RETURNS bigint
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
 �   DROP FUNCTION public.salvar_cliente(p_ds_email character varying, p_ds_senha character varying, p_dt_nascimento character varying, p_nm_cliente character varying, p_nr_cpf character varying, p_nr_telefone character varying);
       public          postgres    false            �            1255    117958 :   salvar_conta(bigint, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.salvar_conta(p_nr_id_cliente bigint, p_nr_conta character varying, p_nr_agencia character varying) RETURNS void
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
 y   DROP FUNCTION public.salvar_conta(p_nr_id_cliente bigint, p_nr_conta character varying, p_nr_agencia character varying);
       public          postgres    false            �            1259    117886 
   tb_cliente    TABLE     �  CREATE TABLE public.tb_cliente (
    nr_id_cliente bigint NOT NULL,
    ds_email character varying(255) NOT NULL,
    ds_senha character varying(255) NOT NULL,
    dt_cadastro character varying(255) NOT NULL,
    dt_nascimento character varying(255) NOT NULL,
    nm_cliente character varying(255) NOT NULL,
    nr_cpf character varying(255) NOT NULL,
    nr_telefone character varying(255) NOT NULL
);
    DROP TABLE public.tb_cliente;
       public         heap    postgres    false            �            1259    117885    tb_cliente_nr_id_cliente_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_cliente_nr_id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.tb_cliente_nr_id_cliente_seq;
       public          postgres    false    215            '           0    0    tb_cliente_nr_id_cliente_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.tb_cliente_nr_id_cliente_seq OWNED BY public.tb_cliente.nr_id_cliente;
          public          postgres    false    214            �            1259    117899    tb_conta    TABLE     �   CREATE TABLE public.tb_conta (
    vl_saldo_conta numeric(38,2),
    fk_nr_id_cliente bigint,
    nr_id_conta bigint NOT NULL,
    nr_agencia character varying(255) NOT NULL,
    nr_conta character varying(255) NOT NULL
);
    DROP TABLE public.tb_conta;
       public         heap    postgres    false            �            1259    117898    tb_conta_nr_id_conta_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_conta_nr_id_conta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.tb_conta_nr_id_conta_seq;
       public          postgres    false    217            (           0    0    tb_conta_nr_id_conta_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.tb_conta_nr_id_conta_seq OWNED BY public.tb_conta.nr_id_conta;
          public          postgres    false    216            �            1259    117914    tb_pix_chaves    TABLE     �   CREATE TABLE public.tb_pix_chaves (
    fk_nr_id_conta bigint NOT NULL,
    nr_id_chave bigint NOT NULL,
    ds_chave character varying(255) NOT NULL,
    tp_chave character varying(255) NOT NULL
);
 !   DROP TABLE public.tb_pix_chaves;
       public         heap    postgres    false            �            1259    117913    tb_pix_chaves_nr_id_chave_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_pix_chaves_nr_id_chave_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.tb_pix_chaves_nr_id_chave_seq;
       public          postgres    false    219            )           0    0    tb_pix_chaves_nr_id_chave_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.tb_pix_chaves_nr_id_chave_seq OWNED BY public.tb_pix_chaves.nr_id_chave;
          public          postgres    false    218            �            1259    117925    tb_transacoes    TABLE     �   CREATE TABLE public.tb_transacoes (
    tp_transacao integer,
    vl_transacao numeric(38,2),
    fk_nr_id_conta_destino bigint,
    fk_nr_id_conta_origem bigint,
    nr_id_transacao bigint NOT NULL,
    dt_transacao character varying(255)
);
 !   DROP TABLE public.tb_transacoes;
       public         heap    postgres    false            �            1259    117924 !   tb_transacoes_nr_id_transacao_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_transacoes_nr_id_transacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.tb_transacoes_nr_id_transacao_seq;
       public          postgres    false    221            *           0    0 !   tb_transacoes_nr_id_transacao_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.tb_transacoes_nr_id_transacao_seq OWNED BY public.tb_transacoes.nr_id_transacao;
          public          postgres    false    220            w           2604    117889    tb_cliente nr_id_cliente    DEFAULT     �   ALTER TABLE ONLY public.tb_cliente ALTER COLUMN nr_id_cliente SET DEFAULT nextval('public.tb_cliente_nr_id_cliente_seq'::regclass);
 G   ALTER TABLE public.tb_cliente ALTER COLUMN nr_id_cliente DROP DEFAULT;
       public          postgres    false    214    215    215            x           2604    117902    tb_conta nr_id_conta    DEFAULT     |   ALTER TABLE ONLY public.tb_conta ALTER COLUMN nr_id_conta SET DEFAULT nextval('public.tb_conta_nr_id_conta_seq'::regclass);
 C   ALTER TABLE public.tb_conta ALTER COLUMN nr_id_conta DROP DEFAULT;
       public          postgres    false    216    217    217            y           2604    117917    tb_pix_chaves nr_id_chave    DEFAULT     �   ALTER TABLE ONLY public.tb_pix_chaves ALTER COLUMN nr_id_chave SET DEFAULT nextval('public.tb_pix_chaves_nr_id_chave_seq'::regclass);
 H   ALTER TABLE public.tb_pix_chaves ALTER COLUMN nr_id_chave DROP DEFAULT;
       public          postgres    false    218    219    219            z           2604    117928    tb_transacoes nr_id_transacao    DEFAULT     �   ALTER TABLE ONLY public.tb_transacoes ALTER COLUMN nr_id_transacao SET DEFAULT nextval('public.tb_transacoes_nr_id_transacao_seq'::regclass);
 L   ALTER TABLE public.tb_transacoes ALTER COLUMN nr_id_transacao DROP DEFAULT;
       public          postgres    false    221    220    221            |           2606    117895 "   tb_cliente tb_cliente_ds_email_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT tb_cliente_ds_email_key UNIQUE (ds_email);
 L   ALTER TABLE ONLY public.tb_cliente DROP CONSTRAINT tb_cliente_ds_email_key;
       public            postgres    false    215            ~           2606    117897     tb_cliente tb_cliente_nr_cpf_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT tb_cliente_nr_cpf_key UNIQUE (nr_cpf);
 J   ALTER TABLE ONLY public.tb_cliente DROP CONSTRAINT tb_cliente_nr_cpf_key;
       public            postgres    false    215            �           2606    117893    tb_cliente tb_cliente_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_cliente
    ADD CONSTRAINT tb_cliente_pkey PRIMARY KEY (nr_id_cliente);
 D   ALTER TABLE ONLY public.tb_cliente DROP CONSTRAINT tb_cliente_pkey;
       public            postgres    false    215            �           2606    117908 &   tb_conta tb_conta_fk_nr_id_cliente_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT tb_conta_fk_nr_id_cliente_key UNIQUE (fk_nr_id_cliente);
 P   ALTER TABLE ONLY public.tb_conta DROP CONSTRAINT tb_conta_fk_nr_id_cliente_key;
       public            postgres    false    217            �           2606    117910     tb_conta tb_conta_nr_agencia_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT tb_conta_nr_agencia_key UNIQUE (nr_agencia);
 J   ALTER TABLE ONLY public.tb_conta DROP CONSTRAINT tb_conta_nr_agencia_key;
       public            postgres    false    217            �           2606    117912    tb_conta tb_conta_nr_conta_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT tb_conta_nr_conta_key UNIQUE (nr_conta);
 H   ALTER TABLE ONLY public.tb_conta DROP CONSTRAINT tb_conta_nr_conta_key;
       public            postgres    false    217            �           2606    117906    tb_conta tb_conta_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT tb_conta_pkey PRIMARY KEY (nr_id_conta);
 @   ALTER TABLE ONLY public.tb_conta DROP CONSTRAINT tb_conta_pkey;
       public            postgres    false    217            �           2606    117923 (   tb_pix_chaves tb_pix_chaves_ds_chave_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.tb_pix_chaves
    ADD CONSTRAINT tb_pix_chaves_ds_chave_key UNIQUE (ds_chave);
 R   ALTER TABLE ONLY public.tb_pix_chaves DROP CONSTRAINT tb_pix_chaves_ds_chave_key;
       public            postgres    false    219            �           2606    117921     tb_pix_chaves tb_pix_chaves_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.tb_pix_chaves
    ADD CONSTRAINT tb_pix_chaves_pkey PRIMARY KEY (nr_id_chave);
 J   ALTER TABLE ONLY public.tb_pix_chaves DROP CONSTRAINT tb_pix_chaves_pkey;
       public            postgres    false    219            �           2606    117930     tb_transacoes tb_transacoes_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.tb_transacoes
    ADD CONSTRAINT tb_transacoes_pkey PRIMARY KEY (nr_id_transacao);
 J   ALTER TABLE ONLY public.tb_transacoes DROP CONSTRAINT tb_transacoes_pkey;
       public            postgres    false    221            �           2606    117931 $   tb_conta fkisi7dx2ykpwm8ffcgmb3463c7    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_conta
    ADD CONSTRAINT fkisi7dx2ykpwm8ffcgmb3463c7 FOREIGN KEY (fk_nr_id_cliente) REFERENCES public.tb_cliente(nr_id_cliente);
 N   ALTER TABLE ONLY public.tb_conta DROP CONSTRAINT fkisi7dx2ykpwm8ffcgmb3463c7;
       public          postgres    false    3200    215    217            �           2606    117941 )   tb_transacoes fkjaaice5rifrn2243de81pa2no    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_transacoes
    ADD CONSTRAINT fkjaaice5rifrn2243de81pa2no FOREIGN KEY (fk_nr_id_conta_destino) REFERENCES public.tb_conta(nr_id_conta);
 S   ALTER TABLE ONLY public.tb_transacoes DROP CONSTRAINT fkjaaice5rifrn2243de81pa2no;
       public          postgres    false    221    217    3208            �           2606    117946 )   tb_transacoes fkjyppglec3337btj314mjdperw    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_transacoes
    ADD CONSTRAINT fkjyppglec3337btj314mjdperw FOREIGN KEY (fk_nr_id_conta_origem) REFERENCES public.tb_conta(nr_id_conta);
 S   ALTER TABLE ONLY public.tb_transacoes DROP CONSTRAINT fkjyppglec3337btj314mjdperw;
       public          postgres    false    3208    221    217            �           2606    117936 )   tb_pix_chaves fkop5lkkamm4essj4p3p44s9lw7    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_pix_chaves
    ADD CONSTRAINT fkop5lkkamm4essj4p3p44s9lw7 FOREIGN KEY (fk_nr_id_conta) REFERENCES public.tb_conta(nr_id_conta);
 S   ALTER TABLE ONLY public.tb_pix_chaves DROP CONSTRAINT fkop5lkkamm4essj4p3p44s9lw7;
       public          postgres    false    219    217    3208           