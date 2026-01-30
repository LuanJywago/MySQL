CREATE DATABASE IF NOT EXISTS oficina
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE oficina;

-- TABELA: Cliente
CREATE TABLE IF NOT EXISTS Cliente (
    idCliente         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome              VARCHAR(100) NOT NULL,
    CPF               CHAR(11) NOT NULL,
    dataNascimento    DATE NULL,
    sexo              ENUM('M','F','O') NOT NULL,
    telefone          VARCHAR(20) NULL,
    email             VARCHAR(150) NULL,
    logradouro        VARCHAR(100) NULL,
    numero            VARCHAR(10) NULL,
    complemento       VARCHAR(50) NULL,
    cidade            VARCHAR(30) NULL,
    UF                CHAR(2) NULL,
    CEP               CHAR(8) NULL,
    dataCadastro      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ativo             TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (idCliente),
    UNIQUE (CPF),
    UNIQUE (email)
) ENGINE=InnoDB;

-- TABELA: Veiculo
CREATE TABLE IF NOT EXISTS Veiculo (
    idVeiculo       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    idCliente       INT UNSIGNED NOT NULL,
    placa           VARCHAR(8) NOT NULL,
    renavam         CHAR(11) NOT NULL,
    chassi          CHAR(17) NOT NULL,
    marca           VARCHAR(40) NOT NULL,
    modelo          VARCHAR(60) NOT NULL,
    cor             VARCHAR(30) NULL,
    observacoes     VARCHAR(255) NULL,
    PRIMARY KEY (idVeiculo),
    UNIQUE (placa),
    UNIQUE (renavam),
    UNIQUE (chassi),
    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (idCliente)
        REFERENCES Cliente(idCliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- TABELA: Servico
CREATE TABLE IF NOT EXISTS Servico (
    idServico              INT UNSIGNED NOT NULL AUTO_INCREMENT,
    descricao              VARCHAR(255) NOT NULL,
    precoUnitario          DECIMAL(10,2) NOT NULL,
    tempoEstimadoMinutos   SMALLINT UNSIGNED NULL,
    observacoes            VARCHAR(255) NULL,
    ativo                  TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (idServico)
) ENGINE=InnoDB;

-- TABELA: Peca
CREATE TABLE IF NOT EXISTS Peca (
    idPeca          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    descricao       VARCHAR(255) NOT NULL,
    precoUnitario   DECIMAL(10,2) NOT NULL,
    unidadeMedida   VARCHAR(10) NOT NULL,
    estoqueAtual    INT UNSIGNED NOT NULL DEFAULT 0,
    estoqueMinimo   INT UNSIGNED NOT NULL DEFAULT 0,
    ativo           TINYINT(1) NOT NULL DEFAULT 1,
    observacoes     VARCHAR(255) NULL,
    PRIMARY KEY (idPeca)
) ENGINE=InnoDB;

-- TABELA: Mecanico
CREATE TABLE IF NOT EXISTS Mecanico (
    idMecanico     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100) NOT NULL,
    cpf            CHAR(11) NOT NULL,
    telefone       VARCHAR(20) NULL,
    email          VARCHAR(150) NULL,
    dataAdmissao   DATE NOT NULL,
    ativo          TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (idMecanico),
    UNIQUE (cpf),
    UNIQUE (email)
) ENGINE=InnoDB;

-- TABELA: Especialidade
CREATE TABLE IF NOT EXISTS Especialidade (
    idEspecialidade  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(60) NOT NULL,
    descricao        VARCHAR(255) NULL,
    ativo            TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (idEspecialidade),
    UNIQUE (nome)
) ENGINE=InnoDB;

-- TABELA: MecanicoEspecialidade (N:N)
CREATE TABLE IF NOT EXISTS MecanicoEspecialidade (
    idMecanico        INT UNSIGNED NOT NULL,
    idEspecialidade   INT UNSIGNED NOT NULL,
    nivel             TINYINT UNSIGNED NULL,
    observacoes       VARCHAR(255) NULL,
    PRIMARY KEY (idMecanico, idEspecialidade),
    FOREIGN KEY (idMecanico) REFERENCES Mecanico(idMecanico)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (idEspecialidade) REFERENCES Especialidade(idEspecialidade)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- TABELA: OrdemServico
CREATE TABLE IF NOT EXISTS OrdemServico (
    idOrdemServico         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    idCliente              INT UNSIGNED NOT NULL,
    idVeiculo              INT UNSIGNED NOT NULL,
    idMecanicoResponsavel  INT UNSIGNED NULL,
    dataAbertura           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dataFechamento         DATETIME NULL,
    status                 ENUM('aberta','em_execucao','finalizada','cancelada')
                              NOT NULL DEFAULT 'aberta',
    diagnostico            TEXT NULL,
    observacoes            TEXT NULL,
    PRIMARY KEY (idOrdemServico),
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (idVeiculo) REFERENCES Veiculo(idVeiculo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (idMecanicoResponsavel) REFERENCES Mecanico(idMecanico)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- TABELA: ItensServico
CREATE TABLE IF NOT EXISTS ItensServico (
    idItemServico    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    idOrdemServico   INT UNSIGNED NOT NULL,
    idServico        INT UNSIGNED NOT NULL,
    quantidade       DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    precoUnitario    DECIMAL(10,2) NOT NULL,
    desconto         DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    observacoes      VARCHAR(255) NULL,
    PRIMARY KEY (idItemServico),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (idServico) REFERENCES Servico(idServico)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- TABELA: ItensPeca
CREATE TABLE IF NOT EXISTS ItensPeca (
    idItemPeca       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    idOrdemServico   INT UNSIGNED NOT NULL,
    idPeca           INT UNSIGNED NOT NULL,
    quantidade       DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    precoUnitario    DECIMAL(10,2) NOT NULL,
    desconto         DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    observacoes      VARCHAR(255) NULL,
    PRIMARY KEY (idItemPeca),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (idPeca) REFERENCES Peca(idPeca)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- TABELA: Pagamento
CREATE TABLE IF NOT EXISTS Pagamento (
    idPagamento      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    idOrdemServico   INT UNSIGNED NOT NULL,
    forma            ENUM('dinheiro','debito','credito','pix','boleto') NOT NULL,
    valor            DECIMAL(10,2) NOT NULL,
    dataPagamento    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status           ENUM('pendente','confirmado','cancelado') NOT NULL DEFAULT 'confirmado',
    observacoes      VARCHAR(255) NULL,
    PRIMARY KEY (idPagamento),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;


INSERT INTO Cliente (nome, CPF, dataNascimento, sexo, telefone, email, logradouro, numero, complemento, cidade, UF, CEP)
VALUES
('Ana Paula Gomes','12345678901','1990-05-12','F','61998761122','ana.gomes@example.com','SQN 305 Bloco B','204',NULL,'Brasilia','DF','70736510'),
('Carlos Roberto Lima','98765432100','1985-11-03','M','61994443311','carlos.lima@example.com','QE 40 Conj F','21',NULL,'Brasilia','DF','71050000'),
('Juliana Alves','32165498712','1993-01-25','F','61991237788','juliana.alves@example.com','CLN 116','Lj 12',NULL,'Brasilia','DF','70773000');


INSERT INTO Veiculo (idCliente, placa, renavam, chassi, marca, modelo, cor, observacoes)
VALUES
(1,'ABC1D23','14523698741','9BWZZZ377VT004251','Volkswagen','Gol','Prata',NULL),
(2,'XYZ4E56','25874136985','9BD17123S0P012345','Fiat','Argo','Branco',NULL),
(3,'JKL9M01','36985214753','8ADZZZ377VT009876','Toyota','Corolla','Preto',NULL);



INSERT INTO Servico (descricao, precoUnitario, tempoEstimadoMinutos, observacoes, ativo)
VALUES
('Troca de óleo', 89.90, 30, 'Mão de obra básica', 1),
('Alinhamento', 120.00, 45, 'Geometria', 1),
('Balanceamento', 100.00, 40, 'Quatro rodas', 1),
('Revisão básica', 250.00, 90, 'Checklist', 1),
('Troca de pastilhas', 180.00, 60, 'Freio dianteiro', 1),
('Diagnóstico eletrônico', 150.00, 50, 'Scanner', 1),
('Troca de filtro de ar', 60.00, 20, NULL, 1),
('Troca de vela', 140.00, 50, NULL, 1);


INSERT INTO Peca (descricao, precoUnitario, unidadeMedida, estoqueAtual, estoqueMinimo, ativo, observacoes) 
VALUES
('Filtro de óleo', 35.00, 'UN', 50, 10, 1, NULL),
('Pastilha de freio', 120.00, 'JGO', 20, 5, 1, 'Par dianteiro'),
('Óleo 5W30 sintético', 45.00, 'L', 100, 30, 1, 'API SN'),
('Filtro de ar', 40.00, 'UN', 40, 10, 1, NULL),
('Correia dentada', 90.00, 'UN', 25, 5, 1, NULL),
('Vela de ignição', 25.00, 'UN', 80, 20, 1, NULL),
('Fluido de freio DOT4', 28.00, 'L', 30, 10, 1, NULL),
('Aditivo radiador', 22.00, 'L', 35, 10, 1, NULL);


INSERT INTO Mecanico (nome, cpf, telefone, email, dataAdmissao, ativo)
VALUES
('Joao Silva',  '11122233344', '61999990001', 'joao.silva@oficina.com', '2022-03-01', 1),
('Maria Souza', '55566677788', '61999990002', 'maria.souza@oficina.com', '2021-07-15', 1),
('Pedro Lima',  '99988877766', '61999990003', 'pedro.lima@oficina.com', '2020-01-20', 1),
('Carla Nunes', '33344455566', '61999990004', 'carla.nunes@oficina.com', '2023-02-10', 1);


INSERT INTO Especialidade (nome, descricao, ativo)
VALUES
('Motor',        'Serviços de motor', 1),
('Suspensao',    'Geometria e amortecedores', 1),
('Freios',       'Sistema de freio', 1),
('Eletrica',     'Elétrica embarcada', 1),
('Transmissao',  'Caixa e embreagem', 1),
('ArCondicionado','Climatização', 1),
('Alinhamento',  'Geometria direção', 1);


INSERT INTO MecanicoEspecialidade (idMecanico, idEspecialidade, nivel, observacoes)
VALUES
(1, 1, 5, 'Senior'),
(1, 3, 4, NULL),
(2, 4, 5, 'Especialista'),
(2, 6, 4, NULL),
(2, 2, 3, NULL),
(3, 2, 5, 'Especialista'),
(3, 7, 5, 'Especialista'),
(3, 3, 3, NULL),
(4, 5, 4, NULL),
(4, 1, 3, NULL);


INSERT INTO OrdemServico (idCliente, idVeiculo, idMecanicoResponsavel, dataAbertura, status, diagnostico, observacoes)
VALUES
(1, 1, 1, '2025-11-10 09:10:00', 'finalizada', 'Troca de óleo e filtro', NULL),
(2, 2, 2, '2025-11-12 14:30:00', 'em_execucao', 'Vibração na direção', 'Avaliar alinhamento e balanceamento'),
(3, 3, 3, '2025-11-15 10:00:00', 'aberta', 'Barulho nos freios dianteiros', NULL),
(1, 1, 4, '2025-11-20 08:40:00', 'aberta', 'Falha intermitente elétrica', NULL);


INSERT INTO ItensServico (idOrdemServico, idServico, quantidade, precoUnitario, desconto, observacoes)
VALUES
(1, 1, 1.00, 89.90, 0.00, NULL);
(2, 2, 1.00, 120.00, 0.00, NULL),
(2, 3, 1.00, 100.00, 0.00, NULL);
(3, 6, 1.00, 150.00, 0.00, 'Scanner'),
(3, 5, 1.00, 180.00, 10.00, 'Desconto'),
(3, 8, 4.00, 140.00, 0.00, NULL);
(4, 6, 1.00, 150.00, 0.00, NULL);
(1, 1, 1.00, 35.00, 0.00, NULL),
(1, 3, 4.00, 45.00, 0.00, '4 litros');
(2, 7, 1.00, 28.00, 0.00, NULL);
(3, 2, 1.00, 120.00, 0.00, 'Par dianteiro'),
(3, 6, 4.00, 25.00, 0.00, '4 velas');
(4, 4, 1.00, 40.00, 0.00, NULL);


INSERT INTO Pagamento (idOrdemServico, forma, valor, dataPagamento, status, observacoes) VALUES
(1, 'credito',  89.90 + 35.00 + (4*45.00), '2025-11-10 11:00:00', 'confirmado', 'À vista'),
(2, 'pix',      120.00,                   '2025-11-12 15:00:00', 'confirmado', 'Sinal'),
(2, 'debito',   100.00,                   '2025-11-13 10:00:00', 'confirmado', 'Parcial'),
(4, 'pix',      150.00 + 40.00,           '2025-11-20 10:00:00', 'pendente',   'Aguardando confirmação');


-- CONSULTA: Clientes (campos essenciais)
SELECT idCliente, nome, CPF, cidade, UF
FROM Cliente;

-- CONSULTA: Veículos
SELECT idVeiculo, idCliente, marca, modelo, placa
FROM Veiculo;

-- CONSULTA: Serviços ativos
SELECT idServico, descricao, precoUnitario
FROM Servico
WHERE ativo = 1;

-- CONSULTA: Peças em catálogo
SELECT idPeca, descricao, precoUnitario, estoqueAtual
FROM Peca;

-- CONSULTA: Ordens de serviço com status
SELECT idOrdemServico, idCliente, idVeiculo, status, dataAbertura
FROM OrdemServico;


-- CONSULTA: Clientes do DF
SELECT idCliente, nome, cidade, UF
FROM Cliente
WHERE UF = 'DF';

-- CONSULTA: Veículos da marca Toyota
SELECT idVeiculo, placa, marca, modelo
FROM Veiculo
WHERE marca = 'Toyota';

-- CONSULTA: Serviços com preço acima de 120
SELECT idServico, descricao, precoUnitario
FROM Servico
WHERE precoUnitario > 120.00;

-- CONSULTA: Peças com estoque abaixo do mínimo
SELECT idPeca, descricao, estoqueAtual, estoqueMinimo
FROM Peca
WHERE estoqueAtual < estoqueMinimo;

-- CONSULTA: OS abertas ou em execução
SELECT idOrdemServico, status, dataAbertura
FROM OrdemServico
WHERE status IN ('aberta','em_execucao');

-- CONSULTA: Idade aproximada do cliente (anos)
SELECT idCliente, nome,
       TIMESTAMPDIFF(YEAR, dataNascimento, CURDATE()) AS idade
FROM Cliente;

-- CONSULTA: Valor total por item de serviço (qtd * preço - desconto)
SELECT idItemServico, idOrdemServico, idServico,
       quantidade, precoUnitario, desconto,
       (quantidade * precoUnitario - desconto) AS total_item
FROM ItensServico;

-- CONSULTA: Valor total por item de peça
SELECT idItemPeca, idOrdemServico, idPeca,
       quantidade, precoUnitario, desconto,
       (quantidade * precoUnitario - desconto) AS total_item
FROM ItensPeca;

-- CONSULTA: Clientes ordenados por nome
SELECT idCliente, nome, cidade
FROM Cliente
ORDER BY nome ASC;

-- CONSULTA: Serviços do mais caro ao mais barato
SELECT idServico, descricao, precoUnitario
FROM Servico
ORDER BY precoUnitario DESC, descricao ASC;

-- CONSULTA: OS mais recentes primeiro
SELECT idOrdemServico, status, dataAbertura
FROM OrdemServico
ORDER BY dataAbertura DESC;

-- CONSULTA: Quantidade de veículos por cliente
SELECT c.idCliente, c.nome, COUNT(v.idVeiculo) AS qtd_veiculos
FROM Cliente c
LEFT JOIN Veiculo v ON v.idCliente = c.idCliente
GROUP BY c.idCliente, c.nome
ORDER BY qtd_veiculos DESC;

-- CONSULTA: Clientes com mais de 1 veículo (HAVING)
SELECT c.idCliente, c.nome, COUNT(v.idVeiculo) AS qtd_veiculos
FROM Cliente c
JOIN Veiculo v ON v.idCliente = c.idCliente
GROUP BY c.idCliente, c.nome
HAVING COUNT(v.idVeiculo) > 1;

-- CONSULTA: Faturamento por serviço (HAVING > 100)
SELECT s.descricao,
       SUM(isv.quantidade) AS total_qtd,
       SUM(isv.quantidade*isv.precoUnitario - isv.desconto) AS total_faturado
FROM ItensServico isv
JOIN Servico s ON s.idServico = isv.idServico
GROUP BY s.descricao
HAVING SUM(isv.quantidade*isv.precoUnitario - isv.desconto) > 100
ORDER BY total_faturado DESC;

-- CONSULTA: Pagamento confirmado por forma (apenas > 200)
SELECT forma, SUM(valor) AS total
FROM Pagamento
WHERE status = 'confirmado'
GROUP BY forma
HAVING SUM(valor) > 200
ORDER BY total DESC;


-- CONSULTA: Clientes e seus veículos
SELECT c.idCliente, c.nome, v.idVeiculo, v.placa, v.marca, v.modelo
FROM Cliente c
JOIN Veiculo v ON v.idCliente = c.idCliente
ORDER BY c.nome;

-- CONSULTA: OS com cliente, veículo e mecânico
SELECT os.idOrdemServico, os.status, os.dataAbertura,
       c.nome AS cliente, v.placa, v.modelo, m.nome AS mecanico
FROM OrdemServico os
JOIN Cliente c  ON c.idCliente = os.idCliente
JOIN Veiculo v  ON v.idVeiculo = os.idVeiculo
LEFT JOIN Mecanico m ON m.idMecanico = os.idMecanicoResponsavel
ORDER BY os.idOrdemServico DESC;

-- CONSULTA: Itens de serviços de cada OS (detalhado)
SELECT os.idOrdemServico, c.nome AS cliente, s.descricao AS servico,
       isv.quantidade, isv.precoUnitario, isv.desconto,
       (isv.quantidade*isv.precoUnitario - isv.desconto) AS total_item
FROM ItensServico isv
JOIN OrdemServico os ON os.idOrdemServico = isv.idOrdemServico
JOIN Cliente c       ON c.idCliente = os.idCliente
JOIN Servico s       ON s.idServico = isv.idServico
ORDER BY os.idOrdemServico;

-- CONSULTA: Itens de peças de cada OS (detalhado)
SELECT os.idOrdemServico, c.nome AS cliente, p.descricao AS peca,
       ip.quantidade, ip.precoUnitario, ip.desconto,
       (ip.quantidade*ip.precoUnitario - ip.desconto) AS total_item
FROM ItensPeca ip
JOIN OrdemServico os ON os.idOrdemServico = ip.idOrdemServico
JOIN Cliente c       ON c.idCliente = os.idCliente
JOIN Peca p          ON p.idPeca = ip.idPeca
ORDER BY os.idOrdemServico;

-- CONSULTA: Serviços executados por mecânico (JOIN múltiplo + GROUP BY)
SELECT m.nome AS mecanico,
       COUNT(isv.idItemServico) AS qtd_itens_servico,
       SUM(isv.quantidade*isv.precoUnitario - isv.desconto) AS faturado_servicos
FROM OrdemServico os
JOIN Mecanico m  ON m.idMecanico = os.idMecanicoResponsavel
JOIN ItensServico isv ON isv.idOrdemServico = os.idOrdemServico
GROUP BY m.nome
ORDER BY faturado_servicos DESC;

-- CONSULTA: Mecânicos e suas especialidades (N:N)
SELECT m.nome AS mecanico, e.nome AS especialidade, me.nivel
FROM MecanicoEspecialidade me
JOIN Mecanico m ON m.idMecanico = me.idMecanico
JOIN Especialidade e ON e.idEspecialidade = me.idEspecialidade
ORDER BY m.nome, me.nivel DESC;