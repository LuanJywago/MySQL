-- Criando schema ou banco de dados
CREATE SCHEMA if not exists company;

-- Fazendo a chamada para usar um schema ou BD 
USE company;

-- Criando as tabelas do schema ou BD
CREATE TABLE company.employee(
    Fname VARCHAR(15) NOT NULL,
    Minit char,
    Lname VARCHAR(15) NOT NULL,
    Ssn char(9) NOT NULL,
    Bdate DATE,
    address VARCHAR(30),
    Sex char,
    Salary decimal(10, 2),
    Super_ssl char (9),
    Dno INT NOT NULL,
    primary key (Ssn)
);

CREATE TABLE departament(
    Dname VARCHAR(15) NOT NULL,
    Dnumber INT NOT NULL,
    Mgr_ssn char(9),
    Mgr_start_date DATE,
    primary key (Dnumber),
    Unique (Dname),
    foreign key(Mgr_ssn) references employee(Ssn)
);

CREATE TABLE dept_location(
    Dnumber int not null,
    Dlocation varchar(20) not null,
    primary key(Dnumber, Dlocation),
    foreign key (Dnumber) references departament(Dnumber)
);

CREATE TABLE project(
    Pname varchar(20) not null,
    Pnumber int not null,
    Plocation varchar(15),
    Dnum int not null,
    primary key (Pnumber),
    unique (Pname),
    foreign key (Dnumber) references departament(Dnumber)
);

CREATE TABLE works_on(
    Essn char(9) not null,
        Pno int not null,
        Hours decimal(3,1) not null,
        primary key (Essn, Pno), --- comentario
        foreign key (Essn) references employee(Ssn),
        foreign key (Pno) references project(Pnumber)
);

CREATE TABLE dependent(
    Essn char(9) not null,
    Dependet_name varchar(15) not null,
    sex char,
    Bdate date,
    Relationship varchar(9),
    primary key (Essn, Dependet_name), --dupla chave primaria
    foreign key (Essn) references employee(Ssn)
);

-- Alterando uma tabela colocando uma fk NOVA
ALTER TABLE employee
    add constraint fk_employee
    foreign key (Super_ssn) references employee (Ssn)
    in delete set null on update cascade;-- evento em cascata, atualização automatica que acontecem nas filhas baseadas no grau de parentesco

-- modificar uma cosntraint
ALTER TABLE departament drop constraint departament_ibfk_1;
alter table departament
    add cosntraint fk_departament foreign key(Mrg_ssn)
    references employee(Ssn)
    on update cascade

-- persistencia de dados, colocando dados dentro da tabela employee
insert into employee
values
    ('John','B','Smithy',123456289,'731-fOUNDREN-hOUSTON-tx','M',300000,33344455555, null);
    ('John','B','Smithr',173456789,'731-fOUNDREN-hOUSTON-tx','M',300000,33344455355, null);
    ('John','B','Smithw',123453789,'731-fOUNDREN-hOUSTON-tx','M',300000,33344455955, null);
    ('John','B','Smithq',123451789,'731-fOUNDREN-hOUSTON-tx','M',300000,33344455855, null);
    ('John','B','Smitha',123446789,'731-fOUNDREN-hOUSTON-tx','M',300000,33344455155, null);
    ('John','B','Smithu',123466789,'731-fOUNDREN-hOUSTON-tx','M',300000,33344455455, null);
    ('John','B','Smithj',127456789,'731-fOUNDREN-hOUSTON-tx','M',300000,33344455655, null);
    ('John','B','Smithg',123456389,'731-fOUNDREN-hOUSTON-tx','M',300000,33344455255, null);

-- Definir um gasto de 11% para o INSS a partir do salário do funcionário
SELECT Fname, Lname, Salary * 0.011 from employee;

-- Refinando o INSS para mostrar uma tabela bonita
SELECT Fname, Lname, Salary * 0,011 as INSS from employee;

-- Refinando ainda mais para mostrar a tabela e o valor arredondado dentro dela
SELECT Fname, Lname, Salary, round(Salary * 0.011, 2) as INSS from employee;

-- Definir um aumento de salario dos gerentes associados a um projeto X
SELECT concat(Fname, ' ', Lname) as Complete_name, Salary, round(Salary*1.1, 2) as increased_salary
    from employee e, works_on as w, project as p
    where (e.Ssn = w.Essn and w.Pno=p.Pnumber and p.Pname='ProductX');

