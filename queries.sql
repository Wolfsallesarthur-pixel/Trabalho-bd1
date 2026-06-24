-- =====================================================================
-- SCRIPT DE CONSULTAS AO MODELO RELACIONAL (DQL)
-- EXIGÊNCIA: Mínimo 10 consultas válidas contendo restrições, joins e agrupamentos
-- SISTEMA: Rede de Hospitais Veterinários VetVida
-- =====================================================================

USE VetVidaDB;

-- ---------------------------------------------------------------------
-- CONSULTA 1: Relatório de Pacientes e Seus Respectivos Tutores (Join Básico)
-- Objetivo: Listar todos os animais cadastrados cruzando com os donos responsáveis.
-- ---------------------------------------------------------------------
SELECT 
    p.id AS 'Cód. Paciente',
    p.nome AS 'Nome do Pet',
    p.especie AS 'Espécie',
    t.nome AS 'Nome do Tutor',
    t.telefone AS 'Contato'
FROM paciente p
INNER JOIN tutor t ON p.tutor_id = t.id
ORDER BY p.nome ASC;


-- ---------------------------------------------------------------------
-- CONSULTA 2: Consultas Realizadas por Médico Específico (Filtro Dinâmico)
-- Objetivo: Rastrear a agenda e os diagnósticos dados pela 'Dra. Ana Silva'.
-- ---------------------------------------------------------------------
SELECT 
    c.id AS 'Nº Consulta',
    c.data_hora AS 'Data/Hora',
    p.nome AS 'Paciente',
    c.motivo AS 'Sintomas Relatados',
    c.diagnostico AS 'Laudo Clínico'
FROM consulta c
INNER JOIN veterinario v ON c.veterinario_id = v.id
INNER JOIN paciente p ON c.paciente_id = p.id
WHERE v.nome = 'Dra. Ana Silva'
ORDER BY c.data_hora DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 3: Consolidação Contábil Financeira de Receita por Unidade Hospitalar
-- Objetivo: Somar o faturamento líquido efetivamente PAGO agrupado por filial física.
-- ---------------------------------------------------------------------
SELECT 
    u.id AS 'Cód. Unidade',
    u.nome AS 'Hospital / Unidade',
    u.cidade AS 'Município',
    SUM(f.valor_total) AS 'Faturamento Total Efetivado (R$)'
FROM faturamento f
INNER JOIN consulta c ON f.consulta_id = c.id
INNER JOIN veterinario v ON c.veterinario_id = v.id
INNER JOIN unidade u ON v.unidade_id = u.id
WHERE f.status = 'Pago'
GROUP BY u.id, u.nome, u.cidade
ORDER BY 'Faturamento Total Efetivado (R$)' DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 4: Ranking de Serviços e Procedimentos Mais Consumidos
-- Objetivo: Identificar a demanda volumétrica do catálogo de serviços clínicos.
-- ---------------------------------------------------------------------
SELECT 
    s.id AS 'Cód. Serviço',
    s.nome AS 'Procedimento',
    SUM(cs.quantidade) AS 'Quantidade Total Consumida',
    ROUND(AVG(s.valor_unitario), 2) AS 'Preço Médio Praticado (R$)'
FROM servico s
INNER JOIN consulta_servico cs ON s.id = cs.servico_id
GROUP BY s.id, s.nome
ORDER BY SUM(cs.quantidade) DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 5: Filtro de Clientes Multi-pet (Uso do HAVING)
-- Objetivo: Localizar tutores altamente ativos que possuem mais de 1 animal no sistema.
-- ---------------------------------------------------------------------
SELECT 
    t.id AS 'Cód. Tutor',
    t.nome AS 'Nome do Cliente',
    COUNT(p.id) AS 'Quantidade de Animais Cadastrados'
FROM tutor t
INNER JOIN paciente p ON t.id = p.tutor_id
GROUP BY t.id, t.nome
HAVING COUNT(p.id) > 1
ORDER BY 'Quantidade de Animais Cadastrados' DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 6: Extrato Detalhado de Serviços por Atendimento Individual
-- Objetivo: Abrir os itens de linha que compõem o faturamento de uma consulta (Ex: Consulta ID 1).
-- ---------------------------------------------------------------------
SELECT 
    c.id AS 'Nº Atendimento',
    s.nome AS 'Item / Serviço Executado',
    s.valor_unitario AS 'Valor Unitário (R$)',
    cs.quantidade AS 'Qtd',
    (s.valor_unitario * cs.quantidade) AS 'Subtotal do Item (R$)'
FROM consulta_servico cs
INNER JOIN servico s ON cs.servico_id = s.id
INNER JOIN consulta c ON cs.consulta_id = c.id
WHERE cs.consulta_id = 1;


-- ---------------------------------------------------------------------
-- CONSULTA 7: Triagem de Pacientes por Faixa Cronológica Histórica
-- Objetivo: Listar todos os animais de estimação nascidos antes de '2021-01-01' para campanhas geriátricas.
-- ---------------------------------------------------------------------
SELECT 
    nome AS 'Nome do Pet',
    especie AS 'Espécie',
    data_nascimento AS 'Data de Nascimento',
    TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()) AS 'Idade Estimada'
FROM paciente
WHERE data_nascimento < '2021-01-01'
ORDER BY data_nascimento ASC;


-- ---------------------------------------------------------------------
-- CONSULTA 8: Relatório de Inadimplência e Controles Pendentes por Tutor
-- Objetivo: Rastrear faturamentos em aberto, nomes dos tutores e o valor devido.
-- ---------------------------------------------------------------------
SELECT 
    f.id AS 'Fatura ID',
    t.nome AS 'Tutor Devedor',
    t.telefone AS 'Contato para Cobrança',
    p.nome AS 'Paciente Relacionado',
    f.valor_total AS 'Montante Pendente (R$)',
    f.status AS 'Situação Financeira'
FROM faturamento f
INNER JOIN consulta c ON f.consulta_id = c.id
INNER JOIN paciente p ON c.paciente_id = p.id
INNER JOIN tutor t ON p.tutor_id = t.id
WHERE f.status = 'Pendente'
ORDER BY f.valor_total DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 9: Distribuição Espacial do Corpo Médico Veterinário da Rede
-- Objetivo: Listar os profissionais, suas especialidades e suas cidades físicas de atuação.
-- ---------------------------------------------------------------------
SELECT 
    v.nome AS 'Médico Veterinário',
    v.crmv AS 'Registro Profissional',
    v.especialidade AS 'Especialidade Clínica',
    u.nome AS 'Hospital de Alocação',
    u.cidade AS 'Cidade de Atuação'
FROM veterinario v
INNER JOIN unidade u ON v.unidade_id = u.id
ORDER BY u.cidade, v.nome;


-- ---------------------------------------------------------------------
-- CONSULTA 10: Análise Macro de Indicador Contábil (Ticket Médio Global)
-- Objetivo: Calcular o valor médio gasto pelos clientes em atendimentos na rede.
-- ---------------------------------------------------------------------
SELECT 
    COUNT(id) AS 'Total de Notas Geradas',
    ROUND(AVG(valor_total), 2) AS 'Ticket Médio por Atendimento (R$)',
    MAX(valor_total) AS 'Maior Faturamento Único Registro (R$)',
    MIN(valor_total) AS 'Menor Faturamento Único Registro (R$)'
FROM faturamento
WHERE status <> 'Cancelado';
