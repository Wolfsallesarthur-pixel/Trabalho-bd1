-- =====================================================================
-- SCRIPT DE INSERÇÃO DE DADOS, ATUALIZAÇÕES E DELETES COM TRANSAÇÕES (DML)
-- SISTEMA: Rede de Hospitais Veterinários VetVida
-- =====================================================================

USE VetVidaDB;

-- ---------------------------------------------------------------------
-- PARTE 1: INSERÇÕES POPULANDO AS TABELAS DO MODELO
-- ---------------------------------------------------------------------

-- Carga inicial de Unidades
INSERT INTO unidade (nome, cidade) VALUES 
('VetVida Unidade Central', 'São Paulo'),
('VetVida Zona Sul', 'Curitiba'),
('VetVida Unidade Litoral', 'Santos');

-- Carga inicial de Médicos Veterinários
INSERT INTO veterinario (nome, crmv, especialidade, unidade_id) VALUES 
('Dra. Ana Silva', 'CRMV-SP 12345', 'Clínica Geral', 1),
('Dr. Carlos Souza', 'CRMV-SP 54321', 'Ortopedia', 1),
('Dra. Beatriz Lima', 'CRMV-PR 98765', 'Felinos', 2),
('Dr. Ricardo Alves', 'CRMV-SP 77766', 'Cardiologia', 3);

-- Carga inicial de Tutores (Clientes)
INSERT INTO tutor (nome, cpf, telefone) VALUES 
('João Pedro Rodrigues', '111.222.333-44', '(11) 98888-7777'),
('Maria Oliveira Santos', '555.666.777-88', '(11) 99999-0000'),
('Roberto Costa Ferreira', '999.888.777-66', '(41) 97777-5555'),
('Patrícia Souza Lima', '444.555.666-22', '(13) 96666-4444');

-- Carga inicial de Pacientes (Pets vinculados aos Tutores)
INSERT INTO paciente (nome, especie, data_nascimento, tutor_id) VALUES 
('Rex', 'Cachorro', '2019-05-10', 1),
('Mia', 'Gato', '2021-02-15', 2),
('Thor', 'Cachorro', '2018-11-20', 2),
('Piu', 'Ave', '2022-08-05', 3),
('Luna', 'Gato', '2020-01-30', 4);

-- Carga inicial do Catálogo de Serviços
INSERT INTO servico (nome, valor_unitario) VALUES 
('Consulta Médica Geral', 150.00),
('Vacina V10 Importada', 85.00),
('Raio-X Digital Completo', 220.00),
('Hemograma Veterinário Completo', 110.00),
('Ultrassonografia Abdominal', 250.00);

-- Carga inicial de Consultas / Atendimentos
INSERT INTO consulta (data_hora, motivo, diagnostico, paciente_id, veterinario_id) VALUES 
('2026-05-10 10:00:00', 'Checkup e vacinação anual', 'Animal em ótimo estado clínico, vacinas atualizadas.', 1, 1),
('2026-05-12 14:30:00', 'Claudicação na pata traseira direita', 'Suspeita de luxação patelar. Solicitado Raio-X.', 3, 2),
('2026-05-15 09:00:00', 'Inapetência e apatia extrema', 'Desidratação leve. Coletado sangue para análise.', 2, 3),
('2026-05-16 11:15:00', 'Avaliação cardiológica periódica', 'Sopro cardíaco controlado. Manter medicação.', 5, 4);

-- Vínculo de Serviços Executados nas Consultas (Relacionamento N:M)
INSERT INTO consulta_servico (consulta_id, servico_id, quantidade) VALUES 
(1, 1, 1), -- Consulta Geral para o Rex (ID 1)
(1, 2, 2), -- Aplicação de 2 Vacinas V10 no Rex
(2, 1, 1), -- Consulta Geral para o Thor (ID 3)
(2, 3, 1), -- Execução de 1 Raio-X no Thor
(3, 1, 1), -- Consulta Geral para a Mia (ID 2)
(3, 4, 1), -- Execução de 1 Hemograma na Mia
(4, 1, 1); -- Consulta Geral para a Luna (ID 5)

-- Lançamento do Faturamento das Consultas (Valores Consolidados)
INSERT INTO faturamento (valor_total, status, consulta_id) VALUES 
(320.00, 'Pago', 1),     -- Cálculo: (150 * 1) + (85 * 2) = 320.00
(370.00, 'Pendente', 2), -- Cálculo: (150 * 1) + (220 * 1) = 370.00
(260.00, 'Pago', 3),     -- Cálculo: (150 * 1) + (110 * 1) = 260.00
(150.00, 'Pendente', 4); -- Cálculo: (150 * 1) = 150.00


-- ---------------------------------------------------------------------
-- PARTE 2: EXEMPLIFICAÇÃO DE TRANSACIONALIDADE (UPDATE E DELETE)
-- ---------------------------------------------------------------------

-- Cenário de Update Seguro com Controle de Transação:
-- A rede VetVida decidiu aplicar um reajuste inflacionário de 10% em todos os exames
-- do catálogo e, simultaneamente, colocar em conformidade faturamentos antigos pendentes.
START TRANSACTION;

    -- Atualiza os valores unitários de serviços específicos no catálogo
    UPDATE servico 
    SET valor_unitario = valor_unitario * 1.10 
    WHERE nome LIKE '%Completo%';

    -- Atualiza um faturamento pendente específico que recebeu negociação de desconto
    UPDATE faturamento 
    SET valor_total = 350.00, status = 'Pago' 
    WHERE id = 2 AND status = 'Pendente';

-- Se as atualizações ocorreram em conformidade, consolida a transação no disco
COMMIT;


-- Cenário de Delete Seguro com Controle de Transação:
-- Um tutor solicitou o cancelamento total e exclusão imediata do atendimento da Consulta ID 4,
-- por erro de agendamento na Unidade Litoral. É necessário deletar em bloco de forma atômica.
START TRANSACTION;

    -- Remove as referências financeiras primeiro (Tabela dependente)
    DELETE FROM faturamento 
    WHERE consulta_id = 4;
    
    -- Remove as amarras de relacionamento de serviços associados
    DELETE FROM consulta_servico 
    WHERE consulta_id = 4;
    
    -- Por fim, remove o registro principal da consulta de forma limpa
    DELETE FROM consulta 
    WHERE id = 4;

-- Validação de segurança: se houver problemas, executa-se ROLLBACK. Caso contrário:
COMMIT;
