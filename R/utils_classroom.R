criar_classroom <- function(curso_nome, data_inicio) {
  
  options(
    googleAuthR.client_id = Sys.getenv("GOOGLE_AUTH_R_CLIENT_ID"),
    googleAuthR.client_secret = Sys.getenv("GOOGLE_AUTH_R_CLIENT_SECRET")
  )
  
  secao <- paste(
    lubridate::month(data_inicio),
    "de",
    lubridate::year(data_inicio)
  )
  
  googleAuthR::gar_auth(
    scopes = "https://www.googleapis.com/auth/classroom.courses"
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
  
  caminho_planilha <- baixar_dados()
  
  emails <- readxl::read_excel(caminho_planilha, sheet = "professores") %>% 
    dplyr::filter(nome %in% professores) %>% 
    dplyr::pull(email)
  
  convites <- purr::map(
    emails,
    ~ googleclassroom::gc_invitation(
      id = info_curso$id,
      role = "TEACHER",
      userId = .x
    )
  )
  
  purrr::walk(
    convites,
    googleclassroom::gc_invitations_create
  )
    
}