---
title: "Cloud Souverain : Comment démarrer avec Scaleway"
date: 2026-05-17T07:30:00+01:00
author: Antoine Delia
draft: true
tags:
    - Scaleway
    - Cloud Sovereignty
categories: [ Cloud ]
image: scaleway.png
---

# Pourquoi le Cloud Souverain ?
Ces dernières semaines, le concept de "Cloud Souverain" était partout, comme une évidence. Et pourtant, quand j'ai commencé à m'intéresser au Cloud il y a plusieurs années, personne n'en parlait. C'était déjà une prouesse de comprendre et utiliser le Cloud, alors qu'il soit souverain ou non, franchement, tout le monde s'en fichait.

Mais avec le climat géopolitique actuel, tout le monde s'est souvenu que les trois grands acteurs du Cloud que sont AWS, Azure et GCP sont américains, et que cela pourrait potentiellement poser des problèmes, notamment avec le Cloud Act, qui permet au gouvernement américain d'accéder aux données stockées sur les serveurs de ces entreprises, même s'ils sont situés en dehors des États-Unis.

Ainsi, vous aurez beau dire : "non mais chez nous on utilise la région AWS `eu-west-1` en Irlande, donc c'est complètement souverain !", ça ne changera rien au fait que vos données sont potentiellement accessibles par le gouvernement américain. Et beaucoup d'entreprises ont commencé à en prendre conscience, et à se demander s'il n'était pas temps de chercher une alternative plus *souveraine*.

Et même si on observe des initiatives de la part des Big Three (je pense notamment à AWS avec son initiative [*AWS European Sovereign Cloud*](https://www.aboutamazon.fr/actualites/aws/aws-lance-laws-european-sovereign-cloud-et-annonce-son-expansion-en-europe)), on observe une montée en popularité de solutions alternatives, comme Scaleway, qui a su se positionner rapidement comme un acteur majeur du Cloud Souverain en Europe.

Aujourd'hui, j'aimerai donc tester avec vous Scaleway, du point de vue de quelqu'un qui a toujours été habitué à AWS. Serais-je agréablement surpris ? Découvrons-le ensemble !

# Premiers pas avec Scaleway

## Aperçu de la console

Je vous passerai toute la partie de création de compte. C'est assez simple, et je n'ai pas rencontré de problèmes particuliers.

Maintenant, comme la première impression est importante, voyons voir à quoi ressemble la console d'administration de Scaleway dès notre arrivée.

![Console d'administration de Scaleway](scaleway_console.png)

Ma première bonne surprise, est la notion de projets. Là où chez AWS, pour un même compte, toutes vos ressources co-habitent au même endroit (ce qui peut rendre la recherche de ressources compliquée), chez Scaleway, vous pouvez créer des projets qui viendront grouper vos ressources. Un premier projet "Default" existe déjà, et j'imagine qu'il servira aux ressources "communes" à plusieurs projets.

Au niveau de l'interface utilisateur, sans pour autant révolutionner la navigation (et après tout, ce n'est pas forcément ce qu'on attend), Scaleway utilise une sidebar plutôt épurée, avec un groupement de services en fonction de leur fonction. Qui plus est, chaque service a un nom clair, ce qui permet de rapidement savoir où on veut aller (là où AWS aime bien les noms de services cryptiques).

Allez, fini de rêvasser, et entrons dans le vif du sujet !

## Création d'une fonction

Le premier test que j'aimerai faire, c'est de déployer une simple function (aka une AWS Lambda) pour voir les similitudes et différences avec AWS.

Je me rends donc dans Serverless Compute --> Functions. Et je suis déjà perplexe : Scaleway me parle de "namespaces" pour me permettre de grouper mes fonctions. J'ai d'abord pensé à une redite des "projets" vu plus haut, mais les "namespaces" permettent en plus de partager des variables d'environnement entre plusieurs fonctions. Des groupes dans des groupes donc.

Passons là-dessus pour l'instant, et commençons à créer notre première fonction.

![Création d'une fonction dans Scaleway](scaleway_create_function.png)

Pour commencer, je trouve l'interface très clair, et j'apprécie particulièrement les petites docs glissées à certains endroits, ainsi que la mention "Deprecated" sur les versions des runtimes. Idem pour les coûts estimés dans la colonne de droite, une bonne indication rapide pour voir si on n'est pas en train de faire n'importe quoi ! Au final, cela ressemble beaucoup à du AWS, mais en plus "clean" et plus ordonné.

Il y a tout de même des points qui me chiffonnent un peu :
* La request timeout indique un maximum de 900, mais le slider peut monter à 3600
* L'input "Average request duration" qui n'a pas l'air de pouvoir être rempli

Une fois que tout est bon, je finis par créer ma fonction. Et là encore, je suis un peu déçu. Il aura fallu plus d'une minute pour déployer cette fonction qui ne contient qu'un simple "Hello World". J'ai notamment été intrigué par l'étape numéro 3 : "function image is being pushed to container registry". J'ai trouvé ça assez curieux que Scaleway stocke une image de ma pauvre fonction Hello World. Je suis donc allé voir dans le service "Container Registry" et suprise ! Mon image était bien là, mais avec une taille de 337MB !!! Sachant que le stockage des images sur Scaleway est facturé, je trouve ça un peu fort de café de devoir déjà payé 0.06€ pour un bête Hello World.

Mais revenons à nos fonctions. Un autre point noir concerne l'éditeur de code. Là où chez AWS, on nous offre une expérience proche d'un Visual Studio Code, chez Scaleway, vous n'aurez droit qu'à un simple textarea, avec un seul fichier. Je vous entends déjà dire "de toute façon, modifier du code dans la console, c'est une hérésie !", et je suis d'accord avec vous. Mais cela montre le retard de Scaleway sur ce point.

En contrepartie, la navigation est quant à elle bien plus agréable et facile pour s'y retrouver. J'apprécie tout particulièrement la partie "Test" qui nous offre une commande curl prête à l'usage (dommage cependant qu'il ne soit pas possible de tester directement depuis la console).

## Même exercice avec Terraform

Comme je le disais plus haut, la console c'est bien, mais si on veut se lancer sérieusement dans un provider cloud, alors il faudra passer par la case Infrastructure as Code. Et ici, mon chouchou reste Terraform. Je suis donc curieux de voir comment se passe le déploiement d'une fonction sur Scaleway avec Terraform.

