#' Cria um novo curso
#'
#' @return
#' @export
#'
#' @examples
criar_novo_curso <- function() {
  
  pasta_temp <- tempdir()
  arq_temp <- paste0(pasta_temp, "/criar_novo_curso.R")
  
  file.copy("inst/dev/criar_novo_curso.R", arq_temp)
  
  rstudioapi::navigateToFile(arq_temp)
  
}

gerar_novo_curso <- function(nome, nome_abrev, imagem, banner, desc, 
                             ordem = NULL) {
  
  if (!stringr::str_detect(rstudioapi::getActiveProject(), "site-v2$")) {
    stop("Você precisa estar com o projeto 'site-v2' aberto!")
  }
  
  usethis::ui_todo("Criando novo id único...")
  planilha <- baixar_dados()
  tab <- readxl::read_excel(planilha, sheet = "catalogo-de-cursos")
  
  novo_id <- max(tab$id_unico) + 1
  
  if (is.null(ordem)) {
    nova_ordem <- max(tab$ordem) + 5
  } else {
    nova_ordem <- ordem
  }
  
  usethis::ui_done("Id único criado.")
  
  caminho_imagem <- paste0(
    "static/img/cursos/",
    nome_abrev,
    ".",
    fs::path_ext(imagem)
  )
  
  caminho_banner <- paste0(
    "static/img/cursos/",
    nome_abrev,
    "-banner.",
    fs::path_ext(imagem)
  )
  
  if (file.exists(imagem)) {
    
    usethis::ui_todo("Copiando imagem para pasta 'static/img/cursos/'...")
    file.copy(
      imagem,
      c(caminho_imagem, caminho_banner)
    )
    usethis::ui_done("Imagem copiada para pasta 'static/img/cursos/'.")
    
    usethis::ui_todo("Criando banner...")
    usethis::ui_done("Banner criado.")
    
  } else {
    
    usethis::ui_todo("Fazendo download da imagem...")
    download.file(imagem, destfile = caminho_imagem)
    usethis::ui_done("Download da imagem realizado com sucesso.")
    
    usethis::ui_todo("Criando banner...")
    file.copy(
      caminho_imagem,
      caminho_banner,
      overwrite = TRUE
    )
    usethis::ui_done("Banner criado.")
    
  }
  
  usethis::ui_todo("Formatando imagem...")
  formatar_imagem(caminho_imagem, nome)
  usethis::ui_done("Imagem formatada.")
  
  usethis::ui_todo("Inserindo curso no catálogo...")
  ss_id <- "1jACV67tPXktUp1rmbAurVRxzxnrhSwzBZgikwNTH8gE"
  
  novo_curso <- data.frame(
    id_unico = novo_id,
    title = nome,
    abrev = nome_abrev,
    img = stringr::str_remove(caminho_imagem, "^static/"),
    banner = stringr::str_remove(caminho_banner, "^static/"),
    desc = desc,
    ordem = nova_ordem
  )
  
  googlesheets4::sheet_append(
    ss = googledrive::as_id(ss_id),
    data = novo_curso,
    sheet = "catalogo-de-cursos"
  )
  usethis::ui_done("Curso inserido no catálogo.")
  
  usethis::ui_todo("Gerando template para página do curso...")
  
  novo_template <- paste0("inst/templates/", nome_abrev, ".Rmd")
  file.copy(
    from = "inst/templates/novo_curso.Rmd",
    to = novo_template
  )
  rstudioapi::navigateToFile(novo_template)
  
  usethis::ui_done("Template para página do curso gerado.")
  
  usethis::ui_done("Curso gerado com sucesso!")
  usethis::ui_info(
    "Configure o template do curso antes de abrir uma nova turma."
  )
  
}

formatar_imagem <- function(caminho_imagem, nome) {
  
  nome <- stringr::str_wrap(nome, width = 21)
  
  imagem <- magick::image_read(caminho_imagem)
  
  imagem %>%
    magick::image_resize(
      magick::geometry_size_pixels(
        width = 500, 
        height = 500, 
        preserve_aspect = FALSE
      )
    ) %>% 
    magick::image_annotate(
      text = nome,
      location = "+25-182",
      gravity = "West",
      color = "white",
      size = 42,
      font = "Roboto Condensed",
      weight = 550
    ) %>% 
    magick::image_write(path = caminho_imagem)
}

imputar_id_no_template <- function(arquivo, id_unico) {
  text <- readLines(arquivo)
  text <- gsub("param_id", id_unico, text)
  writeLines(text, arquivo, sep = "\n")
}

#' Abre uma nova turma
#'
#' @return
#' @export
#'
#' @examples
abrir_nova_turma <- function() {
  
  pasta_temp <- tempdir()
  arq_temp <- paste0(pasta_temp, "/abrir_nova_turma.R")
  
  file.copy("inst/dev/abrir_nova_turma.R", arq_temp)
  
  rstudioapi::navigateToFile(arq_temp)
}

abrir_turma <- function(modelo, data_inicio, data_fim, horario,
                             valor, vagas, carga_horaria, num_aulas,
                             local, professores,
                             valor_aluguel = 0, valor_monitoria = 0,
                             valor_professor = 0, valor_coffee = 0,
                             valor_outras_despesas = 0, bolsas = 2,
                             obs = "") {
  
  cursos <- list.files("inst/templates/")
  
  cursos <- cursos[!cursos %in% c("novo_curso.Rmd", "metadados.Rmd")] %>% 
    stringr::str_remove(".Rmd")
  
  curso_selecionado <- cursos[
    menu(choices = cursos, title = "Escolha um curso:")
    ]
  
  usethis::ui_todo("Criando id da turma...")
  planilha <- baixar_dados(force = TRUE)
  tab_turmas <- readxl::read_excel(planilha, sheet = "cursos")
  id_turma <- max(tab_turmas$curso_id) + 1
  usethis::ui_done("Id da turma criado.")
  
  curso_nome <- pegar_id_unico() %>% 
    dplyr::filter(abrev == curso_selecionado) %>% 
    dplyr::pull(title)
  
  info_classroom <- criar_classroom(
    curso_nome, 
    data_inicio[1]
  )
  
  convidar_professores_classroom(
    info_classroom,
    professores
  )
  
  nova_turma <- tibble::tibble(
    curso_id = id_turma,
    curso = curso_nome,
    modelo = modelo[1],
    data_inicio = as.character(data_inicio[1]),
    data_fim = as.character(data_fim[1]),
    horario = horario[1],
    valor = valor[1]*100,
    vagas = vagas[1],
    carga_horaria = carga_horaria[1],
    num_aulas = num_aulas[1],
    valor_aluguel = valor_aluguel[1],
    valor_monitoria = valor_monitoria[1],
    valor_professor = valor_professor[1],
    valor_coffee = valor_coffee[1],
    valor_outras_despesas = valor_outras_despesas[1],
    bolsas = bolsas[1],
    obs = obs[1],
    local = local[1],
    professores = paste(professores[1:2], collapse = ", "),
    classroom = info_classroom$enrollmentCode,
    classroom_id = info_classroom$id
  )
  
  usethis::ui_todo("Inserindo turma no catálogo...")
  ss_id <- "1jACV67tPXktUp1rmbAurVRxzxnrhSwzBZgikwNTH8gE"
  
  googlesheets4::sheet_append(
    ss = googledrive::as_id(ss_id),
    data = nova_turma,
    sheet = "cursos"
  )
  usethis::ui_done("Turma inserida no catálogo.")
  
  usethis::ui_todo("Gerando/atualizando página do curso...")
  gerar_pagina_curso(curso_selecionado)
  usethis::ui_done("Página do curso gerada/atualizada.")
  
}

gerar_pagina_curso <- function(curso_selecionado) {
  
  arquivo_rmd <- paste0("content/cursos/", curso_selecionado, ".Rmd")
  
  if (file.exists(arquivo_rmd)) {
    res <- usethis::ui_yeah(
      paste0("Arquivo '", arquivo_rmd, "' será sobrescrito. Deseja continuar?")
    )
    if (!res) {
      stop(paste0("Processo interrompido pelo usuário."))
    }
  }
  
  template <- paste0("inst/templates/", curso_selecionado, ".Rmd")
  metadados <- paste0("inst/templates/metadados.Rmd")
  
  file.copy(metadados, arquivo_rmd, overwrite = TRUE)
  
  id_unico <- pegar_id_unico(nome_abrev = curso_selecionado, force = TRUE)
  imputar_id_no_template(arquivo_rmd, id_unico)
  
  rmarkdown::render(
    input = arquivo_rmd,
    output_format = rmarkdown::md_document(
      # variant = "markdown_phpextra",
      preserve_yaml = TRUE,
      ext = ".Rmd"
    ),
    quiet = TRUE
  )
  
  pagina <- readLines(template)
  write(pagina, file = arquivo_rmd, append = TRUE, sep = "\n")
  
  rstudioapi::navigateToFile(arquivo_rmd)
  
}