create database if not exists Manipulation;

use Manipulation;

create table bankAccounts(
    Id_account  int auto_increment Primary Key,
    Ag_num int not null,
    Ac_num int not null, 
    Saldo float,
    Constraint identification_account_constraint UNIQUE (Ag_num, Ac_num)
);

-- remove a tabela (so pode remover se remover a fk dele, vai dar erro!)
drop table bankAccounts

-- Modificando a tabela
Alter table bankAccounts
    add LimiteCredito float not null default 500; -- define 500 reais de limite padrão para cada conta criada

-- verficar se foi modificado
desc bankAccounts

-- Modificando a tabela
alter table bankAccounts
a   dd email varchar(50);

-- Removendo o atributo email
alter table bankAccounts
    drop column email; -- Coluna email vai ser removida

-- alter table nome_tabela modify column nome_atributo tipo_dados condição;
-- alter table nome_tabela add, constraint nome_constraint condições;


create table bankClient(
    Id_client  INT auto_increment,
    ClientAccount INT,
    CPF char(13) not null,
    RG char (9),
    Nome varchar (50) not null,
    Endereço varchar(100) not null,
    Renda_mensal float,
    primary key (Id_client, ClientAccount),
    Constraint fk_Account_client foreign key (ClientAccount) references bankAccounts(Id_account) on update cascade
);

--remove a tabela
drop table bankClient

create table bankTransactions(
    Id_transaction int auto_increment primary key,
    Ocorrencia datetime,
    Status_transaction VARCHAR(20),
    Valor_transferencia float,
    Source_account int,
    Destination_account int,
    Constraint fk_source_transaction foreign key (Source_account) references bankAccounts(Id_account),
    Constraint fk_destination_transaction foreign key (Destination_account) references bankAccounts(Id_account)
),


-- modificando tabela
Alter table bankClient
    add UFF char(2) not null;

--inserção do dado

insert into bankAccounts (Ag_num, Ac_num, Saldo)
    values (1235, 123, 123123, 0);

-- visualizando as informações
select * from bankAccounts;

insert into bankClient (ClientAccount, CPF, RG, Nome, Endereço, Renda_mensal)
    value (1, 1235, 12312312323, 123123123, "Fulano", "Alguma rua", 5892.0,);

-- recuperando a informação que acabou de atribuir
select * from bankClient;

-- atualizar uma tabela
update bankClient
    set UFF = 'MG'
    where Nome = "Fulano"

-- Ordenando
Select Id_account
from bankAccounts
ORDER BY amount LIMIT 5; -- define o limite de 5 dados

