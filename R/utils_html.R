colar_html <- function(...) {
  paste(..., sep = "\n")
}

#' Cria um header h3
#'
#' @param titulo 
#'
#' @return
#' @export
#'
#' @examples
criar_section_header <- function(titulo) {
  glue::glue(
    colar_html(
      '<header class="section-header">',
      ' <h4>{{titulo}}</h4>',
      '</header>'
    ),
    .open = "{{",
    .close = "}}"
  ) %>% 
    shiny::HTML()
}


#' Title
#'
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
criar_lista_voce_saira <- function(id) {
  
  bullet <- "<span style = 'font-size: 10px'>&#9989;</span>"
  
  lista <- pegar_info_curso(id, "voce_saira") %>% 
    stringr::str_split("\\|", simplify = TRUE) %>% 
    as.character()
  
  glue::glue(paste(bullet, lista, collapse = "\n\n"))
  
}

criar_topicos_ementa <- function(lista) {
  
  bullet <- "&#128204"
  
  topico <- paste0("<p>", bullet, " <b>", lista[1], "</b></p>")
  
  sub_topicos <- paste0(
      "<li>",
      lista[2:length(lista)],
      "</li>",
      collapse = "\n"
  )
  
  colar_html(
    topico,
    "<ul>",
    sub_topicos,
    "</ul>\n"
  )
  
}


#' Title
#'
#' @param stickers 
#'
#' @return
#' @export
#'
#' @examples
criar_lista_stickers <- function(stickers) {
  
  tab <- readxl::read_excel(system.file("pacotes.xlsx", package = "siteCursoR")) %>% 
    dplyr::filter(pacote %in% stickers)
  
  links <- tab$link
  pacotes <- tab$pacote
  frases <- tab$frase
    
  glue::glue(
    '<div class="tooltip-wrap">',
    '<img src = "/img/cursos/hex/{{pacotes}}.png" width = "72px" height = "82px">',
    '<div class="tooltip-content">',
    '<a href = "{{links}}" target = "_blank">{{pacotes}}</a>',
    '<p>{{frases}}</p>',
    '</div>',
    '</div>',
    .open = "{{",
    .close = "}}"
  ) %>% 
    shiny::HTML()
  
}

#' Title
#'
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
criar_ementa <- function(id) {
  
  ementa <- pegar_info_curso(id, "ementa")
  
  ementa <- ementa %>% 
    stringr::str_split("\\|\\|") %>% 
    unlist() %>% 
    purrr::map(~unlist(stringr::str_split(.x, "\\|"))) %>% purrr::map(cat, sep = "\n- ")
    purrr::map_chr(~criar_topicos_ementa(.x)) %>% 
    paste0(collapse = "")
  
  stickers <- 
  
  glue::glue(
    colar_html(
      '<div class="row">',
      '<div class="column-esq">',
      '{{ementa}}',
      '</div>',
      '<div class="column-dir">',
      '<br><br><br>',
      '<div class="row justify-content-center">',
      '{{stickers}}',
      '</div>',
      '</div>',
      '</div>'
    ),
    .open = "{{",
    .close = "}}"
  )
  
}