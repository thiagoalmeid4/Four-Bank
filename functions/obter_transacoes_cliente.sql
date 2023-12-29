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
