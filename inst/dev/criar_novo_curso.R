
# -------------------------------------------------------------------------
# Esse é um arquivo TEMPORÁRIO
# Ele será automaticamente destruído ao fim do processo
# -------------------------------------------------------------------------

# Criando um novo curso 

# Passo 1: Informações do curso -------------------------------------------

siteCursoR:::gerar_novo_curso(
  nome = "", # Ex: R para Ciência de Dados I
  nome_abrev = "", # Ex: r4ds-1 (sem espaços ou pontos, aparecerá na URL)
  imagem = "", # Caminho ou URL para a imagem do curso
  desc = "", # Breve descrição do curso. Uma frase.
  #opcional
  ordem = NULL # Por padrão, é colocado no final. 
)

# Obs 
# Rodar siteCursoR:::ver_ordem_cursos() para ver lista com as ordens.

# Passo 2: Editar template da página do curso -----------------------------


