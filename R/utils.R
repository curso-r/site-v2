`%>%` <- magrittr::`%>%`

#' Devolve a legenda para as figuras da Allison.
#'
#' @return
#' @export
#'
#' @examples
cap_alisson_horst <- function() {
  "Arte por Allison Horst. Procure por @allison_horst nas redes sociais para encontrá-la."
}

#'
criar_repositorio <- function(repo_nome, descricao) {
  res <- gh::gh(
    "POST /orgs/:org/repos", 
    org = "curso-r", 
    name = repo_nome, 
    description = descricao, 
    private = FALSE, 
    .token = usethis::github_token()
  )
  
  url <- res$html_url
  utils::browseURL(url)
  
  invisible(url)
  
}

#'
criar_repositorio_main <- function(curso_nome, curso_abrev) {
  
  repo_nome <- paste0("main-", curso_abrev)
  
  descricao <- glue::glue(
    "Repositório principal do curso {curso_nome}."
  )
  
  url <- criar_repositorio(
    repo_nome,
    descricao
  )
  
  invisible(url)
  
}


#'
criar_repositorio_turma <- function(curso_nome, curso_abrev, data) {
  
  if (curso_abrev == "intro-machine-learning") {
    curso_abrev <- "intro-ml"
  }
  
  data_formatada <- paste0(
    lubridate::year(data),
    stringr::str_pad(lubridate::month(data), 2, "left", "0")
  )
  
  repo_nome <- paste(data_formatada, curso_abrev, sep = "-")
  
  descricao <- paste(
    "Repositório da turma de",
    lubridate::month(data), 
    "de",
    lubridate::year(data),
    "do curso",
    paste0(curso_nome, ".")
  )
  
  url <- criar_repositorio(
    repo_nome,
    descricao
  )
  
  invisible(url)
  
}