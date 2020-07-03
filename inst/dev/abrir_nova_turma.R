
# -------------------------------------------------------------------------
# Esse é um arquivo TEMPORÁRIO
# Ele será automaticamente destruído ao fim do processo
# -------------------------------------------------------------------------

# Criando um novo curso ---------------------------------------------------


# Passo 1: Informações da turma

siteCursoR:::abrir_turma(
  modelo = c("curso", "workshop"),
  data_inicio = "dd/mm/aaaa",
  data_fim = "dd/mm/aaaa",
  horario = c("19h00 às 22h00", "9h00 às 13h00"),
  valor = 500,
  vagas = 50,
  carga_horaria = 18, 
  num_aulas = 6,
  local = c("Online", "Endereço"),
  professores = c("Athos Damiani", "William Amorim"), # Vetor com dois nomes/sobrenomes
  classroom = "",
  #opcional
  valor_aluguel = 0,
  valor_monitoria = 0,
  valor_professor = 0,
  valor_coffee = 0,
  valor_outras_despesas = 0,
  bolsas = 2,
  obs = ""
)

# Passo 2: Editar template da página do curso