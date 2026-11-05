-- ============================================================
-- SEQUÊNCIA PARA GERAÇÃO DA MATRÍCULA
-- ============================================================
-- Gera números sequenciais:
-- 1, 2, 3, 4...
CREATE SEQUENCE seq_matricula_aluno
 START WITH 1
 INCREMENT BY 1;
-- ============================================================
-- FUNÇÃO PARA GERAÇÃO DA MATRÍCULA
-- ============================================================
-- A função gera automaticamente uma matrícula no formato:
-- AL000001
-- AL000002
-- AL000003
CREATE OR REPLACE FUNCTION gerar_matricula_aluno()
RETURNS VARCHAR
AS $$
BEGIN
 RETURN
 'AL' ||
 LPAD(
 nextval('seq_matricula_aluno')::TEXT,
 6,
 '0'
 );
END;
$$ LANGUAGE plpgsql;
-- ============================================================
-- TABELA ALUNO
-- ============================================================
CREATE TABLE aluno (
 id_aluno INTEGER GENERATED ALWAYS AS IDENTITY,
 -- A matrícula será gerada automaticamente
 -- caso não seja informada no INSERT.
 matricula VARCHAR(20)
 NOT NULL
 DEFAULT gerar_matricula_aluno(),
 nome VARCHAR(150) NOT NULL,
 data_nascimento DATE NOT NULL,
 email VARCHAR(150) NOT NULL,
 telefone VARCHAR(20) NOT NULL,
 CONSTRAINT pk_aluno
 PRIMARY KEY (id_aluno),
 CONSTRAINT uq_aluno_matricula
 UNIQUE (matricula)
);
-- ============================================================
-- TABELA LIVRO
-- ============================================================
CREATE TABLE livro (
 id_livro INTEGER GENERATED ALWAYS AS IDENTITY,
 titulo VARCHAR(200) NOT NULL,
 autor VARCHAR(150) NOT NULL,
 editora VARCHAR(150) NOT NULL,
 ano_publicacao INTEGER NOT NULL,
 isbn VARCHAR(20) NOT NULL,
 quantidade_total INTEGER NOT NULL,
 quantidade_disponivel INTEGER NOT NULL,
 CONSTRAINT pk_livro
 PRIMARY KEY (id_livro),
 CONSTRAINT uq_livro_isbn
 UNIQUE (isbn),
 CONSTRAINT ck_livro_quantidade_total
 CHECK (quantidade_total > 0),
 CONSTRAINT ck_livro_quantidade_disponivel
 CHECK (
 quantidade_disponivel >= 0
 AND quantidade_disponivel <= quantidade_total
 )
);
-- ============================================================
-- TABELA EMPRESTIMO
-- ============================================================
CREATE TABLE emprestimo (
 id_emprestimo INTEGER GENERATED ALWAYS AS IDENTITY,
 id_aluno INTEGER NOT NULL,
 data_emprestimo DATE NOT NULL DEFAULT CURRENT_DATE,
 data_prevista_devolucao DATE NOT NULL,
 data_devolucao DATE,
 CONSTRAINT pk_emprestimo
PRIMARY KEY (id_emprestimo),
 CONSTRAINT fk_emprestimo_aluno
 FOREIGN KEY (id_aluno)
 REFERENCES aluno (id_aluno),
 CONSTRAINT ck_emprestimo_data_prevista
 CHECK (
 data_prevista_devolucao >= data_emprestimo
 ),
 CONSTRAINT ck_emprestimo_data_devolucao
 CHECK (
 data_devolucao IS NULL
 OR data_devolucao >= data_emprestimo
 )
);
-- ============================================================
-- TABELA ITEM_EMPRESTIMO
-- ============================================================
CREATE TABLE item_emprestimo (
 id_item_emprestimo INTEGER GENERATED ALWAYS AS IDENTITY,
 id_emprestimo INTEGER NOT NULL,
 id_livro INTEGER NOT NULL,
 CONSTRAINT pk_item_emprestimo
 PRIMARY KEY (id_item_emprestimo),
 CONSTRAINT fk_item_emprestimo_emprestimo
 FOREIGN KEY (id_emprestimo)
 REFERENCES emprestimo (id_emprestimo),
 CONSTRAINT fk_item_emprestimo_livro
 FOREIGN KEY (id_livro)
 REFERENCES livro (id_livro),
 CONSTRAINT uq_item_emprestimo_livro
 UNIQUE (id_emprestimo, id_livro)
);