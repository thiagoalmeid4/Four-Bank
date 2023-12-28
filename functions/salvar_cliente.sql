-- FUNCTION: public.salvar_cliente(character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION IF EXISTS public.salvar_cliente(character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION public.salvar_cliente(
	p_ds_email character varying,
	p_ds_senha character varying,
	p_dt_nascimento character varying,
	p_nm_cliente character varying,
	p_nr_cpf character varying,
	p_nr_telefone character varying)
    RETURNS bigint
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
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
$BODY$;

ALTER FUNCTION public.salvar_cliente(character varying, character varying, character varying, character varying, character varying, character varying)
    OWNER TO postgres;
