-- FUNCTION: public.obter_dados_autenticacao(character varying)

-- DROP FUNCTION IF EXISTS public.obter_dados_autenticacao(character varying);

CREATE OR REPLACE FUNCTION public.obter_dados_autenticacao(
	p_identificador character varying)
    RETURNS TABLE(cliente_id bigint, cpf character varying, senha character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
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
$BODY$;

ALTER FUNCTION public.obter_dados_autenticacao(character varying)
    OWNER TO postgres;
