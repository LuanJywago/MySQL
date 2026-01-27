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

-- Ordenando de forma descendente partir do numero do departamento
SELECT Fname, Lname, Dno from employee
ORDER BY(Dno) DESC;

-- Ordenando a partir do numero do departamento
use company_constraints;
select * from employee
order by Dno;

-- Nome do departamento, nome do gerente do departamento e endereço
select distinct d.Dname, concat(e.Fname, " ", e.Lname) as Manager, Address -- distinct usado para evitar informação duplicada
    from departament as d, employee as e, works_on as w, project as p
    where (d.Dnumber = e.Dno and e.Ssn = d.Mgr_ssn and w.Pno = p.Pnumber;)
    order by d.Dname, e.Lname, e.Fname;

-- Agrupamento de registros (SALARIO MÉDIO PELO Dno)
SELECT Dno, Count(*) AVG(Salary)
from employee
Group by Dno;

-- Agrupamento com filtro de pesquisa
Select * from employee, departament
where Dno = Dnumber and Dname = "Research";

Select Dno, count(*) as Number_of_employee, round(avg(Salary),2) as Dalary_avg
from employee
GROUP BY Dno;

-- Usando o HAVING para criar a estrutura se COUNT > 2
SELECT Pnumber, Pname, COUNT(*)
FROM PROJECT, works_on
WHERE Pnumber = Pno
GROUP BY Pnumber, Pname
HAVING COUNT (*) > 2;


-- DESATIVE O SAFE MODE DO WORKBENCH:
-- 1. PREFERENCIAS -> SQL EDITOR -> OTHER -> SAFE UPDATES (desmarca e reinicia o programa)
select concat(Fname, ' ', Lname) as Full_name, Salary, departament from employee;
update employee
set salary =
    case
        when Dno = 5 then Salary+ 2000
        when Dno = 4 then Salary+ 1500
        when Dno = 1 then Salary+ 3000
        else Salary + 0
    end;
-- Vizualizar as tabelas atualizadas novamente
select concat(Fname, ' ', Lname) as Full_name, Salary, departament from employee;

--JOIN STATEMENTS
-- JOIN
select * from employee -- sem atributo, ele mescla os atributos da lista entre as duas
JOIN works_on;

select * from employee, works_on
where Ssn = Essn -- vai ter a mesma coisa, mas menos intuitivo e pode dar problema de match entre as tabelas

-- JOIN ON --> INNER JOIN  
Select Fname, Lname, Address
from (employee join departament on Dno = Dnumber) -- retorna uma tabela como resultado de uma tabela para ser recuperada
where Dname = "Research" -- recupera as informações mas aplica um filtro em cima delas
-- acresce esse fator de filtro para pesquisar todas as tabelas, mas retornar apenas o dado filtrado entre essas tabelas

select * from employee -- não especificou atributo, logo, vai vir tudo
join works_on
on Ssn = Essn -- colocou uma forma de junção entre elas

-- para achar os dados se causar dificuldades
select * from dept_location; -- Dlocation e Dnumber
select * from departament; -- Dname, Dept_create_date

Select Dname, Dept_create_date, as StartDate, Dlocation as Location 
from departament join dept_location
USING (Dnumber) -- atributos em comuns nas tabelas. Se der prego, use ON mesmo
ORDER BY StartDate; -- ordena em forma ascendente

-- CROSS JOIN (LIVRO: LEARNING SQL)
-- Produto cartesiano
-- Sempre determinar o tipo de JOIN

select * from employee 
cross join dependent; -- Mostra todos os dependentes existentes dentro do banco de dados


-- JOINS COM 3 TABELAS --
--Project, works_on e employee (ordem das tabelas não necessariamente importa)
select concat(Fname,' ', Lname) as Full_name, Dno, Pname, Pno, Plocation from employee 
    inner join works_on on Ssn = Essn
    inner join project on Pno = Pnumber
    inner join departament on Dno = Dnumber
    order by Pnumber;

select concat(Fname,' ', Lname) as Full_name, Dno as DeptNumber, Pname as ProjectName, Pno as ProjectNumber, Plocation as Location from employee 
    inner join works_on on Ssn = Essn
    inner join project on Pno = Pnumber
    where Pname like 'Project%'
    order by Pnumber;

-- departament, dept_location e employee
SELECT Dno, Dname, concat(Fname,' ', Lname) as Manager, Salary, round(Salary*1.05) as bonus from departament
    inner join dept_location using(Dnumber)
    inner join employee on Ssn = Mrg_ssn
    group by Dnumber -- agrupamento
    having count(*)>1; -- condição em cima do agrupamento (grupo)