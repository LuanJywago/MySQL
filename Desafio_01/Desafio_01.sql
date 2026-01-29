-- CRIAR O DB E USAR
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- TABELA: Client
CREATE TABLE Client(
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

-- TABELA: Orders
CREATE TABLE Orders(
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

-- Índice útil para consultas por cliente
CREATE INDEX ix_Orders_IdClient ON Orders (IdClient);

-- TABELA: Product
CREATE TABLE Product(
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

-- TABELA DE RELAÇÃO: OrderItems (Produto/Pedido)
CREATE TABLE OrderItems(
    IdOrder INT NOT NULL,
    IdProduct INT NOT NULL,
    Quantidade INT NOT NULL,
    Status ENUM ('Separado', 'Em Falta', 'Cancelado', 'Entregue') DEFAULT 'Separado',
    UnitPrice DECIMAL(10,2) NOT NULL,           -- preço no momento do pedido
    Discount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_OrderItems PRIMARY KEY (IdOrder, IdProduct),  -- evita duplicar produto no mesmo pedido
    CONSTRAINT fk_OrderItems_Order FOREIGN KEY (IdOrder)
        REFERENCES Orders(IdOrder)
        ON UPDATE CASCADE
        ON DELETE CASCADE,                      -- apaga itens ao apagar pedido
    CONSTRAINT fk_OrderItems_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,                     -- não deixa apagar produto em pedidos
    CONSTRAINT ck_OrderItems_Qtd CHECK (Quantidade > 0),
    CONSTRAINT ck_OrderItems_Preco CHECK (UnitPrice >= 0),
    CONSTRAINT ck_OrderItems_Discount CHECK (Discount >= 0)
) ENGINE=InnoDB;

-- Índice útil para buscas de itens por produto
CREATE INDEX ix_OrderItems_IdProduct ON OrderItems (IdProduct);

-- TABELA: Payment
CREATE TABLE Payment(
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

-- Índices úteis
CREATE INDEX ix_Payment_IdOrder ON Payment (IdOrder);
CREATE INDEX ix_Payment_IdClient ON Payment (IdClient);

-- TERCEIRO / VENDEDOR (marketplace/lojista parceiro)
CREATE TABLE vendor(
    IdVendor INT NOT NULL AUTO_INCREMENT,
    RazaoSocial VARCHAR(120) NOT NULL,
    NomeFantasia VARCHAR(120),
    Local VARCHAR(120),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Vendor PRIMARY KEY (IdVendor),
    CONSTRAINT uq_Vendor_Razao UNIQUE (RazaoSocial)
) ENGINE=InnoDB;

-- PRODUTOS POR VENDEDOR (terceiro) – relacionamento N:N com atributo Quantidade
CREATE TABLE VendorProduct(
    IdVendor INT NOT NULL,
    IdProduct INT NOT NULL,
    Quantidade INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_VendorProduct PRIMARY KEY (IdVendor, IdProduct),
    CONSTRAINT fk_VendorProduct_Vendor FOREIGN KEY (IdVendor)
        REFERENCES Vendor(IdVendor)
        ON UPDATE CASCADE
        ON DELETE CASCADE,     -- se excluir o Vendor, apaga seus anúncios/itens
    CONSTRAINT fk_VendorProduct_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,    -- não permite excluir Produto que está sendo vendido
    CONSTRAINT ck_VendorProduct_Qtd CHECK (Quantidade >= 0)
) ENGINE=InnoDB;

CREATE INDEX ix_VendorProduct_IdProduct ON VendorProduct (IdProduct);

-- ESTOQUE (locais físicos ou lógicos)
CREATE TABLE Stock(
    IdStock INT NOT NULL AUTO_INCREMENT,
    Local VARCHAR(120) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Stock PRIMARY KEY (IdStock)
) ENGINE=InnoDB;

-- RELAÇÃO PRODUTO x ESTOQUE (quantidades por local)
CREATE TABLE ProductStock(
    IdProduct INT NOT NULL,
    IdStock INT NOT NULL,
    Quantidade INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ProductStock PRIMARY KEY (IdProduct, IdStock),
    CONSTRAINT fk_ProductStock_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,    -- impede apagar Produto em estoque
    CONSTRAINT fk_ProductStock_Stock FOREIGN KEY (IdStock)
        REFERENCES Stock(IdStock)
        ON UPDATE CASCADE
        ON DELETE CASCADE,     -- se excluir um estoque, apaga as quantidades daquele local
    CONSTRAINT ck_ProductStock_Qtd CHECK (Quantidade >= 0)
) ENGINE=InnoDB;

CREATE INDEX ix_ProductStock_IdStock ON ProductStock (IdStock);

-- FORNECEDOR
CREATE TABLE Supplier(
    IdSupplier INT NOT NULL AUTO_INCREMENT,
    RazaoSocial VARCHAR(120) NOT NULL,
    CNPJ CHAR(14) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Supplier PRIMARY KEY (IdSupplier),
    CONSTRAINT uq_Supplier_CNPJ UNIQUE (CNPJ),
    CONSTRAINT ck_Supplier_CNPJ CHECK (CNPJ REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB;

-- PRODUTOS FORNECIDOS (Fornecedor disponibiliza Produto) – N:N
CREATE TABLE SupplierProduct(
    IdSupplier INT NOT NULL,
    IdProduct INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_SupplierProduct PRIMARY KEY (IdSupplier, IdProduct),
    CONSTRAINT fk_SupplierProduct_Supplier FOREIGN KEY (IdSupplier)
        REFERENCES Supplier(IdSupplier)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,    -- impede excluir fornecedor com catálogo ativo
    CONSTRAINT fk_SupplierProduct_Product FOREIGN KEY (IdProduct)
        REFERENCES Product(IdProduct)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX ix_SupplierProduct_IdProduct ON SupplierProduct (IdProduct);


-- CASOS DE USO
-- Persistindo dados dentro de client
INSERT INTO Client (Fname, Mname, Lname, CPF, Address)
VALUES
('Lucas', 'Henrique', 'Almeida', '12345678901', 'Rua das Flores, 120 - Brasília'),
('Mariana', 'Silva', 'Souza', '23456789012', 'Av. Central, 450 - Goiânia'),
('Pedro', 'Augusto', 'Ferreira', '34567890123', 'Rua 7 de Setembro, 90 - São Paulo'),
('Ana', 'Beatriz', 'Oliveira', '45678901234', 'Rua das Palmeiras, 55 - Rio de Janeiro'),
('João', 'Paulo', 'Gomes', '56789012345', 'Alameda Santos, 800 - Curitiba'),
('Carla', 'Cristina', 'Mendes', '67890123456', 'Rua A, 45 - Belo Horizonte'),
('Rafael', 'Moreira', 'Castro', '78901234567', 'Travessa Azul, 12 - Salvador'),
('Vitória', 'Lopes', 'Martins', '89012345678', 'Rua José Bonifácio, 210 - Porto Alegre');

SELECT * FROM Client;

SELECT * FROM Product;

INSERT INTO Orders (IdOrder, OrderStatus, Descricao, Frete) -- tomar cuidado por o IdOrder está como AUTO_INCREMENT, SE DER ERRO, RETIRE!
VALUES
(1, 'Processing', 'Compra de periféricos', 19.90),
(2, 'In Progress', 'Compra de itens de informática', 25.00),
(3, 'Delivered', 'Pedido entregue ao cliente', 0.00),
(4, 'Sent', 'Pedido enviado para transportadora', 14.50),
(5, 'Processing', 'Compra de acessórios para PC', 18.90),
(6, 'Delivered', 'Pedido entregue — modalidade rápida', 22.00),
(7, 'In Progress', 'Compra de equipamentos eletrônicos', 30.00),
(8, 'Sent', 'Aguardando recebimento pelo cliente', 15.80),
(9, 'Processing', 'Pedido aguardando separação de itens', 20.00),
(10, 'Delivered', 'Entrega concluída com sucesso', 0.00);

SELECT * FROM Orders;

INSERT INTO OrderItems (IdOrder, Idproduct, Quantidade, Status)
VALUES

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

SELECT * FROM OrderItems;

INSERT INTO ProductStock


-- OBJETIVO:
-- Cliente PJ e PF – Uma conta pode ser PJ ou PF, mas não pode ter as duas informações;
-- Pagamento – Pode ter cadastrado mais de uma forma de pagamento;
-- Entrega – Possui status e código de rastreio;


























-- PERGUNTAS PARA EMBASAS AS QUERIES SQL
-- 1. Quantos pedidos foram feitos por cada cliente?



-- 2. Algum vendedor também é fornecedor?



-- 3. Relação de produtos fornecedores e estoques;



-- 4. Relação de nomes dos fornecedores e nomes dos produtos;



