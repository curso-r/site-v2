---
title: "Abandonando o Termo 'master' no GitHub"
date: "2020-07-27"
tags: ["github", "git"]
categories: ["tutorial"]
banner: "img/banners/blm.jpg"
author: ["Caio"]
summary: "Assim como algumas linguagens de programação no passado, o GitHub está abandonado o termo 'master'. Veja como se adiantar e adotar o 'main' a partir de já."
draft: false
editor_options:
  chunk_output_type: console
---

A terminologia _master/slave_ (mestre/escravo) existe há muitas décadas na computação e parece ter [migrado](https://en.wikipedia.org/wiki/Master/slave_(technology)) para a indústria da tecnologia já no início do século XX. Esses conceitos normalmente estão associados a um modelo de comunicação assimétrico no qual um processo ou aparelho (o "mestre") controla outros processos ou aparelhos (os "escravos"). Não é necessário dizer que os termos vêm sendo contestados há anos devido à evidente conotação racista, mas o debate ganhou nova vida após os protestos do Black Lives Matter em 2020.

Várias linguagens de programação já abandonaram essa terminologia. Em 2018, no caso em que possivelmente houve maior repercussão até hoje, o Python [abandonou](https://www.vice.com/en_us/article/8x7akv/masterslave-terminology-was-removed-from-python-programming-language) a palavra _master_ por _parent process_ (processo pai) e a palavra _slave_ por _worker_ (trabalhador) ou _helper_ (ajudante) após um [debate](https://bugs.python.org/issue34605) acalorado.

Enquanto isso, já em 2014, o Django passou a adotar a terminologia _primary/replica_ (primário/réplica) e foi seguido pelo Drupal. Em 2017, o Internet Systems Consortium optou por _primary/secondary_ (primário/secundário). Como se pode ver, não faltam alternativas para uma referência à escravidão.

Enfim, este ano foi a vez do GitHub. Desde sua criação, a plataforma de controle de versão tem utilizado o termo _master_ para tratar do _branch_ principal de um repositório e, apesar de nem existir uma analogia para algo como um _slave branch_, a palavra continua até hoje. Antes tarde do que nunca, a empresa [anunciou](https://www.vice.com/en_us/article/k7qbyv/github-to-remove-masterslave-terminology-from-its-platform) que vai fazer uma transição em breve para o termo _main_ (principal) e aposentar seu antecessor.

Justamente por pretender ser uma comunidade inclusiva e aberta, alguns programadores de R já começaram a transferir seus repositórios do GitHub para o novo modelo. Em seu blog, [Steven Mortimer](https://stevenmortimer.com/5-steps-to-change-github-default-branch-from-master-to-main/) forneceu o passo-a-passo para fazermos o mesmo. Os comandos são bastante simples e estão listados abaixo:

```sh
# Passo 1
# Crie o branch 'main' localmente trazendo o histórico do 'master'
git branch -m master main

# Passo 2
# Faça o push do novo branch para o GitHub
git push -u origin main

# Passo 3
# Substitua o HEAD do 'master' para o 'main'
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

# Passo 4
# Troque o branch padrão no GitHub para o 'main'
# https://docs.github.com/pt/github/administering-a-repository/setting-the-default-branch

# Passo 5
# Delete o 'master'
git push origin --delete master
```

Note apenas que o Passo 4 deve ser realizado diretamente no GitHub de acordo com a [documentação](https://docs.github.com/pt/github/administering-a-repository/setting-the-default-branch) (disponível em português).

Caso você queira que o processo seja completamente automatizado, existe um [aplicativo web](https://eyqs.ca/tools/rename/) que faz tudo para você. Para saber mais sobre os esforços do próprio GitHub, acesse [a página](https://github.com/github/renaming) na qual estão sendo discutidas as mudanças.
