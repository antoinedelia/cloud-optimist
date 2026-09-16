---
title: "Code Review : les pièges à éviter"
author: Antoine Delia
date: 2025-04-19T16:45:00+02:00
tags:
    - GitHub
    - Python
    - CI/CD
categories: [ GitHub, Python, CI/CD ]
draft: true
image: code-review.jpeg
---

Que vous soyez développeur junior ou senior, vous avez sans doute déjà eu à effectuer une code review (revue de code en français). Cette étape n'est pas toujours la plus plaisante, et certains se demandent même la raison d'une telle procédure : pourquoi perdre du temps à relire un code, alors que l'on pourrait déjà l'envoyer en production ?

Aujourd'hui, j'aimerai discuter avec vous de l'utilité des Code Review, ainsi que plusieurs conseils pour être sûr que vos Code Reviews se passent sans aucun souci !

# Une Code Review : Kézako ?

Avant toute chose, de quoi parle-t-on ? Très simplement, une Code Review consiste à faire relire son code par quelqu'un d'autre afin de s'assurer qu'il ne comporte pas d'erreurs, ou qu'aucun oubli n'ait été fait.

Et, bien que dans Code Review, il y ait le mot "code", cela ne veut pas dire que cela s'applique uniquement à ça. En effet, lorsque vous rajoutez du code, celui-ci s'accompagne normalement de documentation, de tests unitaires, etc. Toutes ces choses doivent aussi être revues pour être sûr que la qualité globale d'un nouvel ajout soit au rendez-vous.

# Pourquoi faire une Code Review ?

Peut-être que vous vous demandez à quoi tout cela peut bien servir. Car après tout, vous savez coder, non ? Vous devriez savoir ce qui va, ou ce qui ne va pas ?

Eh bien, c'est un peu vrai, mais il arrive parfois que vous passiez de nombreuses heures sur une feature ou un bug, si bien que vous en perdrez presque la raison. Dans ce genre de moments (aussi appelés avoir "la tête dans le guidon"), nos facultés d'analyse ne sont pas au mieux, et le regard d'une personne neutre, avec le recul nécessaire, saura vous dire si tout semble bon ou pas.

Théoriquement, une Code Review peut-être effectuée par soi-même, pour peu que vous laissiez votre code de côté pendant quelque temps afin de revenir dessus avec une vision plus claire. Toutefois, non seulement cela va ralentir votre capacité à livrer de nouvelles features, vous perdrez également une chance d'avoir ce regard nouveau, qui non seulement pourra reconnaître rapidement si un bout de code présente un problème, mais aussi qui pourra vous orienter vers une solution plus pertinente.

Et c'est sur ce dernier point que je voudrais insister : la collaboration.

En tant que développeurs, nous avons tous nos habitudes, acquises avec nos connaissances et nos expériences. Il est donc parfois facile de coder une feature avec une technique dont nous avons l'habitude, car en plus de gagner du temps, nous pensons que c'est la seule manière de faire. Or, l'un des gros intérêts d'une Code Review, est de confronter son code au regard d'une personne ayant des habitudes (et donc des connaissances et expériences) différentes. Cette personne pourra donc vous montrer une autre manière de faire. Dans le meilleur des cas, cela sera une amélioration de votre proposition initiale, et dans le pire, vous aurez appris quelque chose de nouveau !

Ainsi, pour une meilleure qualité de code et une meilleure collaboration, les Code Reviews sont un excellent outil !

# Conseils pour une Code Review réussie

Maintenant que vous en savez plus sur les Code Reviews (et que, je l'espère, ais attisé votre curiosité sur le sujet), j'aimerai vous partager plusieurs conseils que j'applique lors d'une Code Review, que je sois du côté développeur ou reviewer.

## Code reviews should be friendly

Le premier point, et sans doute le plus important de tous, est que les Code Reviews doivent être effectuées de manière bienveillante. Jamais vous ne devez ouvertement critiquer une personne, et cela dans les deux sens.

Si vous ne respectez pas ce point, vous aurez beau appliquer les suivants, personne ne voudra plus faire de Code Reviews.

En tant que reviewer, cela n'est pas évident, car à un moment donné, vous allez forcément devoir pointer des défauts dans le code que vous êtes en train de relire. Arrive ainsi mon deuxième conseil.

## You evaluate the code, not the individual

Quand vous êtes reviewer, vous devez vous rappeller que la chose que vous critiquez (je parle ici de critique constructive, positive comme négative) est du code, pas une personne. Ainsi, vous devez faire attention à votre façon de vous exprimer.

```
❌ "Ton code est illisible"
❌ "Pourquoi tu as fais comme ça ?"
❌ "Elle sert à rien cette fonction, supprime-la"
✅ "J'ai un peu de mal à comprendre le workflow global. Tu sais pourquoi on fait de cette façon ? Si oui, j'aimerai bien quelques commentaires pour qu'on puisse mieux comprendre"
✅ "J'ai vu que tu utilises <tel methode>. Il me semble que <cette méthode> pourrait améliorer les performance. Tu en penses quoi ?"
✅ "Cette fonction n'est pas appellée, est-ce un oubli ? Sinon, on pourrait la supprimer, tu ne crois pas ?"
```

Avez-vous repéré les facteurs clés ?

Ne pas dire tu mais on quand il s'agit de la codebase
Demander l'avis du dev, car des fois on croit savoir alors que non

Enfin, je veux attirer votre attention sur le fait qu'à la fin, le reviewer à le dernier mot sur le code qui doit être livré. Ainsi, malgré toute la bienveillance du monde, si vous devez absolument changer un bout de code pour respecter les guidelines de votre entreprise, il vous faudra les appliquer, même si le développeur va à l'encontre de cette décision. À vous de communiquer sur ces contraintes efficacement afin de ne pas créer de frustration ou de suprises au dernier moment.

À l'inverse, en tant que développeur, vous allez devoir mettre votre égo de côté, et admettre la possibilité que la première version de votre code n'était pas la meilleure qui soit. Et ce n'est pas grave. Il nous est tous déjà arrivé de passer beaucoup trop de temps sur un problème, jusqu'à ne plus être parfaitement lucide. Et dans ces moments-là, il n'est pas rare de faire des oublis, ou de s'emmêler les pinceaux. Profitez donc du fait que vous allez avoir un co-équipier qui sera là pour vous aider à terminer le boulot.

On parle souvent du four-eye review. Mais n'oubliez pas que vous êtes dans la même équipe.

## Way to learn new things about your coding language/best practices

Une chose dont on parle peu, c'est que les code reviews sont l'endroit parfait pour se former !

En effet, avec nos habitudes, nous avons tendance à répéter ce que nous savons faire. Et c'est tout à fait normal ! Quand on maitrise quelque chose, on est à l'aise avec, et on est rapide. Pourquoi s'enbêter avec le reste ?

Et c'est là que la force du reviewer va intervenir. Celui-ci, de par ses connaissances ou grâce au nombre de reviews qu'il aura faite, reconnaitra facilement s'il existe une meilleure façon de faire les choses.

Prenons un exemple simple.

```python
i = 0
for item in items:
    print(i, item)
    i += 1
```

Ici, le développeur souhaite itérer sur une liste d'`items`. En plus de cela, il aimerait pouvoir savoir où il en est dans sa boucle. Il ajoute donc une variable `i` qui gardera le compte.

Alors, si vous étiez reviewer, que proposeriez-vous ? Si je vous demande ça, c'est parce que pendant longtemps, c'est typiquement le genre de code que je pouvais écrire. Et personne ne m'a jamais indiqué qu'il existait un moyen simple et natif de faire ça !

```python
for i, item in enumerate(items):
    print(i, item)
```

Et oui, Python a tout prévu, et possède une fonction `enumerate` qui permet de résoudre le problème initial !

C'est exactement ce que les Code Reviews peuvent vous apporter en tant que développeur : de nouvelles connaissances qui vous permettront d'être encore plus rapide et performant que vous ne l'êtes déjà, alors pourquoi s'en priver ?

## Comment the why, as you'll forget it in a month

Vous avez peut-être déjà entendu le commentaire suivant : "ce code est nul, il n'est même pas commenté !". Ça vous dit quelque chose ?

Pendant mes études, on nous rabachait que les commentaires dans le code était obligatoire, qu'il fallait tout commenter, au risque de ne plus rien comprendre !

Aujourd'hui, je peux dire avec conviction que je suis à l'opposé de cette recommendation.

Pourquoi ? Parce qu'à force de nous forcer à écrire des commentaires, voilà ce que l'on obtient :

```python
# On créer une variable vide
cel = None
# On récupère un input de l'utilisateur
cel = input()
# On multiplie par 9
fahr = cel * 9
# On divise par 5
fahr = fahr / 5
# On ajoute 32
fahr = fahr + 32

# Enfin, on affiche le résultat
print(fahr - 2)
```

Wow, super. Une marre de commentaires qui ne servent à rien et qui polluent l'écran. Le code de base n'est déjà pas clair, mais les commentaires n'y apportent rien : vous pourriez les enlever qu'on comprendrait encore le code.

En effet, les commentaires ne sont pas là poue explique ce que vous faites, mais _pourquoi_ vous le faites.

Reprenons l'exemple plus haut et améliorons-le avec des noms de variables qui font sens.

```python
def celsius_to_fahrenheit(celsius: int) -> int:
    return (celsius * 9 / 5) + 32

temperature_in_celsius = input()
temperature_in_fahrenheit = celsius_to_fahrenheit(temperature_in_celsius)

print(temperature_in_fahrenheit - 2)
```

C'est déjà plus clair n'est-ce pas ? Pas besoin de commentaires pour comprendre ce qui se passe ici.

> D'accord, mais que vient faire ce `- 2` dans le résultat final ?

Ah ! En voilà une bonne question ! Effectivement, pourquoi faisons-nous ceci ? Il doit y avoir une raison, mais laquelle ? C'est là qu'un commentaire bien senti pourra faire la différence !

```python
def celsius_to_fahrenheit(celsius: int) -> int:
    return (celsius * 9 / 5) + 32

temperature_in_celsius = input()
temperature_in_fahrenheit = celsius_to_fahrenheit(temperature_in_celsius)

# On enlève 2 degrés, car un ventilateur est braqué sur nous,
# donc la température ressentie est un peu plus basse
print(temperature_in_fahrenheit - 2)
```

Bon, je ne vous cache pas que c'est un exemple un peu tiré par les cheveux... Mais au moins, on comprend d'où sort cette soustraction ! Et quand vous, ou quelqu'un d'autre, relira ce code dans 2 ans, il saura que cette soustraction est nécessaire. Ainsi, aucun risque de penser que c'est une coquille et de la supprimer, ce qui pourrait au final casser votre logique !

Et je vous assure que des cas comme ça, où l'on se demande plus tard : "Bon sang, mais pourquoi ce développeur a fait ça ???", il y en a un paquet !

Pensez donc à la pauvra âme qui devra passer après vous sur votre code, et préparez le terrain au mieux ! Elle vous en remerciera.

## CI/CD for code linting/formatting should be in place, and be used as a third-party review

Il n'y a rien de plus pénible lorsqu'on review un code, et que les seules remarques se situent au niveau de la "propreté" du code. Un saut de ligne en trop, un espace qui manque, des single-quotes ('') au lieu de double-quotes (""), des petits détails qui ne changent rien au code, mais qui vont vous énerver, vous et le développeur à qui vous allez remonter le souci.

C'est pourquoi, il est crucial de pouvoir se débarasser de ce fardeau au plus tôt. Et quoi de mieux qu'une bonne pipeline CI/CD pour faire le job à votre place ! Et avec tous les outils que l'on a aujourd'hui, plus d'excuses pour ne pas avoir ça en place.

Allez, je suis sympa, je vous offre une GitHub Actions toute simple pour commencer à vous y mettre.

```yaml
name: Ruff
on: [ push, pull_request ]
jobs:
  ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/ruff-action@v3
        with:
            args: "format --check --diff"
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/ruff-action@v3
        with:
            args: "check"
```

## Keep it short! Otherwise review will not be done

Quand on est reviewer, il y a une vision que l'on déteste avoir.

![Trop de changements dans une Pull Request](/img/how-to-make-good-code-reviews/too-many-changes.png)

> _Image honteusement dérobée : https://github.com/github/VisualStudio/issues/1301#issuecomment-342659205_

En effet, faire une revue de code, ça prend du temps.

Le reviewer doit se remettre dans le contexte du projet, comprendre quel est le but de la Pull Request, avant de finalement lire et comprendre le code soumis par le développeur. Tant d'étapes qui peuvent ralentir la mise en production d'une nouvelle feature.

Ainsi, plus les changements sont courts et simples, plus il sera facile pour le reviewer de valider ces changements.

Bien sûr, il y a des cas où cela n'est pas possible. Prenons un refactoring du code. Des fichiers vont surement être supprimés, déplacés, modifiés, etc. Et il ne sera alors pas possible de faire une revue simple. Dans ce cas-là, je conseille de créer une branche dédiée à ce refactoring, et de continuer à créer des Pull Requests simples vers cette nouvelle branche. Ainsi, le reviewer peut continuer d'approuver des changements réduits, tout en laissant le développeur avancer. Ce n'est qu'à la fin qu'il faudra passer en revue la branche de refactoring vers la branche principale. Mais si tout s'est bien passé, vous avez normalement déjà approuvé chaque changement, donc vous pourrez approuver sans peine la Pull Request finale !

## Use your tools to their full extent! (i.e: github suggestions)

## Anyone should be able to review, but you need codeowners



# Références
- https://vadimkravcenko.com/shorts/code-reviews/

