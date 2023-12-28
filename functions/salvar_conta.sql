-- FUNCTION: public.salvar_conta(bigint, character varying, character varying)

-- DROP FUNCTION IF EXISTS public.salvar_conta(bigint, character varying, character varying);

CREATE OR REPLACE FUNCTION public.salvar_conta(
	p_nr_id_cliente bigint,
	p_nr_conta character varying,
	p_nr_agencia character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Inserir uma nova conta com saldo inicial de 100
    INSERT INTO tb_conta (
        fk_nr_id_cliente, nr_conta, nr_agencia, vl_saldo_conta
    )
    VALUES (
        p_nr_id_cliente, p_nr_conta, p_nr_agencia, 100.0
    );
END;
$BODY$;

ALTER FUNCTION public.salvar_conta(bigint, character varying, character varying)
    OWNER TO postgres;
