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
