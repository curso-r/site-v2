colar_html <- function(...) {
  paste(..., sep = "\n")
}

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

markdown_to_html <- function(text) {
  writeLines(text, "temp.md")
  markdown::markdownToHTML("temp.md", "temp.html", fragment.only = TRUE)
  res <- readLines("temp.html") %>% 
    paste(sep = "\n") %>% 
    shiny::HTML()
  file.remove(c("temp.html", "temp.md"))
  res
}

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

criar_lista_stickers <- function(stickers) {
  
  tab <- readxl::read_excel(
    system.file("pacotes.xlsx", package = "siteCursoR")
  ) %>% 
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
    '</div></div>',
    .open = "{{",
    .close = "}}"
  ) %>% 
    shiny::HTML()
  
}

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

adicionar_professores <- function(id) {
  
  prof <- pegar_professores_turma(id)
  
  caminho_planilha <- baixar_dados()
  data_professores <- readxl::read_excel(caminho_planilha, sheet = "professores") %>% 
    dplyr::filter(nome %in% prof)

  nomes <- data_professores$nome
  nm_img <- data_professores$nm_img
  url_github <- data_professores$url_github
  url_twitter <- data_professores$url_twitter
  url_linkedin <- data_professores$url_linkedin
  desc <- data_professores$desc
  
  txt <- glue::glue(
    '<div class="tooltip-wrap2" align="center" style="margin-right: 50px; margin-left: 50px;">',
    '<img src="/img/equipe/{{nm_img}}" width = "150px" height = "150px" style="border-radius: 50%;">',
    '<div class="tooltip-content"><p>{{desc}}</p></div><br/>',
    '<span style="font-weight: bold; text-transform: uppercase; font-size: 18px;">{{nomes}}</span><br/>',
    '<a href="{{url_twitter}}" class="twitter" target="_blank"><i class="fa fa-twitter"></i></a>&nbsp;&nbsp;',
    '<a href="{{url_github}}" class="github" target="_blank"><i class="fa fa-github"></i></a>&nbsp;&nbsp;',
    '<a href="{{url_linkedin}}" class="linkedin" target="_blank"><i class="fa fa-linkedin"></i></a>',
    '</div>',
    .open = "{{", .close = "}}"
  ) %>% 
    paste(collapse = "&nbsp;&nbsp;")
  
  glue::glue("<div class='row justify-content-center'>{{txt}}</div>", .open = "{{", .close = "}}")
  
}