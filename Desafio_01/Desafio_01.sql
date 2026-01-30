-- CRIAÇÃO DO BANCO DE DADOS E UTILIZAÇÃO DELE
CREATE DATABASE IF NOT EXISTS ecommerce;

USE ecommerce;

-- CRIAÇÃO DAS TABELAS
-- Tabela Client
CREATE TABLE IF NOT EXISTS Client(
    IdClient INT NOT NULL AUTO_INCREMENT,
    Fname VARCHAR(20) NOT NULL,
    Mname VARCHAR(25),
    Lname VARCHAR(25),
    CPF CHAR(11) NOT NULL,
    Address VARCHAR(100),
    Bdate DATE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Client PRIMARY KEY (IdClient),
    CONSTRAINT uq_Client_CPF UNIQUE (CPF),
    CONSTRAINT ck_Client_CPF CHECK (CPF REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;

-- Tabela Orders
CREATE TABLE IF NOT EXISTS Orders(
    IdOrder INT NOT NULL AUTO_INCREMENT,
    IdClient INT NOT NULL,
    OrderStatus ENUM ('Sent', 'Processing', 'Delivered', 'In Progress') NOT NULL DEFAULT 'Processing',
    Descricao VARCHAR(255),
    Frete DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Orders PRIMARY KEY (IdOrder),
    CONSTRAINT fk_Orders_idClient 
        FOREIGN KEY (IdClient) REFERENCES Client(IdClient)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS ix_Orders_IdClient ON Orders (IdClient);

-- Tabela Product
CREATE TABLE IF NOT EXISTS Product(
    IdProduct INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL,
    Category VARCHAR(45),
    Descricao VARCHAR(255),
    Price DECIMAL(10,2) NOT NULL,
    Ativo TINYINT(1) NOT NULL DEFAULT 1,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Product PRIMARY KEY (IdProduct),
    CONSTRAINT ck_Product_Price CHECK (Price >= 0)
) ENGINE=InnoDB;

-- Tabela OrderItems
CREATE TABLE IF NOT EXISTS OrderItems(
    IdOrder INT NOT NULL,
    IdProduct INT NOT NULL,
    Quantidade INT NOT NULL,
    Status ENUM ('Separado', 'Em Falta', 'Cancelado', 'Entregue') DEFAULT 'Separado',
    UnitPrice DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_OrderItems PRIMARY KEY (IdOrder, IdProduct),
    CONSTRAINT fk_OrderItems_Order FOREIGN KEY (IdOrder)
        REFERENCES Orders(IdOrder)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_OrderItems_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_OrderItems_Qtd CHECK (Quantidade > 0),
    CONSTRAINT ck_OrderItems_Preco CHECK (UnitPrice >= 0),
    CONSTRAINT ck_OrderItems_Discount CHECK (Discount >= 0)
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS ix_OrderItems_IdProduct ON OrderItems (IdProduct);

-- Tabela Payment
CREATE TABLE IF NOT EXISTS Payment(
    IdPayment INT NOT NULL AUTO_INCREMENT,
    IdOrder INT NOT NULL,
    IdClient INT NOT NULL,
    PaymentMethod ENUM('Pix','Cartao','Boleto','Dinheiro','Dois Cartoes') NOT NULL,
    PaymentStatus ENUM('Pending','Paid','Failed','Refunded') DEFAULT 'Pending',
    Amount DECIMAL(10,2) NOT NULL,
    PaidAt DATETIME NULL,
    TransactionCode VARCHAR(100),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Payment PRIMARY KEY (IdPayment),
    CONSTRAINT fk_Payment_Order
        FOREIGN KEY (IdOrder) REFERENCES Orders(IdOrder)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_Payment_Client
        FOREIGN KEY (IdClient) REFERENCES Client(IdClient)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_Payment_Amount CHECK (Amount >= 0)
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS ix_Payment_IdOrder ON Payment (IdOrder);
CREATE INDEX IF NOT EXISTS ix_Payment_IdClient ON Payment (IdClient);

-- Tabela Vendor
CREATE TABLE IF NOT EXISTS Vendor(
    IdVendor INT NOT NULL AUTO_INCREMENT,
    RazaoSocial VARCHAR(120) NOT NULL,
    NomeFantasia VARCHAR(120),
    Local VARCHAR(120),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Vendor PRIMARY KEY (IdVendor),
    CONSTRAINT uq_Vendor_Razao UNIQUE (RazaoSocial)
) ENGINE=InnoDB;

-- VendorProduct 
CREATE TABLE IF NOT EXISTS VendorProduct(
    IdVendor INT NOT NULL,
    IdProduct INT NOT NULL,
    Quantidade INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_VendorProduct PRIMARY KEY (IdVendor, IdProduct),
    CONSTRAINT fk_VendorProduct_Vendor FOREIGN KEY (IdVendor)
        REFERENCES Vendor(IdVendor)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_VendorProduct_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_VendorProduct_Qtd CHECK (Quantidade >= 0)
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS ix_VendorProduct_IdProduct ON VendorProduct (IdProduct);

-- Tabela Stock
CREATE TABLE IF NOT EXISTS Stock(
    IdStock INT NOT NULL AUTO_INCREMENT,
    Local VARCHAR(120) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Stock PRIMARY KEY (IdStock)
) ENGINE=InnoDB;

-- ProductStock 
CREATE TABLE IF NOT EXISTS ProductStock(
    IdProduct INT NOT NULL,
    IdStock INT NOT NULL,
    Quantidade INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ProductStock PRIMARY KEY (IdProduct, IdStock),
    CONSTRAINT fk_ProductStock_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_ProductStock_Stock FOREIGN KEY (IdStock)
        REFERENCES Stock(IdStock)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_ProductStock_Qtd CHECK (Quantidade >= 0)
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS ix_ProductStock_IdStock ON ProductStock (IdStock);

--Supplier
CREATE TABLE IF NOT EXISTS Supplier(
    IdSupplier INT NOT NULL AUTO_INCREMENT,
    RazaoSocial VARCHAR(120) NOT NULL,
    CNPJ CHAR(14) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Supplier PRIMARY KEY (IdSupplier),
    CONSTRAINT uq_Supplier_CNPJ UNIQUE (CNPJ),
    CONSTRAINT ck_Supplier_CNPJ CHECK (CNPJ REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB;

-- SupplierProduct 
CREATE TABLE IF NOT EXISTS SupplierProduct(
    IdSupplier INT NOT NULL,
    IdProduct INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_SupplierProduct PRIMARY KEY (IdSupplier, IdProduct),
    CONSTRAINT fk_SupplierProduct_Supplier FOREIGN KEY (IdSupplier)
        REFERENCES Supplier(IdSupplier)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_SupplierProduct_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS ix_SupplierProduct_IdProduct ON SupplierProduct (IdProduct);

-- INSERINDO DADOS EM CLIENT
INSERT INTO Client (Fname, Mname, Lname, CPF, Address, Bdate) VALUES
('Lucas',  'Henrique', 'Almeida',  '12345678901', 'Rua das Flores, 120 - Brasília',     '1995-04-12'),
('Mariana','Silva',    'Souza',    '23456789012', 'Av. Central, 450 - Goiânia',          '1992-09-23'),
('Pedro',  'Augusto',  'Ferreira', '34567890123', 'Rua 7 de Setembro, 90 - São Paulo',   '1988-01-30'),
('Ana',    'Beatriz',  'Oliveira', '45678901234', 'Rua das Palmeiras, 55 - Rio',         '1999-06-05'),
('João',   'Paulo',    'Gomes',    '56789012345', 'Alameda Santos, 800 - Curitiba',       '1985-11-19'),
('Carla',  'Cristina', 'Mendes',   '67890123456', 'Rua A, 45 - Belo Horizonte',           '1993-03-07'),
('Rafael', 'Moreira',  'Castro',   '78901234567', 'Travessa Azul, 12 - Salvador',         '1990-12-01'),
('Vitória','Lopes',    'Martins',  '89012345678', 'Rua José Bonifácio, 210 - Porto Alegre','1997-08-14');

-- INSERINDO DADOS EM PRODUCT
INSERT INTO Product (Nome, Category, Descricao, Price, Ativo) VALUES
('Fone de Ouvido Bluetooth',        'Eletrônicos',  'Fone sem fio com cancelamento de ruído',                159.90, 1),
('Mouse Gamer RGB',                 'Informática',  'Mouse gamer 7200 DPI com iluminação RGB',               89.99,  1),
('Camiseta Oversized Preta',        'Vestuário',    'Camiseta unissex algodão premium',                      49.90,  1),
('Smartwatch FitPlus',              'Eletrônicos',  'Relógio inteligente com monitor cardíaco',              229.00, 1),
('Garrafa Térmica 1L',              'Casa e Cozinha','Garrafa inox, mantém temperatura por 12h',             79.50,  1),
('Teclado Mecânico Blue Switch',    'Informática',  'Teclado mecânico com switches azuis',                   199.90, 1),
('Tênis Running Pro',               'Calçados',     'Tênis leve para corrida com amortecimento',             259.99, 1),
('Mochila Antifurto',               'Acessórios',   'Mochila com porta USB e compartimentos secretos',       129.90, 1),
('Jogo de Panelas Antiaderente',    'Casa e Cozinha','Conjunto com 5 panelas antiaderentes premium',         349.00, 1),
('Suporte Articulado p/ Monitor',   'Informática',  'Suporte ajustável para monitores até 32\"',             119.90, 1);

-- INSERINDO DADOS EM STOCK
INSERT INTO Stock (Local) VALUES
('CD Brasília'),
('CD São Paulo'),
('Loja Goiânia');

-- INSERINDO DADOS EM PRODUCTSTOCK
INSERT INTO ProductStock (IdProduct, IdStock, Quantidade) VALUES
(1, 1, 10), (1, 2, 15),
(2, 1, 32), (2, 3, 5),
(3, 1, 12),
(4, 2, 54),
(5, 2, 25),
(6, 1, 17), (6, 2, 10),
(7, 3, 8),
(8, 1, 12),
(9, 2, 5),
(10, 3, 22);

-- INSERINDO DADOS EM VENDOR
INSERT INTO Vendor (RazaoSocial, NomeFantasia, Local) VALUES
('Tech Imports LTDA',               'TechImports',     'Brasília'),
('Casa & Cozinha Distribuidora ME', 'Casa&Cozinha',    'São Paulo'),
('GamerZone Comércio Digital EIRELI','GamerZone',      'Curitiba');

-- INSERINDO DADOS EM SUPPLIER
INSERT INTO Supplier (RazaoSocial, CNPJ) VALUES
('Tech Imports LTDA',                '11222333000199'),
('BR Supply Solutions SA',           '00998877000155'),
('Casa & Cozinha Distribuidora ME',  '44556677000111');

-- INSERINDO DADOS EM VENDORPRODUCT
INSERT INTO VendorProduct (IdVendor, IdProduct, Quantidade) VALUES
(1, 1, 20), (1, 4, 12), (1, 6, 10),
(2, 5, 30), (2, 9, 10),
(3, 2, 25), (3, 6, 8), (3, 10, 15);

-- INSERINDO DADOS EM SUPPLIERPRODUCT
INSERT INTO SupplierProduct (IdSupplier, IdProduct) VALUES
(1, 1), (1, 4), (1, 6),
(2, 2), (2, 10),
(3, 5), (3, 9);

-- INSERINDO DADOS EM ORDERS
INSERT INTO Orders (IdClient, OrderStatus, Descricao, Frete) VALUES
(1, 'Processing',  'Compra de periféricos',                 19.90),
(2, 'In Progress', 'Compra de itens de informática',        25.00),
(1, 'Delivered',   'Pedido entregue ao cliente',             0.00),
(3, 'Sent',        'Pedido enviado para transportadora',    14.50),
(4, 'Processing',  'Compra de acessórios para PC',          18.90),
(5, 'Delivered',   'Pedido entregue — modalidade rápida',   22.00),
(6, 'In Progress', 'Compra de equipamentos eletrônicos',    30.00),
(7, 'Sent',        'Aguardando recebimento pelo cliente',   15.80),
(8, 'Processing',  'Pedido aguardando separação de itens',  20.00),
(1, 'Delivered',   'Entrega concluída com sucesso',          0.00);

-- INSERINDO DADOS EM ORDERITEMS O/I
INSERT INTO OrderItems (IdOrder, IdProduct, Quantidade, Status, UnitPrice, Discount) VALUES
(1, 1, 2, 'Separado', 159.90,  0.00),
(1, 3, 1, 'Separado',  49.90,  0.00),
(2, 2, 1, 'Separado',  89.99,  0.00),
(2, 4, 3, 'Em Falta', 229.00, 10.00),
(3, 1, 1, 'Entregue', 159.90,  0.00),
(4, 5, 2, 'Separado',  79.50,  5.00),
(5, 3, 1, 'Separado',  49.90,  0.00),
(5, 4, 1, 'Cancelado',229.00,  0.00),
(6, 2, 2, 'Entregue',  89.99,  0.00),
(7, 1, 4, 'Separado', 159.90, 20.00);


-- NOVAS TABELAS QUE FALTARAM
CREATE TABLE IF NOT EXISTS ProductOrder(
    IdPOproduct INT NOT NULL,
    IdPOorder   INT NOT NULL,
    poQuantity  INT NOT NULL,
    poStatus    ENUM ('Separado', 'Em Falta', 'Cancelado', 'Entregue') DEFAULT 'Separado',
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ProductOrder PRIMARY KEY (IdPOorder, IdPOproduct),
    CONSTRAINT fk_ProductOrder_Product FOREIGN KEY (IdPOproduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_ProductOrder_Order FOREIGN KEY (IdPOorder)
        REFERENCES Orders(IdOrder)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_ProductOrder_Qtd CHECK (poQuantity > 0)
) ENGINE=InnoDB;

-- INSERINDO DADOS EM PRODUCTORDER
INSERT INTO ProductOrder (IdPOorder, IdPOproduct, poQuantity, poStatus) VALUES
(1, 1, 2, 'Separado'),
(1, 3, 1, 'Separado'),
(2, 2, 1, 'Separado'),
(2, 4, 3, 'Em Falta'),
(3, 1, 1, 'Entregue'),
(4, 5, 2, 'Separado'),
(5, 3, 1, 'Separado'),
(5, 4, 1, 'Cancelado'),
(6, 2, 2, 'Entregue'),
(7, 1, 4, 'Separado');

-- ADICIONANDO UQ (UNIQUE) QUE DEVIA TER SIDO DETERMINADA
-- ADICIONADO ATRAVEZ DE MODIFICAÇÃO EM TABELA
ALTER TABLE Stock
    ADD CONSTRAINT uq_Stock_Local UNIQUE (Local);

-- CRIANDO TABELA PRODUCTSTORAGE QUE FALTOU NO ESQUEMA CONFORME VISTO NA AULA DE DESAFIO
CREATE TABLE IF NOT EXISTS ProductStorage(
    IdProduct INT NOT NULL,
    storageLocation VARCHAR(120) NOT NULL,  -- corresponde a Stock.Local
    quantity INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ProductStorage PRIMARY KEY (IdProduct, storageLocation),
    CONSTRAINT fk_ProductStorage_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_ProductStorage_StockLocal FOREIGN KEY (storageLocation)
        REFERENCES Stock(Local)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_ProductStorage_Qtd CHECK (quantity >= 0)
) ENGINE=InnoDB;

-- INSERINDO DADOS EM PRODUCTSTORAGE
INSERT INTO ProductStorage (IdProduct, storageLocation, quantity) VALUES
(1, 'CD Brasília', 20),
(1, 'CD São Paulo', 10),
(2, 'CD Brasília', 15),
(3, 'CD Brasília',  5),
(4, 'CD São Paulo', 25),
(5, 'CD São Paulo', 12),
(6, 'CD Brasília',  8),
(6, 'Loja Goiânia',  6),
(10,'Loja Goiânia', 10);

--RESPOSTAS ÀS PERGUNTAS (QUERIES + COMENTÁRIOS)

--1) Quantos pedidos foram feitos por cada cliente?
SELECT 
    c.IdClient,
    CONCAT(c.Fname, ' ', COALESCE(c.Mname, ''), ' ', c.Lname) AS Cliente,
    COUNT(o.IdOrder) AS QtdePedidos
FROM Client c
LEFT JOIN Orders o ON o.IdClient = c.IdClient
GROUP BY c.IdClient, Cliente
ORDER BY QtdePedidos DESC, Cliente;


-- 2) Algum vendedor também é fornecedor?
-- resposta: Sim. "Tech Imports LTDA" e "Casa & Cozinha Distribuidora ME" aparecem em ambas as tabelas.
SELECT 
    v.IdVendor, v.RazaoSocial AS Entidade
FROM Vendor v
JOIN Supplier s ON s.RazaoSocial = v.RazaoSocial;

--3) Relação de produtos, fornecedores e estoques (Produto x Fornecedor x Local de estoque com quantidade)
SELECT 
    p.IdProduct,
    p.Nome AS Produto,
    s.RazaoSocial AS Fornecedor,
    st.Local AS Estoque,
    ps.Quantidade
FROM Product p
JOIN SupplierProduct sp ON sp.IdProduct = p.IdProduct
JOIN Supplier s ON s.IdSupplier = sp.IdSupplier
LEFT JOIN ProductStock ps ON ps.IdProduct = p.IdProduct
LEFT JOIN Stock st ON st.IdStock = ps.IdStock
ORDER BY p.IdProduct, Fornecedor, Estoque;

-- 4) Relação de nomes dos fornecedores e nomes dos produtos
SELECT 
    s.RazaoSocial AS Fornecedor,
    p.Nome AS Produto
FROM Supplier s
JOIN SupplierProduct sp ON sp.IdSupplier = s.IdSupplier
JOIN Product p ON p.IdProduct = sp.IdProduct
ORDER BY Fornecedor, Produto;
