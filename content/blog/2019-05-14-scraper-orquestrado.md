---
title: "Web Scraping Orquestrado"
date: "2019-05-14"
tags: ["web-scraping"]
categories: ["tutoriais", "r"]
banner: "img/banners/kuber.jpg"
author: ["Caio"]
summary: "Uma introdução ao pacote Kuber: como usar o kubernetes e o Google
Cloud Platform para fazer um scraper que roda na velocidade da luz."
draft: false
---

O objetivo principal do pacote [Kuber](https://github.com/curso-r/kuber) é
ajudar com computações massivamente paralelas. Ele usa o kubernetes e o 
docker de modo a criar um contêiner que automaticamente executa tarefas em
paralelo via expansão. Se você já usa o Google Cloud Platform, o Kuber
também consegue automaticamente criar clusters, executar computações e
gerenciar o seu progresso com o Google cloud SDK.

Se você nunca ouviu falar sobre orquestração de contêineres, armazenamento
persistente na nuvem ou computação paralela, pode ser que esse tutorial
pareça avançado demais. Você não precisa ser nenhum especialista nesses
assuntos, mas ajuda pelo menos saber o que significam esses termos.

Esse tutorial vai te ajudar a criar a sua primeira tarefa do Kuber. Antes de
começar, certifique-se de que você instalou todos os requisitos corretamente
com a vignette
["Getting started"](https://curso-r.github.io/kuber/articles/getting_started.html)

## A tarefa em si

A principal vantagem do Kuber em relação a outros pacotes de paralelização
(como Parallel ou Future/Furrr) é que ele automaticamente cria um cluster de
computadores que executa a sua tarefa via orquestração de contêineres. Isso
pode ser muito útil para web scraping, por exemplo, porque (1) cada máquina
tem um IP diferente, (2) salvar os HTMLs raspados é fácil com o Google Cloud
Storage e (3) o processo pode ser facilmente ativado/desativado a qualquer
momento.

Neste tutorial a função a ser paralelizada é a seguinte:

```r
# Scrapear um vetor de caracteres de URLs
scrape_urls <- function(urls) {

  # Criar um diretório
  dir <- fs::dir_create("scraped")

  # Iterar nos URLs
  paths <- c()
  for (url in urls) {
    path <- paste0(dir, "/", stringr::str_remove_all(url, "[^a-z]"), ".html")
    paths <- append(paths, path)
    
    httr::GET(url, httr::write_disk(path, overwrite = TRUE))
  }

  return(paths)
}
```

Em suma, essa função recebe um vetor de URLs, os raspa e salva os HTMLs 
resultantes em um diretório local.

## Criando o cluster

Agora para o Kuber. Se tudo estiver instalado corretamente, você deveria ser
capaz de criar um cluster simples com o seguinte comando:

```r
library(kuber)

kub_create_cluster("toy-cluster", machine_type = "f1-micro")
#> ✔  Creating cluster
```

Vá para o
[Kubernetes console](https://console.cloud.google.com/kubernetes/list) para
ver se tudo funcionou corretamente. Não se preocupe se você receber um monte
de alertas, a maioria deles é referente à versão do SDK.

## Criando a tarefa

A função mais importante do Kuber provavelmente é a próxima. Ela cria um
diretório na sua máquina local que descreve a computação paralela e seus
cluster, pacote, imagem e conta de serviço. Para executar o comando abaixo,
apenas `toy-key.json` (a chave da conta de serviço baixada na vignette
"Getting started") já precisa existir no caminho indicado; o resto é todo
criado para você.

```r
kub_create_task("~/toy-dir", "toy-cluster", "toy-bucket", "toy-image", "~/toy-key.json")
#> ✔  Fetching cluster information
#> ✔  Fetching bucket information
#> ✔  Creating bucket
#> ●  Edit `~/toy-dir/exec.R`
#> ●  Create `~/toy-dir/list.rds` with usable parameters
#> ●  Run `kub_push_task("~/toy-dir")`
```

## Editando o exec.R e o list.rds

O diretório criado por `kub_create_task()` tem alguns arquivos que são 
explorados em detalhe na documentação da própria função, mas os dois mais
importantes são `exec.R` e `list.rds`. O primeiro contém o arquivo R a ser
executado pela imagem docker, enquanto o segundo tem todos os objetos que
cada máquina precisa para rodar o seu próprio `exec.R`.

Começando pelo `exec.R`, o arquivo já está populado com um exemplo simples:

```
#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

# Arguments
idx <- as.numeric(args[1])
bucket <- as.character(args[2])

# Use this function to save your results
save_path <- function(path) {
  system(paste0("gsutil cp -r ", file_, " gs://", bucket, "/", gsub("/.+", "", file_)))
  do.call(file.remove, list(list.files(path, full.names = TRUE)))
  return(path)
}

# Get object passed in list[[idx]]
obj <- readRDS("list.rds")[[idx]]

###########################
## INSERT YOUR CODE HERE ##
###########################
```

Como você pode ver, é um Rscript que recebe dois argumentos: um índice e o
nome de um bucket GCS. O código em seguida descreve uma função a ser usada
quando salvando os resultados; ela envia o arquivo/diretório no `path` para
o bucket especificado e então o deleta do disco da máquina. Finalmente, o
script lê `list.rds` e seleciona o objeto guardado no índice `idx`.

Agora é hora de adicionar `scrape_urls()` para o arquivo. Não há muitas
mudanças na função em si, apenas em como os arquivos resultantes são 
gerenciados. Aqui está a versão final do `exec.R`:

```
#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

# Arguments
idx <- as.numeric(args[1])
bucket <- as.character(args[2])

# Use this function to save your results
save_path <- function(path) {
  system(paste0("gsutil cp -r ", file_, " gs://", bucket, "/", gsub("/.+", "", file_)))
  do.call(file.remove, list(list.files(path, full.names = TRUE)))
  return(path)
}

# Get object passed in list[[idx]]
obj <- readRDS("list.rds")[[idx]]

# Scrapear um vetor de caracteres de URLs
scrape_urls <- function(urls) {

  # Criar um diretório
  dir <- fs::dir_create("scraped")

  # Iterar nos URLs
  paths <- c()
  for (url in urls) {
    path <- paste0(dir, "/", stringr::str_remove_all(url, "[^a-z]"), ".html")
    paths <- append(paths, path)
    
    httr::GET(url, httr::write_disk(path, overwrite = TRUE))
  }

  return(paths)
}

# Rodar o scraper
paths <- scrape_urls(obj)

# Salvar os HTMLs no GCS
for (path in paths) {
  save_path(path)
}
```

Como você já pode imaginar pelos chamados acima, `obj` contém os URLs a 
serem raspados. Isso faz sentido porque, como descrito anteriormente, 
`list.rds` tem todo objeto que cada máquina precisa para seu próprio 
`exec.R`; neste caso, cada máquina precisa de um vetor de URLs a serem
scrapeados e `idx` é simplesmente o índice de cada máquina (para que duas
máquinas nunca raspem os mesmos URLs). É só isso.

Agora a única coisa que falta é criar o `list.rds`, ou seja, a lista de URLs
quebrada em um bloco para cada máquina. Como neste exemplo toy-cluster foi
criado com o número padrão de máquinas (3), `list.rds` vai ser uma lista
com 3 elementos. Os comandos a seguir devem ser rodados na sua máquina 
local:

```r
# URLs a serem raspados, blocados por máquina
url_list <- list(
  c("google.com", "duckduckgo.com"),
  c("wikipedia.org"),
  c("facebook.com", "twitter.com", "instagram.com")
)

# Sobrescrever o list.rds com a lista de URLs
readr::write_rds(url_list, "~/toy-dir/list.rds")
```

Com esse `list.rds`, o primeiro nó vai raspar motores de busca, o segundo
vai raspar a Wikipédia e o terceiro vai raspar mídias sociais.

## Dando push e executando a tarefa

Por último mas não menos importante, a tarefa deve ser pushada para o Google
[Container Registry](https://console.cloud.google.com/gcr/images) (GCR), que
é onde as imagens docker do Kuber vão ficar guardadas. Isso garante controle
de versão para todas as tarefas e permitem que elas sejam executadas de 
outro computador, mas pode levar um bom tempo para rodar da primeira vez que
você cria uma tarefa.


```r
kub_push_task("~/toy-dir")
#> ✔  Building image
#> ✔  Authenticating
#> ✔  Pushing image
#> ✔  Removing old jobs
#> ✔  Creating new jobs
```

Se tudo funcionou até agora, o último comando obrigatório é executar a 
tarefa:

```r
kub_run_task("~/toy-dir")
#> ✔  Authenticating
#> ✔  Setting cluster context
#> ✔  Creating jobs
#> ●  Run `kub_list_pods()` to follow up on the pods
```

## Gerenciando o progresso da tarefa

A duas formas principais de gerenciar o progresso de uma tarefa: listando os
pods atualmente ativos e listando os arquivos guardados em um bucket. As 
letras estranhas no nome de cada processo é um identificador único gerado
pelo Kuber para gerenciar aqueles pods.


```r
kub_list_pods("~/toy-dir")
#> ✔  Setting cluster context
#> ✔  Fetching pods
#>                          NAME READY  STATUS RESTARTS AGE
#> 1 process-mkewsr-item-1-8kpg7   1/1 Running        0  1m
#> 2 process-mkewsr-item-2-cph8z   1/1 Running        0  1m
#> 3 process-mkewsr-item-3-kpn5f   1/1 Running        0  1m
```

Se o
[status dos seus pods]((https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/))
indicar algo ruim, pode ser que você precise depurar o seu arquivo `exec.R`.
Isso é absolutamente normal e pode ser que sejam necessárias várias 
tentativas até que a sua tarefa esteja rodando corretamente. Se você 
precisar de ajuda na depuração da sua tarefa, dê uma olhada na vignette
["Debugging exec.R"](https://curso-r.github.io/kuber/articles/debug_exec.html).

O comando abaixo lista todo arquivo em um bucket. Você também pode 
especificar o diretório dentro do bucket e se a listagem deve ser feita
recursivamente. Aqui é possível ver que todo download terminou de rodar
corretamente.

```r
kub_list_bucket("~/toy-dir", folder = "scraped")
#> ✔  Listing content
#> [1] "googlecom.html"     "duckduckgocom.html" "wikipediaorg.html" 
#> [4] "facebookcom.html"   "twittercom.html"    "instagramcom.html" 
```
