-- =====================================================================
-- SCRIPT DE CRIAÇÃO DO BANCO DE DADOS E TABELAS (DDL)
-- SISTEMA: Rede de Hospitais Veterinários VetVida
-- BANCO DE DADOS: MySQL
-- =====================================================================

CREATE DATABASE IF NOT EXISTS VetVidaDB;
USE VetVidaDB;

-- Remover tabelas se existirem para permitir reexecução limpa (respeitando ordem de restrição)
DROP TABLE IF EXISTS faturamento;
DROP TABLE IF EXISTS consulta_servico;
DROP TABLE IF EXISTS consulta;
DROP TABLE IF EXISTS servico;
DROP TABLE IF EXISTS veterinario;
DROP TABLE IF EXISTS unidade;
DROP TABLE IF EXISTS paciente;
DROP TABLE IF EXISTS tutor;

-- 1. Criação da tabela Tutor (Clientes responsáveis pelos animais)
CREATE TABLE tutor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE, -- Restrição de Unicidade e Obrigatoriedade
    telefone VARCHAR(20),
    INDEX idx_tutor_cpf (cpf)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Criação da tabela Paciente (Animais de estimação atendidos)
CREATE TABLE paciente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    data_nascimento DATE,
    tutor_id INT NOT NULL,
    FOREIGN KEY (tutor_id) REFERENCES tutor(id) ON DELETE CASCADE, -- Integridade referencial em cascata
    INDEX idx_paciente_tutor (tutor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Criação da tabela Unidade (Filiais físicas da rede de hospitais)
CREATE TABLE unidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Criação da tabela Veterinario (Corpo médico especializado)
CREATE TABLE veterinario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crmv VARCHAR(20) NOT NULL UNIQUE, -- CRMV deve ser único por profissional
    especialidade VARCHAR(100),
    unidade_id INT NOT NULL,
    FOREIGN KEY (unidade_id) REFERENCES unidade(id),
    INDEX idx_vet_crmv (crmv)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Criação da tabela Servico (Catálogo de procedimentos e preços fixos)
CREATE TABLE servico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    valor_unitario DECIMAL(10, 2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Criação da tabela Consulta (Histórico de atendimentos clínicos realizados)
CREATE TABLE consulta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME NOT NULL,
    motivo VARCHAR(255),
    diagnostico TEXT,
    paciente_id INT NOT NULL,
    veterinario_id INT NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES paciente(id),
    FOREIGN KEY (veterinario_id) REFERENCES veterinario(id),
    INDEX idx_consulta_data (data_hora)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Criação da tabela Consulta_Servico (Tabela intermediária para relacionamento N:M)
CREATE TABLE consulta_servico (
    consulta_id INT NOT NULL,
    servico_id INT NOT NULL,
    quantidade INT DEFAULT 1 NOT NULL,
    PRIMARY KEY (consulta_id, servico_id), -- Chave primária composta
    FOREIGN KEY (consulta_id) REFERENCES consulta(id) ON DELETE CASCADE,
    FOREIGN KEY (servico_id) REFERENCES servico(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Criação da tabela Faturamento (Fluxo financeiro e controle de recebíveis)
CREATE TABLE faturamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_total DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pendente' NOT NULL, -- Valores restritos por regra de negócio
    consulta_id INT NOT NULL UNIQUE, -- Relacionamento estrito 1:1 com a consulta
    FOREIGN KEY (consulta_id) REFERENCES consulta(id) ON DELETE CASCADE,
    CONSTRAINT chk_status CHECK (status IN ('Pendente', 'Pago', 'Cancelado')) -- Restrição de verificação de domínio
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
