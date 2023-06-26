
MODELAGEM DOS SCRIPTS PARA CRIAÇÃO DAS TABELAS DIMENSÃO E FATO:

--TODAS AS TABELAS USAM A MESMA METODOLOGIA, PRIMEIRO CRIASSE O SELECT PARA TRAZER OS CAMPOS NECESSÁRIOS PARA CRIAÇÃO DA TABELA.
--APÓS EXECUTADO O SELECT E VERIFICADO OS RESULTADOS, INCLUE A PRIMEIRA LINHA CREATE TABLE AS 'NOME_TABELA'.
--A CRIAÇÃO SEMPRE DEVE SER FEITA EM 'DATA_WAREHOUSE', LOCAL ONDE ESTÁ O DW.	

TABELA DIM_ORGAO:	
	
CREATE TABLE data_warehouse.dim_orgao AS
SELECT
    e.codigo_orgao AS codigo_orgao,
    COALESCE(MIN(e.dsc_orgao), e.codigo_orgao) AS nome_orgao
FROM execucao_financeira_despesa e
GROUP BY e.codigo_orgao
ORDER BY e.codigo_orgao ASC

- e.codigo_orgao AS codigo_orgao: Esta parte da consulta seleciona o campo codigo_orgao da tabela execucao_financeira_despesa e o renomeia como codigo_orgao. 
O campo codigo_orgao é uma coluna que representa o código de identificação do órgão.

- COALESCE(MIN(e.dsc_orgao), e.codigo_orgao) AS nome_orgao: Nesta parte da consulta, usa-se a função COALESCE em conjunto com a função MIN. 
A função MIN é usada para obter o valor mínimo da coluna dsc_orgao da tabela execucao_financeira_despesa. 
A função COALESCE é usada para retornar o primeiro valor não nulo entre o valor mínimo da coluna dsc_orgao e o valor de e.codigo_orgao. 
O resultado dessa operação é renomeado como nome_orgao, que representa o nome do órgão de execução financeira de despesas.

- FROM execucao_financeira_despesa e: Esta parte da consulta especifica a tabela execucao_financeira_despesa 
e a renomeia como e, que é um alias para facilitar a referência aos campos da tabela.

- GROUP BY e.codigo_orgao: Aqui, a cláusula GROUP BY é usada para agrupar os resultados com base no campo codigo_orgao. 
Isso significa que os resultados serão agrupados por órgão de execução financeira.

- ORDER BY e.codigo_orgao ASC: A cláusula ORDER BY é usada para ordenar os resultados em 
ordem ascendente com base no campo codigo_orgao. Isso significa que os resultados serão exibidos em ordem crescente de código de órgão.	
	

TABELA DIM_CREDOR:
	
CREATE TABLE data_warehouse.dim_credor AS
SELECT
    e.cod_credor AS codigo_credor,
    MIN(e.dsc_nome_credor) AS nome_credor
FROM execucao_financeira_despesa e
GROUP BY e.cod_credor
ORDER BY e.cod_credor ASC

- e.cod_credor AS codigo_credor: Esta parte da consulta seleciona o campo cod_credor da tabela execucao_financeira_despesa
 e o renomeia como codigo_credor. O campo cod_credor é uma coluna que representa o código de identificação do credor.

- MIN(e.dsc_nome_credor) AS nome_credor: Nesta parte da consulta, usa-se a função MIN para obter o valor mínimo da 
coluna dsc_nome_credor da tabela execucao_financeira_despesa. 
Essa função é aplicada para encontrar o nome do credor que vem primeiro em ordem alfabética. 
O resultado dessa operação é renomeado como nome_credor, que representa o nome do credor de execução financeira de despesas.

- FROM execucao_financeira_despesa e: Esta parte da consulta especifica a tabela execucao_financeira_despesa 
e a renomeia como e, que é um alias para facilitar a referência aos campos da tabela.

- GROUP BY e.cod_credor: Aqui, a cláusula GROUP BY é usada para agrupar os resultados com base 
no campo cod_credor. Isso significa que os resultados serão agrupados por código de credor.

- ORDER BY e.cod_credor ASC: A cláusula ORDER BY é usada para ordenar os resultados em ordem 
ascendente com base no campo cod_credor. Isso significa que os resultados serão exibidos em ordem crescente de código de credor.	


TABELA DIM_FONTE:
	
CREATE TABLE data_warehouse.dim_fonte AS
SELECT
    e.cod_fonte AS codigo_fonte,
    MIN(e.dsc_fonte) AS nome_fonte
FROM execucao_financeira_despesa e
WHERE e.cod_item IS NOT NULL
GROUP BY e.cod_fonte
ORDER BY e.cod_fonte ASC

 - e.cod_fonte AS codigo_fonte: Esta parte da consulta seleciona o campo cod_fonte da tabela execucao_financeira_despesa 
e o renomeia como codigo_fonte. O campo cod_fonte é uma coluna que representa o código de identificação da fonte.

- MIN(e.dsc_fonte) AS nome_fonte: Nesta parte da consulta, usa-se a função MIN para obter o valor mínimo da coluna dsc_fonte 
da tabela execucao_financeira_despesa. Essa função é aplicada para encontrar o nome da fonte que vem primeiro em ordem alfabética. 
O resultado dessa operação é renomeado como nome_fonte, que representa o nome da fonte de execução financeira de despesas.

- FROM execucao_financeira_despesa e: Esta parte da consulta especifica a tabela execucao_financeira_despesa 
e a renomeia como e, que é um alias para facilitar a referência aos campos da tabela.

- WHERE e.cod_item IS NOT NULL: A cláusula WHERE é usada para filtrar os registros da tabela 
execucao_financeira_despesa, selecionando apenas aqueles em que o campo cod_item não seja nulo. 
Isso significa que somente serão considerados os registros que possuam um código de item.

- GROUP BY e.cod_fonte: Aqui, a cláusula GROUP BY é usada para agrupar os resultados com base no campo cod_fonte. 
Isso significa que os resultados serão agrupados por código de fonte.

- ORDER BY e.cod_fonte ASC: A cláusula ORDER BY é usada para ordenar os resultados em ordem ascendente com base no campo cod_fonte. 
Isso significa que os resultados serão exibidos em ordem crescente de código de fonte.
	

TABELA FATO_VALOR:
	
CREATE TABLE data_warehouse.fato_valor AS 
SELECT 
	CONCAT(num_ano, cod_ne, codigo_orgao) AS codigo_empenho,
	codigo_orgao,
	cod_credor AS codigo_credor,
	cod_fonte AS codigo_fonte,
	cod_funcao AS codigo_funcao,
	cod_subfuncao AS codigo_subfuncao,
	cod_item AS codigo_item,
	cod_item_elemento AS codigo_item_elemento,
	cod_item_categoria,
	cod_item_grupo,
	cod_item_modalidade,
	cod_programa, 
	num_sic,
	cod_np,
	COALESCE(vlr_empenho, 0.00) AS valor_empenho,
	COALESCE(vlr_liquidado, 0.00) AS valor_liquidado,
	COALESCE(valor_pago, 0.00) AS valor_pago,
		CASE
			WHEN vlr_resto_pagar IS NULL THEN '0.00'
			WHEN vlr_resto_pagar = 0.00 THEN (vlr_empenho - valor_pago) 
			END AS valor_a_pagar,
	dth_empenho AS data_empenho,
	dth_pagamento AS data_pagamento,
	dth_liquidacao AS data_liquidacao,
	dth_processamento AS data_processamento,
	num_ano_np
FROM execucao_financeira_despesa
ORDER BY codigo_empenho ASC

- CONCAT(num_ano, cod_ne, codigo_orgao) AS codigo_empenho: Esta parte da consulta utiliza a função CONCAT para concatenar 
os valores dos campos num_ano, cod_ne e codigo_orgao. O resultado é renomeado como codigo_empenho e representa o código do empenho, 
formado pela combinação desses três campos.

- codigo_orgao: Este campo representa o código do órgão.

- cod_credor AS codigo_credor: Este campo representa o código do credor.

- cod_fonte AS codigo_fonte: Este campo representa o código da fonte.

- cod_funcao AS codigo_funcao: Este campo representa o código da função.

- cod_subfuncao AS codigo_subfuncao: Este campo representa o código da subfunção.

- cod_item AS codigo_item: Este campo representa o código do item.

- cod_item_elemento AS codigo_item_elemento: Este campo representa o código do elemento do item.

- cod_item_categoria: Este campo representa a categoria do item.

- cod_item_grupo: Este campo representa o grupo do item.

- cod_item_modalidade: Este campo representa a modalidade do item.

- cod_programa: Este campo representa o código do programa.

- num_sic: Este campo representa o número do SIC.

- cod_np: Este campo representa o código número do pagamento.

- COALESCE(vlr_empenho, 0.00) AS valor_empenho: Nesta parte da consulta, utiliza-se a função COALESCE para retornar o valor do campo vlr_empenho, 
mas se for nulo, será retornado o valor padrão de 0.00. O resultado é renomeado como valor_empenho e representa o valor do empenho.

- COALESCE(vlr_liquidado, 0.00) AS valor_liquidado: Nesta parte da consulta, utiliza-se a função COALESCE para retornar o valor do campo vlr_liquidado, 
mas se for nulo, será retornado o valor padrão de 0.00. O resultado é renomeado como valor_liquidado e representa o valor liquidado.

- COALESCE(valor_pago, 0.00) AS valor_pago: Nesta parte da consulta, utiliza-se a função COALESCE para retornar o valor do campo valor_pago, 
mas se for nulo, será retornado o valor padrão de 0.00. O resultado é renomeado como valor_pago e representa o valor pago.

- CASE WHEN vlr_resto_pagar IS NULL THEN '0.00' WHEN vlr_resto_pagar = 0.00 THEN (vlr_empenho - valor_pago) END AS valor_a_pagar: 
Esta parte da consulta utiliza a cláusula CASE para verificar duas condições. Se o campo vlr_resto_pagar for nulo, será retornado '0.00'. 
Se o campo vlr_resto_pagar for igual a 0.00, será calculada a diferença entre vlr_empenho e valor_pago, representando o valor a pagar. 
O resultado é renomeado como valor_a_pagar.

- dth_empenho AS data_empenho: Este campo representa a data do empenho.

- dth_pagamento AS data_pagamento: Este campo representa a data do pagamento.

- dth_liquidacao AS data_liquidacao: Este campo representa a data da liquidação.

- dth_processamento AS data_processamento: Este campo representa a data do processamento.

- num_ano_np: Este campo representa o ano do número do pagamento.

- FROM execucao_financeira_despesa: Esta parte da consulta especifica a tabela execucao_financeira_despesa de onde os dados serão selecionados.

- ORDER BY codigo_empenho ASC: A cláusula ORDER BY é usada para ordenar os resultados em ordem ascendente com base no campo codigo_empenho. 
Isso significa que os resultados serão exibidos em ordem crescente de código de empenho.	

	
VW PARA CRIAÇÃO DO DASHBOARD: 

	
CREATE VIEW data_warehouse.analise_teste1 AS 
SELECT
    v.codigo_empenho,
	v.codigo_orgao,
	o.nome_orgao,
	v.codigo_credor,
	cc.nome_credor,
	v.codigo_fonte,
	cf.nome_fonte,
    v.valor_empenho AS total_empenho,
    COALESCE(SUM(v.valor_pago), 0.00) AS total_pago,
    COALESCE(SUM(v.valor_pago), 0.00) AS valor_liquidado,
    CASE
        WHEN COALESCE(SUM(v.valor_pago), 0.00) = valor_empenho THEN 0.00
        ELSE v.valor_empenho - COALESCE(SUM(v.valor_pago), 0.00)
    END AS valor_a_pagar,
	t.data AS data_empenho,
    date_part('year', t.data) AS Ano,
	date_part('quarter', t.data) AS Trimestre,
    date_part('month', t.data) AS Mes,
    mes_nome_pt(t.data) AS Mes_Nome,
		CASE 
			WHEN COALESCE(SUM(v.valor_pago), 0.00) = v.valor_empenho THEN MAX(v.data_pagamento)
        ELSE NULL
    END AS data_liquidacao
FROM
    data_warehouse.fato_valor v
INNER JOIN data_warehouse.dim_orgao o ON o.codigo_orgao = v.codigo_orgao
INNER JOIN data_warehouse.dim_credor cc ON cc.codigo_credor = v.codigo_credor
INNER JOIN data_warehouse.dim_fonte cf ON cf.codigo_fonte = v.codigo_fonte
INNER JOIN data_warehouse.dim_tempo t ON t.data = v.data_empenho
GROUP BY
    v.codigo_empenho, v.codigo_orgao, o.nome_orgao,
	v.codigo_credor, cc.nome_credor, v.codigo_fonte, cf.nome_fonte, v.valor_empenho, t.data

- v.codigo_empenho: Este campo representa o código do empenho.

- v.codigo_orgao: Este campo representa o código do órgão.

- o.nome_orgao: Este campo representa o nome do órgão.

- v.codigo_credor: Este campo representa o código do credor.

- cc.nome_credor: Este campo representa o nome do credor.

- v.codigo_fonte: Este campo representa o código da fonte.

- cf.nome_fonte: Este campo representa o nome da fonte.

- v.valor_empenho AS total_empenho: Este campo representa o valor total do empenho.

- COALESCE(SUM(v.valor_pago), 0.00) AS total_pago: Nesta parte da consulta, utiliza-se a função SUM para calcular a soma do campo valor_pago, 
agrupado por empenho. A função COALESCE é usada para tratar os valores nulos, retornando 0.00 como valor padrão. 
O resultado é renomeado como total_pago e representa o valor total pago.

- COALESCE(SUM(v.valor_pago), 0.00) AS valor_liquidado: Nesta parte da consulta, utiliza-se novamente a função SUM para calcular a soma do campo valor_pago,
agrupado por empenho. A função COALESCE é usada para tratar os valores nulos, retornando 0.00 como valor padrão. 
O resultado é renomeado como valor_liquidado e representa o valor total liquidado.

- CASE WHEN COALESCE(SUM(v.valor_pago), 0.00) = valor_empenho THEN 0.00 ELSE v.valor_empenho - COALESCE(SUM(v.valor_pago), 0.00) END AS valor_a_pagar: 
Esta parte da consulta utiliza a cláusula CASE para verificar se o valor total pago é igual ao valor do empenho. 
Se for igual, é retornado 0.00 como valor a pagar. Caso contrário, é calculada a diferença entre o valor do empenho e o valor total pago. 
O resultado é renomeado como valor_a_pagar e representa o valor a pagar.

- t.data AS data_empenho: Este campo representa a data do empenho.

- date_part('year', t.data) AS Ano: Este campo utiliza a função date_part para extrair o ano da data do empenho.

- date_part('quarter', t.data) AS Trimestre: Este campo utiliza a função date_part para extrair o trimestre da data do empenho.

- date_part('month', t.data) AS Mes: Este campo utiliza a função date_part para extrair o mês da data do empenho.

- mes_nome_pt(t.data) AS Mes_Nome: Este campo utiliza uma função chamada mes_nome_pt para obter o nome do mês em português com base na data do empenho.

- CASE WHEN COALESCE(SUM(v.valor_pago), 0.00) = v.valor_empenho THEN MAX(v.data_pagamento) ELSE NULL END AS data_liquidacao: 
Esta parte da consulta utiliza a cláusula CASE para verificar se o valor total pago é igual ao valor do empenho. 
Se for igual, é retornado a data máxima de pagamento. Caso contrário, é retornado NULL. O resultado é renomeado como data_liquidacao e representa a data de liquidação.

- FROM data_warehouse.fato_valor v: Esta parte da consulta especifica a tabela fato_valor do data warehouse de onde os dados serão selecionados.

- INNER JOIN data_warehouse.dim_orgao o ON o.codigo_orgao = v.codigo_orgao: Essa cláusula realiza um INNER JOIN entre a tabela dim_orgao e a tabela fato_valor 
com base nos campos codigo_orgao, relacionando as informações do órgão.

- INNER JOIN data_warehouse.dim_credor cc ON cc.codigo_credor = v.codigo_credor: Essa cláusula realiza um INNER JOIN entre a tabela dim_credor e a tabela fato_valor 
com base nos campos codigo_credor, relacionando as informações do credor.

- INNER JOIN data_warehouse.dim_fonte cf ON cf.codigo_fonte = v.codigo_fonte: Essa cláusula realiza um INNER JOIN entre a tabela dim_fonte e a tabela fato_valor 
com base nos campos codigo_fonte, relacionando as informações da fonte.

- INNER JOIN data_warehouse.dim_tempo t ON t.data = v.data_empenho: Essa cláusula realiza um INNER JOIN entre a tabela dim_tempo e a tabela fato_valor 
com base no campo data_empenho, relacionando as informações do tempo.

- GROUP BY v.codigo_empenho, v.codigo_orgao, o.nome_orgao, v.codigo_credor, cc.nome_credor, v.codigo_fonte, cf.nome_fonte, v.valor_empenho, t.data: 
Essa cláusula agrupa os resultados pelo código do empenho, código do órgão, nome do órgão, código do credor, nome do credor, código da fonte, nome da fonte, 
valor do empenho e data do empenho.	
	


--dim_funcao

SELECT
    e.cod_funcao AS codigo_funcao,
    MIN(e.dsc_funcao) AS nome_funcao
FROM execucao_financeira_despesa e
GROUP BY e.cod_funcao
ORDER BY e.cod_funcao ASC

--dim_subfuncao

SELECT
    e.cod_subfuncao AS codigo_subfuncao,
    MIN(e.dsc_subfuncao) AS nome_subfuncao
FROM execucao_financeira_despesa e
GROUP BY e.cod_subfuncao
ORDER BY e.cod_subfuncao ASC

--dim_item

SELECT
    e.cod_item AS codigo_item,
    MIN(e.dsc_item) AS nome_item
FROM execucao_financeira_despesa e
WHERE e.cod_item IS NOT NULL --incluído para remover uma linha null
GROUP BY e.cod_item
ORDER BY e.cod_item ASC

--dim_item_elemento

SELECT
    e.cod_item_elemento AS codigo_item_elemento,
    MIN(e.dsc_item_elemento) AS nome_item_elemento
FROM execucao_financeira_despesa e
WHERE e.cod_item_elemento IS NOT NULL
GROUP BY e.cod_item_elemento 
ORDER BY e.cod_item_elemento  ASC

--dim_item_categoria

SELECT
    e.cod_item_categoria AS codigo_item_categoria,
    MIN(e.dsc_item_categoria) AS nome_item_categoria
FROM execucao_financeira_despesa e
GROUP BY e.cod_item_categoria 
ORDER BY e.cod_item_categoria  ASC

--dim_item_grupo

SELECT
    e.cod_item_grupo AS codigo_item_grupo,
    MIN(e.dsc_item_grupo) AS nome_item_grupo
FROM execucao_financeira_despesa e 
WHERE e.cod_item_grupo IS NOT NULL
GROUP BY e.cod_item_grupo 
ORDER BY e.cod_item_grupo  ASC

--dim_item_modalidade

SELECT
    e.cod_item_modalidade AS codigo_item_modalidade,
    MIN(e.dsc_item_modalidade) AS nome_item_modalidade,
	MIN(e.dsc_modalidade_licitacao) AS nome_item_modalidade
FROM execucao_financeira_despesa e 
GROUP BY e.cod_item_modalidade 
ORDER BY e.cod_item_modalidade  ASC

--dim_programa

SELECT
    e.cod_programa AS codigo_programa,
    MIN(e.dsc_programa) AS nome_programa
FROM execucao_financeira_despesa e 
GROUP BY e.cod_programa 
ORDER BY e.cod_programa  ASC

















