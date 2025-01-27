---
title: "FizzBuzz, la façon la plus simple et efficace de tester un développeur"
date: 2019-05-27T13:35:55+02:00
draft: false
author: Antoine Delia
tags:
    - Python
categories: [ Python ]
image: fizzbuzz.jpeg
---

Lorsque je suis sorti de mon école d'ingénieur, j'ai passé beaucoup d'entretiens dans l'espoir d'obtenir un poste de développeur. Mes expériences s'étant limitées à quelques stages, je redoutais cette partie de l'entretien où je devais me lever et résoudre un exercice de code sur un tableau blanc, ou même simplement répondre à quelques questions techniques. Je me trompais.

**Aucun entretien ne m'a testé sur mes compétences en développement.**

J'aurais pu mentir tout au long de l'entretien et tout de même obtenir le poste.

Pour être honnête, je ne fais pas partie de ceux qui louent les questions techniques comme s'il s'agissait d'une formule magique pour détecter les bons développeurs. Je préfère penser qu'une personne avec un bon tempérament, passionnée et humainement agréable est beaucoup plus intéressante qu'un "je-sais-tout" qui ramène toujours sa science à la table sans vouloir entendre l'avis des autres. <strong>On peut combler un manque technique, mais on ne peut pas améliorer un mauvais caractère.</strong>

Cela étant dit, je crois qu'il est obligatoire de vérifier à minima la manière de penser de quelqu'un lorsqu'il est confronté à un problème. Parce qu'au final, c'est ce qu'il fera la plupart du temps : résoudre des problèmes. En ce sens, il est crucial de voir comment quelqu'un va réagir face à un problème. Va-t-il fuir ? Va-t-il immédiatement demander de l'aide ?

C'est là qu'intervient le test <strong>FizzBuzz</strong>.

> Cet article a été inspiré par la vidéo de [Tom Scott](https://www.youtube.com/watch?v=QPZ0pIK_wsc) que je vous recommande vivement de regarder si ce sujet vous intéresse.

L'idée de FizzBuzz est simple. Vous devez énumérer les nombres à haute voix en commençant par 1 jusqu'à 100. Mais, si le nombre est un multiple de 3, vous devez dire "Fizz" à la place. De même, si le nombre est un multiple de 5, vous devez dire "Buzz". Maintenant, vous vous demandez peut-être : "Que faire si c'est un multiple de 3 et de 5 ?". Eh bien, vous devrez simplement dire "FizzBuzz". <em>Générique de fin</em>.


En lisant ce test simple, vous pourriez vous demander pourquoi il devrait être utilisé, car à première vue, même un stagiaire pourrait le résoudre assez facilement. Eh bien, c'est ce que je pensais aussi, jusqu'à ce que je tombe sur [l'article de Jeff Atwood à ce sujet](https://blog.codinghorror.com/why-cant-programmers-program/), où il explique être surpris de voir que ce problème donnait beaucoup de mal à des candidats, seniors compris.

<strong>Alors, essayons de le résoudre ensemble !</strong>

<em>Dans la plupart des entretiens techniques, vous avez généralement le choix du langage de programmation avec lequel vous souhaitez résoudre un problème (voir même d'écrire en [pseudo-code](https://fr.wikipedia.org/wiki/Pseudo-code)). Pour ce billet, j'utiliserai Python.</em>

Avant toute chose, créons une boucle simple qui affiche tous les nombres de 1 à 100.

```python
# Premier piège ici, range exclut le dernier nombre que vous lui passez.
# Ici, nous commençons bien à 1, et finissons à 100.
for i in range(1, 101):
    print(i)
```

On commence bien ! Maintenant, revenons à l'énoncé original : si le nombre est un multiple de 3, on affiche "Fizz", si c'est un multiple de 5, on affiche "Buzz". Ajoutons ces conditions.

```python
for i in range(1, 101):
    if i % 3 == 0:
        print('Fizz')
    if i % 5 == 0:
        print('Buzz')
    if i % 3 != 0 and i % 5 != 0:
        print(i)
```

Prenons un moment pour voir ce qu'on a fait ici. <strong>Pour vérifier si un nombre est un multiple de 3, nous utilisons le modulo avec le symbole `%`.</strong> Nous faisons la même chose pour les multiples de 5. Enfin, si le nombre n'est ni un multiple de 3 ni de 5, on l'affiche simplement.

Ainsi, on obtient exactement ce que l'on veut !... Sauf quand un nombre est un multiple de 3 ET de 5. Dans ce cas, <strong>les mots Fizz et Buzz ne sont pas affichés sur la même ligne !</strong> Nous devons donc prendre en compte ce cas en ajoutant une nouvelle condition, et empêcher les deux premiers `if` de se déclencher.

```python
for i in range(1, 101):
    if i % 3 == 0 and i % 5 != 0:
        print('Fizz')
    if i % 5 == 0 and i % 3 != 0:
        print('Buzz')
    if i % 3 == 0 and i % 5 == 0:
        print('FizzBuzz')
    if i % 3 != 0 and i % 5 != 0:
        print(i)
```

Ça fonctionne enfin ! Mais à quel prix ? <strong>Ce code est un vrai désordre.</strong> Et ce n'est en aucun cas un code facile à maintenir. Prenons cet exemple : que se passerait-il si nous voulions maintenant afficher le mot Fizz pour les multiples de 2 au lieu de 3 ? <strong>Nous devrons changer cette valeur à 4 endroits différents dans le code</strong> pour que cela fonctionne.

Cela peut sembler trivial avec un code aussi minimaliste, mais imaginez ce qui se passerait si cela arrivait dans un projet bien plus grand. <strong>Ce code est sujet à erreurs, complique sa maintenabilité et rend presque impossible l'ajout de nouvelles fonctionnalités facilement.</strong>

Essayons une autre approche pour rendre ce code plus élégant ! Déclarons d'abord une variable qui sera la valeur que nous voulons afficher à la fin. On la laisse vide pour l'instant. Chaque fois que nous avons une condition qui correspond, nous ajoutons simplement le mot correspondant à la variable. À la fin, vérifier si la variable est vide nous indiquera si nous devons l'afficher ou plutôt afficher le nombre.

Voici ce que cela donne.


```python
for i in range(1, 101):
    result = ''
    if i % 3 == 0:
        result += 'Fizz'
    if i % 5 == 0:
        result += 'Buzz'
    print(result or i)
```

C'est déjà beaucoup plus clair ! Non seulement nous avons réduit le nombre de lignes de moitié, mais nos vérifications `if` sont désormais limpides et ne laissent aucune place à l'interprétation. De plus, nous pouvons facilement changer la valeur de n'importe quel nombre si nécessaire sans avoir à chercher toutes ses occurrences. Enfin, si nous devons ajouter une autre condition (pour les multiples de 7 par exemple), il nous suffira d'ajouter deux nouvelles lignes sans toucher au reste du code !

Nous voyons enfin en quoi ce simple test FizzBuzz est si intéressant. Il nous a permis de tester la capacité d'une personne à utiliser des principes algorithmiques simples, mais aussi de vérifier sa manière de penser lorsqu'elle est confrontée à un problème, et si elle est capable de produire un code qui pourra être facilement maintenu dans le futur.

<strong>En résumé, FizzBuzz est un bon moyen de différencier un développeur d'un bon développeur.</strong>
