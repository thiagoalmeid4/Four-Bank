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
