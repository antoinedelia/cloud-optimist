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

À l'inverse, en tant que développeur, vous allez devoir mettre votre égo de côté, et admettre la possibilité que la première version de votre code n'était pas la meilleure qui soit. Et ce n'est pas grave. 

## Not a way to micro-manage, but to ensure four-eye review

## Way to learn new things about your coding language/best practices

## Anyone should be able to review, but you need codeowners

## CI/CD for code linting/formatting should be in place, and be used as a third-party review

## Comment the why, as you'll forget it in a month

## Variable/class/function naming

## Use your tools to their full extent! (i.e: github suggestions)

## Keep it short! Otherwise review will not be done


# Références
- https://vadimkravcenko.com/shorts/code-reviews/

