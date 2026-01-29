DROP DATABASE IF EXISTS company;
CREATE DATABASE company CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE company;

-- Criando as tabelas
-- tabela employee
CREATE TABLE employee(
    Fname       VARCHAR(15) NOT NULL,
    Minit       CHAR(1),
    Lname       VARCHAR(15) NOT NULL,
    Ssn         CHAR(9)     NOT NULL,
    Bdate       DATE,
    Address     VARCHAR(60),
    Sex         CHAR(1),
    Salary      DECIMAL(10,2),
    Super_ssn   CHAR(9),
    Dno         INT,
    PRIMARY KEY (Ssn)
);

-- tabela departament
CREATE TABLE departament(
    Dname           VARCHAR(15) NOT NULL,
    Dnumber         INT NOT NULL,
    Mgr_ssn         CHAR(9),
    Mgr_start_date  DATE,
    PRIMARY KEY (Dnumber),
    UNIQUE (Dname)
);

-- tabela dept_location
CREATE TABLE dept_location(
    Dnumber     INT NOT NULL,
    Dlocation   VARCHAR(20) NOT NULL,
    PRIMARY KEY(Dnumber, Dlocation),
    CONSTRAINT fk_dept_location_departament
        FOREIGN KEY (Dnumber) REFERENCES departament(Dnumber)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- tabela project
CREATE TABLE project(
    Pname       VARCHAR(20) NOT NULL,
    Pnumber     INT NOT NULL,
    Plocation   VARCHAR(15),
    Dnum        INT NOT NULL,
    PRIMARY KEY (Pnumber),
    UNIQUE (Pname),
    CONSTRAINT fk_project_departament
        FOREIGN KEY (Dnum) REFERENCES departament(Dnumber)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- tabela works_on
CREATE TABLE works_on(
    Essn    CHAR(9)     NOT NULL,
    Pno     INT         NOT NULL,
    Hours   DECIMAL(3,1) NOT NULL,
    PRIMARY KEY (Essn, Pno),
    CONSTRAINT fk_works_on_employee
        FOREIGN KEY (Essn) REFERENCES employee(Ssn)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_works_on_project
        FOREIGN KEY (Pno) REFERENCES project(Pnumber)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- tabela dependent
CREATE TABLE dependent(
    Essn            CHAR(9)     NOT NULL,
    Dependent_name  VARCHAR(15) NOT NULL,
    Sex             CHAR(1),
    Bdate           DATE,
    Relationship    VARCHAR(12),
    PRIMARY KEY (Essn, Dependent_name),
    CONSTRAINT fk_dependent_employee
        FOREIGN KEY (Essn) REFERENCES employee(Ssn)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Alterando tabela para colocar fk nova
ALTER TABLE employee
    ADD CONSTRAINT fk_employee_supervisor
    FOREIGN KEY (Super_ssn) REFERENCES employee (Ssn)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

-- modificar uma constraint
ALTER TABLE departament
    ADD CONSTRAINT fk_departament_manager
    FOREIGN KEY (Mgr_ssn) REFERENCES employee(Ssn)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_departament
    FOREIGN KEY (Dno) REFERENCES departament(Dnumber)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

-- persistencia de dados, colocando dados dentro da tabela employee
INSERT INTO employee (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno)
VALUES
('John','B','Smithy','123456289',NULL,'731-fOUNDREN-hOUSTON-tx','M',300000.00,NULL,NULL),
('Peter','B','Smithr','173456789',NULL,'731-fOUNDREN-hOUSTON-tx','M',300000.00,NULL,NULL),
('luck','B','Smithw','123453789',NULL,'731-fOUNDREN-hOUSTON-tx','M',300000.00,NULL,NULL),
('John','B','Smithq','123451789',NULL,'731-fOUNDREN-hOUSTON-tx','M',300000.00,NULL,NULL),
('John','B','Smitha','123446789',NULL,'731-fOUNDREN-hOUSTON-tx','M',300000.00,NULL,NULL),
('John','B','Smithu','123466789',NULL,'731-fOUNDREN-hOUSTON-tx','M',300000.00,NULL,NULL),
('John','B','Smithj','127456789',NULL,'731-fOUNDREN-hOUSTON-tx','M',300000.00,NULL,NULL),
('John','B','Smithg','123456389',NULL,'731-fOUNDREN-hOUSTON-tx','M',300000.00,NULL,NULL);

-- Definir gasto de 11% para o INSS a partir do salario do funcionario
SELECT Fname, Lname, Salary * 0.11 FROM employee;

-- Refinando o INSS
SELECT Fname, Lname, Salary * 0.11 AS INSS FROM employee;

-- Refinando ainda mais para mostrar nome na tabela e valor arredondado em 2 casas
SELECT Fname, Lname, Salary, ROUND(Salary * 0.11, 2) AS INSS FROM employee;

-- Definir um aumento de salário dos gerentes associados a um projeto X
SELECT CONCAT(Fname, ' ', Lname) AS Complete_name, Salary, ROUND(Salary*1.1, 2) AS increased_salary
FROM employee e, works_on w, project p
WHERE (e.Ssn = w.Essn AND w.Pno = p.Pnumber AND p.Pname = 'ProductX');

-- Ordenando de forma descendente a partir do numero do departamento
SELECT Fname, Lname, Dno FROM employee
ORDER BY Dno DESC;

USE company;

SELECT * FROM employee
ORDER BY Dno;

SELECT DISTINCT d.Dname, CONCAT(e.Fname, ' ', e.Lname) AS Manager, e.Address
FROM departament d
JOIN employee e ON e.Ssn = d.Mgr_ssn
ORDER BY d.Dname, e.Lname, e.Fname;

SELECT Dno, COUNT(*), AVG(Salary)
FROM employee
GROUP BY Dno;

SELECT * FROM employee e, departament d
WHERE e.Dno = d.Dnumber AND d.Dname = 'Research';

-- Agrupamento de registros
SELECT Dno, COUNT(*) AS Number_of_employee, ROUND(AVG(Salary),2) AS Salary_avg
FROM employee
GROUP BY Dno;

SELECT p.Pnumber, p.Pname, COUNT(*) 
FROM project p, works_on w
WHERE p.Pnumber = w.Pno
GROUP BY p.Pnumber, p.Pname
HAVING COUNT(*) > 2;

SELECT CONCAT(e.Fname, ' ', e.Lname) AS Full_name, e.Salary, d.Dname AS departament
FROM employee e
LEFT JOIN departament d ON e.Dno = d.Dnumber;

-- DESATIVE O SAFE MODE DO WORKBENCH:
-- 1. PREFERENCIAS -> SQL EDITOR -> OTHER -> SAFE UPDATES (desmarca e reinicia o programa)
UPDATE employee
SET Salary =
    CASE
        WHEN Dno = 5 THEN Salary + 2000
        WHEN Dno = 4 THEN Salary + 1500
        WHEN Dno = 1 THEN Salary + 3000
        ELSE Salary
    END;

SELECT CONCAT(Fname, ' ', Lname) AS Full_name, Salary, Dno FROM employee;

-- JOIN usando ON
SELECT * FROM employee
JOIN works_on ON Ssn = Essn;

SELECT * FROM employee, works_on
WHERE Ssn = Essn;

SELECT Fname, Lname, Address
FROM (employee JOIN departament ON Dno = Dnumber)
WHERE Dname = 'Research';

SELECT * FROM dept_location;
SELECT * FROM departament;

-- JOIN com ON e usando um atributo USING (quando dois dados são tidos em comum, usa-se o using as vezes)
SELECT Dname, Mgr_start_date AS StartDate, Dlocation AS Location
FROM departament
JOIN dept_location USING (Dnumber)
ORDER BY StartDate;

-- Cross join
SELECT * FROM employee
CROSS JOIN dependent;

-- INNER JOIN COM MAIS DE 2 TABELAS
-- Faz-se um inner join entre uma tabela e outra (criando uma resultante)
-- A resultante dessas tabelas são unidas novamente para criar uma resultante V2
SELECT CONCAT(e.Fname,' ', e.Lname) AS Full_name, e.Dno, p.Pname, w.Pno, p.Plocation
FROM employee e
INNER JOIN works_on w ON e.Ssn = w.Essn
INNER JOIN project p ON w.Pno = p.Pnumber
INNER JOIN departament d ON e.Dno = d.Dnumber
ORDER BY p.Pnumber;

-- Resultante com filtro de pesquisa para o nome do projeto
SELECT CONCAT(e.Fname,' ', e.Lname) AS Full_name, e.Dno AS DeptNumber, p.Pname AS ProjectName, w.Pno AS ProjectNumber, p.Plocation AS Location
FROM employee e
INNER JOIN works_on w ON e.Ssn = w.Essn
INNER JOIN project p ON w.Pno = p.Pnumber
WHERE p.Pname LIKE 'Project%'
ORDER BY p.Pnumber;

-- filtro de pesquisa para contador maior que 1 em cima da resultante definitiva dos INNER JOINS
SELECT d.Dnumber, d.Dname, CONCAT(m.Fname,' ', m.Lname) AS Manager, m.Salary, ROUND(m.Salary*1.05,2) AS bonus
FROM departament d
INNER JOIN dept_location dl USING (Dnumber)
INNER JOIN employee m ON m.Ssn = d.Mgr_ssn
GROUP BY d.Dnumber, d.Dname, Manager, m.Salary, bonus
HAVING COUNT(*) > 1;

