CREATE DATABASE IF NOT EXISTS dw_star_schema CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE dw_star_schema;


CREATE TABLE IF NOT EXISTS DimProfessor (
  ProfessorSK      BIGINT AUTO_INCREMENT PRIMARY KEY,
  ProfessorNK      VARCHAR(100) NOT NULL,  
  Nome             VARCHAR(200) NOT NULL,
  Titulacao        VARCHAR(100),
  RegimeTrabalho   VARCHAR(50),             
  Email            VARCHAR(200),
  InicioVigencia   DATE NOT NULL DEFAULT (CURRENT_DATE),
  FimVigencia      DATE NULL,
  FlagAtual        TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT UQ_DimProfessor_NK_SCD UNIQUE (ProfessorNK, InicioVigencia)
) ENGINE=InnoDB;

CREATE INDEX IX_DimProfessor_NK ON DimProfessor (ProfessorNK);

CREATE TABLE IF NOT EXISTS DimDisciplina (
  DisciplinaSK         BIGINT AUTO_INCREMENT PRIMARY KEY,
  CodigoDisciplina     VARCHAR(50) NOT NULL,
  NomeDisciplina       VARCHAR(200) NOT NULL,
  Creditos             INT,
  CargaHorariaPadrao   INT,
  AreaConhecimento     VARCHAR(200),

  CONSTRAINT UQ_DimDisciplina_Cod UNIQUE (CodigoDisciplina)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS DimCurso (
  CursoSK             BIGINT AUTO_INCREMENT PRIMARY KEY,
  CodigoCurso         VARCHAR(50) NOT NULL,
  NomeCurso           VARCHAR(200) NOT NULL,
  Nivel               VARCHAR(50),           
  ModalidadeAcademica VARCHAR(50),           
  UnidadeAcademica    VARCHAR(200),

  CONSTRAINT UQ_DimCurso_Cod UNIQUE (CodigoCurso)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS DimDepartamento (
  DepartamentoSK      BIGINT AUTO_INCREMENT PRIMARY KEY,
  CodigoDepartamento  VARCHAR(50) NOT NULL,
  NomeDepartamento    VARCHAR(200) NOT NULL,
  CentroInstituto     VARCHAR(200),
  Campus              VARCHAR(200),

  CONSTRAINT UQ_DimDepartamento_Cod UNIQUE (CodigoDepartamento)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS DimData (
  DataSK     INT        PRIMARY KEY,
  Data       DATE       NOT NULL,
  Dia        SMALLINT   NOT NULL,
  Mes        SMALLINT   NOT NULL,
  Ano        INT        NOT NULL,
  Semestre   SMALLINT   NOT NULL,
  NomeMes    VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE UNIQUE INDEX UX_DimData_Data ON DimData (Data);

CREATE TABLE IF NOT EXISTS FatoOfertaDisciplina (
  FatoID             BIGINT AUTO_INCREMENT PRIMARY KEY,

  ProfessorSK        BIGINT     NOT NULL,
  DisciplinaSK       BIGINT     NOT NULL,
  CursoSK            BIGINT     NOT NULL,
  DepartamentoSK     BIGINT     NOT NULL,
  DataOfertaSK       INT        NOT NULL,     

  CargaHorariaMinistrada DECIMAL(9,2) NULL,
  TurmasOfertadas        INT NULL,

  CONSTRAINT FK_Fato_Professor
    FOREIGN KEY (ProfessorSK)    REFERENCES DimProfessor (ProfessorSK)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT FK_Fato_Disciplina
    FOREIGN KEY (DisciplinaSK)   REFERENCES DimDisciplina (DisciplinaSK)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT FK_Fato_Curso
    FOREIGN KEY (CursoSK)        REFERENCES DimCurso (CursoSK)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT FK_Fato_Departamento
    FOREIGN KEY (DepartamentoSK) REFERENCES DimDepartamento (DepartamentoSK)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT FK_Fato_Data
    FOREIGN KEY (DataOfertaSK)   REFERENCES DimData (DataSK)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Índices úteis nas FKs
CREATE INDEX IX_Fato_Professor    ON FatoOfertaDisciplina (ProfessorSK);
CREATE INDEX IX_Fato_Disciplina   ON FatoOfertaDisciplina (DisciplinaSK);
CREATE INDEX IX_Fato_Curso        ON FatoOfertaDisciplina (CursoSK);
CREATE INDEX IX_Fato_Departamento ON FatoOfertaDisciplina (DepartamentoSK);
CREATE INDEX IX_Fato_Data         ON FatoOfertaDisciplina (DataOfertaSK);


WITH RECURSIVE seq AS (
  SELECT DATE('2018-01-01') AS d
  UNION ALL
  SELECT d + INTERVAL 1 DAY FROM seq WHERE d < DATE('2030-12-31')
)
INSERT INTO DimData (DataSK, Data, Dia, Mes, Ano, Semestre, NomeMes)
SELECT
  CAST(DATE_FORMAT(d, '%Y%m%d') AS SIGNED) AS DataSK,
  d                                         AS Data,
  DAY(d)                                    AS Dia,
  MONTH(d)                                  AS Mes,
  YEAR(d)                                   AS Ano,
  CASE WHEN MONTH(d) <= 6 THEN 1 ELSE 2 END AS Semestre,
  DATE_FORMAT(d, '%M')                      AS NomeMes
FROM seq
ON DUPLICATE KEY UPDATE DataSK = VALUES(DataSK);
