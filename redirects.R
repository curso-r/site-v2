library(xml2)
library(tidyverse)

urls_antigas <- read_xml("http://curso-r.netlify.com/sitemap.xml") %>%
  xml2::xml_children() %>% 
  xml2::xml_children() %>% 
  keep(~ str_detect(., "loc")) %>% 
  xml_text()

urls_novas <- read_xml("https://www.curso-r.com/sitemap.xml") %>%
  xml2::xml_children() %>% 
  xml2::xml_children() %>% 
  keep(~ str_detect(., "loc")) %>% 
  xml_text()

posts_novo <- urls_novas %>% str_subset("/blog/2")
posts_antigo <- urls_antigas %>% str_subset("/blog/2")

data.frame(
  posts_antigo = posts_antigo,
  posts_novo = posts_novo
) %>%
  write_delim("static/_redirects", delim = "\t", col_names = FALSE)





