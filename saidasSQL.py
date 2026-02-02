# Dicionário com palavras-chave SQL e suas descrições
descricoes_sql = {
    "SELECT": "recupera dados de uma ou mais tabelas",
    "PRIMARY KEY": "identificador único para cada registro de uma tabela",
    "FOREIGN KEY": "define relacionamento entre tabelas via chave",
    "WHERE": "filtra registros com base em condições específicas"
}
 
# Leitura da entrada
entrada = input().strip().upper()
 
# Imprime a descrição correspondente
print(descricoes_sql[entrada])

# Dicionário com operadores/funções SQL e suas descrições
descricoes_sql = {
    "COUNT": "conta o número de registros",
    "SUM": "soma os valores de uma coluna",
    "LIKE": "filtra registros que correspondem a um padrão",
    "BETWEEN": "filtra registros dentro de um intervalo"
}

# Leitura da entrada
entrada = input().strip().upper()

# Imprime a descrição correspondente
print(descricoes_sql[entrada])
