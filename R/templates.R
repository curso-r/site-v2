criar_novo_curso <- function() {
  
  pasta_temp <- tempdir()
  
  file.copy(
    paste0(system.file(package = "siteCursoR"), "/dev/criar_novo_curso.R"),
    paste0(pasta_temp, "/criar_novo_curso.R"),
  )
  
  rstudioapi::navigateToFile(
    paste0(pasta_temp, "/criar_novo_curso.R")
  )
}

formatar_imagem <- function(caminho_imagem, nome) {

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
      location = "-70-182",
      gravity = "center",
      color = "white",
      size = 36,
      font = "Roboto Condensed",
      weight = 500
    ) %>% 
    magick::image_write(path = caminho_imagem)
}

gerar_novo_curso <- function(nome, nome_abrev, imagem, banner, desc) {
  
  if (!stringr::str_detect(rstudioapi::getActiveProject(), "site-v2$")) {
    stop("Você precisa estar com o projeto 'site-v2' aberto!")
  }
  
  usethis::ui_todo("Criando novo id único...")
  planilha <- baixar_dados()
  tab <- readxl::read_excel(planilha, sheet = "catalogo-de-cursos")
  
  novo_id <- max(tab$id_unico) + 1
  nova_ordem <- max(tab$ordem) + 5
  usethis::ui_done("Id único criado.")
  
  caminho_imagem <- caminho_banner <- paste0(
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
    img = caminho_imagem,
    banner = caminho_banner,
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
  criar_template_novo_curso(novo_id, nome_abrev)
  usethis::ui_done("Template para página do curso gerado.")
  
  usethis::ui_done("Curso gerado com sucesso!")
  usethis::ui_info(
    "Configure o template do curso antes de abrir uma nova turma."
  )
  
}

criar_template_novo_curso <- function(novo_id, nome_abrev) {
  
  text <- readLines(
    paste0(system.file(package = "siteCursoR"), "/templates/novo_curso.Rmd")
  )
  
  nome_arquivo <- paste0("inst/templates/", nome_abrev, ".Rmd")
  
  text <- gsub("param_id", novo_id, text)
  writeLines(text, nome_arquivo, sep = "\n")
  
  rstudioapi::navigateToFile(nome_arquivo)
  
}

markdown_to_html <- function(text) {
  writeLines(text, "temp.md")
  markdown::markdownToHTML("temp.md", "temp.html", fragment.only = TRUE)
  res <- readLines("temp.html") %>% 
    paste(sep = "\n") %>% 
    shiny::HTML()
  file.remove(c("temp.html", "temp.md"))
  res
}

#' Title
#'
#' @param overwrite 
#' @param output_file 
#'
#' @return
#' @export
#'
#' @examples
abrir_nova_turma <- function(overwrite = FALSE, output_file = NULL) {
  
  cursos <- list.files(
    paste0(system.file(package = "siteCursoR"), "/templates/")
  )
  
  cursos <- cursos[cursos != "novo_curso.Rmd"] %>% 
    stringr::str_remove(".Rmd")
  
  curso_selecionado <- cursos[
    menu(choices = cursos, title = "Escolha um curso:")
    ]
  
  if (is.null(output_file)) {
    arquivo_md <- paste0("content/cursos/", curso_selecionado, ".md")
    arquivo_rmd <- paste0("content/cursos/", curso_selecionado, ".Rmd")
    if (file.exists(arquivo_md)) {
      stop(paste0("Arquivo '", arquivo_md, "' já existe e overwrite = FALSE."))
    }
  } else {
    arquivo_md <- paste0("content/cursos/", output_file, ".md")
    arquivo_rmd <- paste0("content/cursos/", output_file, ".Rmd")
    if (file.exists(arquivo_md)) {
      stop(paste0("Arquivo '", arquivo_md, "' já existe e overwrite = FALSE."))
    }
  }
  
  template <- system.file(
    paste0("templates/", curso_selecionado, ".Rmd"), 
    package = "siteCursoR"
  )
  
  file.copy(template, arquivo_rmd, overwrite = TRUE)
  
  rmarkdown::render(
    input = arquivo_rmd,
    output_format = rmarkdown::md_document(
      preserve_yaml = TRUE,
      variant = "commonmark"
    ),
    quiet = TRUE
  )
  
  file.remove(arquivo_rmd)
  
  usethis::ui_done("Página criada com sucesso!")
  
}