-- FUNCTION: public.obter_saldo_conta(bigint)

-- DROP FUNCTION IF EXISTS public.obter_saldo_conta(bigint);

CREATE OR REPLACE FUNCTION public.obter_saldo_conta(
    p_id_usuario bigint)
RETURNS TABLE(saldo_conta numeric, nr_conta character varying, nr_agencia character varying, nome_cliente character varying) 
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
ROWS 1000

AS $BODY$
DECLARE
    v_saldo_conta numeric(38,2);
BEGIN
    -- Obter saldo da conta
    SELECT c.vl_saldo_conta, c.nr_conta, c.nr_agencia, cl.nm_cliente
    INTO v_saldo_conta, nr_conta, nr_agencia, nome_cliente
    FROM tb_conta c
    JOIN tb_cliente cl ON c.fk_nr_id_cliente = cl.nr_id_cliente
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

    RETURN QUERY SELECT v_saldo_conta, nr_conta, nr_agencia, nome_cliente;

END;
$BODY$;


ALTER FUNCTION public.obter_saldo_conta(bigint)
    OWNER TO postgres;
