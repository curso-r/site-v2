criar_classroom <- function(curso_nome, data_inicio) {
  
  options(
    googleAuthR.client_id = Sys.getenv("GOOGLE_AUTH_R_CLIENT_ID"),
    googleAuthR.client_secret = Sys.getenv("GOOGLE_AUTH_R_CLIENT_SECRET")
  )
  
  data_inicio <- lubridate::dmy(data_inicio)
  
  secao <- paste(
    "Turma de",
    tolower(
      lubridate::month(
        data_inicio, 
        label = TRUE, 
        abbr = FALSE,
        locale = "pt_BR.UTF-8"
      )
    ),
    "de",
    lubridate::year(data_inicio)
  )
  
  googleAuthR::gar_auth(
    scopes = c(
      "https://www.googleapis.com/auth/classroom.courses",
      "https://www.googleapis.com/auth/classroom.rosters"
    )
  )
  
  novo_curso <- googleclassroom::gc_course(
    name = curso_nome,
    ownerId = "me",
    courseState = "ACTIVE",
    section = secao
  )
  
  
  googleclassroom::gc_courses_create(novo_curso)
  
  
}

convidar_professores_classroom <- function(info_curso, professores) {
  
  caminho_planilha <- baixar_dados(force = TRUE)
  
  emails <- readxl::read_excel(caminho_planilha, sheet = "professores") %>% 
    dplyr::filter(nome %in% professores) %>% 
    dplyr::pull(email)
  
  convites <- purrr::map(
    emails,
    ~ googleclassroom::gc_invitation(
      courseId = info_curso$id,
      role = "TEACHER",
      userId = .x
    )
  )
  
  res <- purrr::map(
    convites,
    purrr::possibly(
      googleclassroom::gc_invitations_create,
      otherwise = NA
    )
  )
  
  purrr::walk2(
    res,
    emails,
    ~ if (is.na(.x[1])) usethis::ui_info(paste(
      "Convite para", .y, "não enviado!"
    ))
  )
  
}