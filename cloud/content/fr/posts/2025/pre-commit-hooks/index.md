
---
title: "Les pre-commit hooks, ou comment s'assurer d'avoir des commits au top !"
author: Antoine Delia
date: 2025-03-19T16:45:00+02:00
tags:
    - Git
    - Python
    - Terraform
categories: [ Git, Python, Terraform ]
draft: true
image: pre-commi-hooks.jpeg
---

Aujourd'hui, j'aimerai vous conter l'histoire de Bob.

# Bob, un développeur ordinaire

Bob travaille en tant que développeur dans une entreprise, où il passe son temps à coder sur de nombreux projets. Que ce soit du Python, du Terraform, ou même de la documentation, Bob est capable d'enchaîner plusieurs heures sur Visual Studio Code, pour livrer un maximum de features. Seulement voilà, il y a quelque chose qui n'arrête pas de l'irriter. Quelque chose qui le rend furieux à chaque fois.

# L'ennemi de Bob : les pipelines CD/CD

Quand Bob travaille sur une nouvelle feature, il est absorbé par son travail. Certains pourraient dire qu'il essaie à chaque fois de battre un record sur le temps de livraison d'une nouvelle feature. Ainsi, Bob pianote sur son clavier, enchaîne les commits, et finit par pusher tout ça sur le GitHub de son entreprise. Il ouvre ensuite une Pull Request pour que son code puisse être review, et c'est là que le malheur de Bob commence.

À chaque fois que Bob ouvre une Pull Request, une pipeline CI/CD se lance pour vérifier que la branch de Bob est OK. Et comme bien souvent, ce n'est pas le cas.

Que ce soit sur des projets Pythons, Terraform, ou de la documentation, ces pipelines vont systématiquement embêter Bob. "Ah, on dirait que tu as oublié de formatter ton fichier Terraform comme il faut !", ou encore "Oh mais ce ne serait pas un import Python inutilisé ça ?", ou même "C'est ça que tu appelles de la documentation en Markdown ?".

En effet, chaque pipeline de CI/CD va vérifier si le code ou la documentation de Bob applique les standards définis par son entreprise. Cela peut aller du style de formattage du code jusqu'à la détection de "code smell" (des bouts de code qui présentent un problème).

Et toutes ces vérifications, Bob trouve qu'elles sont importantes. Mais ce qui l'embête, c'est qu'il est obligé de pusher son code, et d'attendre que la pipeline se termine pour avoir ces informations. Une perte de temps, selon Bob ! Car il lui faut ensuite retourner dans Visual Studio Code pour faire les modifications adéquates, pour ensuite ajouter un autre commit à sa branch.

Si seulement il y avait un moyen pour Bob de s'éviter ce genre d'embêtements !

# Les pre-commit hooks à la rescousse

Heureusement pour Bob, il n'est pas le seul à trouver ce workflow très pratique. Et c'est ainsi que sont nés les [pre-commit hooks](https://git-scm.com/book/ms/v2/Customizing-Git-Git-Hooks).

Les pre-commit hooks sont des vérifications qui sont lancées au moment où vous allez vouloir créer un nouveau commit. Tout cela est propre à git, et il existe d'ailleurs des hooks qui peuvent être lancés basés sur d'autres actions.

En creusant un petit peu, Bob se rend compte qu'il existe un framework pour manager ces pre-commit hooks, qui porte un nom bien créatif : [pre-commit](https://pre-commit.com/).

## Les pre-commit hooks en action

Ni une ni deux, Bob lit la documentation (comme nous devrions tous le faire lorsque nous découvrons un nouvel outil), et décide de se lancer !
