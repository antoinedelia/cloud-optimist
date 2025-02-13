
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

### Installation et théorie

Ni une ni deux, Bob lit la documentation (comme nous devrions tous le faire lorsque nous découvrons un nouvel outil), et décide de se lancer !

La première chose à faire, eh bien, c'est de l'installer !

```sh
pip install pre-commit
```

Pour être sûr que tout s'est bien passé, un `pre-commit --version` ne mange pas de pain.

Ensuite, il va falloir créer un fichier propre à pre-commit, pour lui indiquer quels hooks il doit utiliser. Bob crée donc le fichier `.pre-commit-config.yaml` à la racine de son projet.

> [!NOTE]
>
> Ce fichier ne doit pas être ajouté à votre `.gitignore`. Au contraire, le rajouter dans votre projet permettra aux futurs développeurs d'en profiter !

C'est maintenant que ça devient intéressant ! Bob va pouvoir, dans ce fichier, spécifié les hooks qui l'intéressent en suivant la structure suivante :

```yaml
repos:
-   repo: L'URL du repo qui contient des pre-commit hooks
    rev: La version à utiliser
    hooks:
    -   id: Une liste de hook
-   repo: ...
    rev: ...
    hooks:
    -   id: ...
```

Tout ça, c'est bien beau, mais comment savoir quels hooks sont disponibles ? Heureusement, une [liste non-exhaustive de repos](https://pre-commit.com/hooks.html) est présente sur le site du projet, et vous permettra de choisir parmi les dizaines de repos existants.

Dans le cas de Bob, il voudrait rajouter dans son projet Python, un hook pour lui permettre de lancer `ruff format` et `ruff check` à chaque commit. Il aura donc le fichier `.pre-commit-config.yaml` suivant :

```yaml
repos:
- repo: https://github.com/astral-sh/ruff-pre-commit
  # Ruff version.
  rev: v0.9.6
  hooks:
    # Run the linter.
    - id: ruff
    # Run the formatter.
    - id: ruff-format
```

> [!NOTE]
>
> Je prends le cas de Python dans cet exemple, mais vous avez des hooks pour des projets utilisant des fichiers Terraform, shell, sql, et bien d'autres !

Tout cela est bien beau, mais il ne se passe pour l'instant pas grand chose. En effet, après avoir listé ces hooks, il va falloir les installer.

```sh
pre-commit install
```

> [!NOTE]
>
> La best practice à retenir est de toujours lancer la commande `pre-commit install` après avoir cloné un nouveau repository

Dès à présent, Bob peut lancer un nouveau commit, et `pre-commit` lancera automatiquement ces nouveaux hooks !

### Mise en pratique

> [!IMPORTANT]
>
> Cette section par du principe que Bob a un fichier `pyproject.toml` existant et configuré pour Ruff.

Bob a maintenant ses pre-commit hooks installés dans son projet. Il décide alors de les mettre à l'épreuve. Il se focalise alors sur le bout de code suivant :

```python
TODO
```

Bob doit rajouter une fonction pour ne plus utiliser des valeurs hardcodées, mais les récupérer via un fichier texte. Ni une ni deux, Bob se retrousse les manches et modifie le code de la manière suivante :

```python
TODO
```

Tout semble bon pour Bob. Machinallement, il lance un `git add .` suivi d'un `git commit -m "done"` (oui, Bob n'est pas très fort pour les messages de commit), et s'attend à ce que son code puisse être push sur GitHub.

Mais quelle surprise ! Bob se retrouve nez à nez avec un beau warning : "TODO".

## Créer votre propre hook

TODO
