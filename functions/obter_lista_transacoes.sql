-- FUNCTION: public.obter_lista_transacoes(bigint)

-- DROP FUNCTION IF EXISTS public.obter_lista_transacoes(bigint);

CREATE OR REPLACE FUNCTION public.obter_lista_transacoes(
	p_id_usuario bigint)
    RETURNS TABLE(origem_destino character varying, nome_cliente character varying, valor numeric, tipo_transacao integer, data_transferencia character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN t.fk_nr_id_conta_origem = c.nr_id_conta THEN 'ENTRADA'::varchar
            WHEN t.fk_nr_id_conta_destino = c.nr_id_conta THEN 'SAÍDA'::varchar
        END AS origem_destino,
        COALESCE((SELECT nm_cliente FROM tb_cliente WHERE nr_id_cliente = c1.fk_nr_id_cliente)::varchar, ''::varchar) AS nome_cliente,
        t.vl_transacao::numeric AS valor,
        t.tp_transacao::integer AS tipo_transacao,
        TO_CHAR(t.dt_transacao::timestamp, 'DD/MM/YYYY HH24:MI:SS')::varchar AS data_transferencia
    FROM
        tb_transacoes t
    LEFT JOIN
        tb_conta c ON t.fk_nr_id_conta_origem = c.nr_id_conta OR t.fk_nr_id_conta_destino = c.nr_id_conta
    LEFT JOIN
        tb_conta c1 ON t.fk_nr_id_conta_origem = c1.nr_id_conta
    WHERE
        c.fk_nr_id_cliente = p_id_usuario
    ORDER BY
        t.dt_transacao DESC;

    RETURN;
END;
$BODY$;

ALTER FUNCTION public.obter_lista_transacoes(bigint)
    OWNER TO postgres;
