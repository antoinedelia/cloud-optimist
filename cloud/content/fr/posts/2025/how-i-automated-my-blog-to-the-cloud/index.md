---
title: "Comment j'ai automatisé la création de mon blog dans le Cloud"
date: 2025-02-04T14:00:00+02:00
author: Antoine Delia
draft: true
tags:
    - Terraform
    - CI/CD
    - GitHub Actions
    - Hugo
    - AWS
categories: [ Terraform, CI/CD, GitHub Actions, Hugo, AWS ]
image: automated-blog.jpeg
---

# Le commencement et la fin

Quand j'ai envisagé de créer un blog pour la première fois, j'étais encore étudiant dans mon école d'ingénieurs. Et le monde des sites internets et des blogs était encore quelque chose de nouveau pour moi. Et lorsque je me suis finalement lancé dans l'aventure du blogging, c'est tout naturellement que je me suis tourné vers ce qui semblait être la meilleure solution à l'époque : WordPress.

Quoi que l'on en dise, WordPress est une solution relativement simple d'usage pour les débutants qui souhaitent créer leur premier site internet. Et ça tombe bien, car j'en faisais parti ! 

Alors, armé d'un tout nouveau compte chez OVH, j'ai pû mettre en ligne mon [blog personnel](https://blog.antoinedelia.fr) en quelques cliques !

Et puis, quelques années plus tard, quand me vint l'idée de publier un blog dédié à des sujets professionels, Là encore, j'ai fait appel à mon bon vieil ami WordPress.

Les mois passèrent, et l'idyle que je vivais avec WordPress commençait petit à petit à se ternir. Certes, rajouter des articles à travers l'UI de WordPress était pratique, mais pour ce qui était de gérer les backups, c'était une autre paire de manches. En plus, WordPress requiert une base de données pour fonctionner, ce qui rendait le tout très volumineux pour quelques articles, sans compter la facture qui venait avec.

Je me rendais alors compte que, pour un blog aussi simple, et avec si peu de visites, il y avait certainement un moyen d'améliorer les choses.

# Le début d'un nouveau plan

Je vais vous raconter ici le cheminement qui m'a amené au renouveau de mon blog sur lequel vous vous trouvez aujourd'hui. Si vous êtes seulement intéressé par le résultat final, vous pouvez avancer à la prochain section. Sinon, bonne lecture !

## La découverte d'Hugo

Avant de me mettre en quête d'un nouvel outil pour mon blog, j'ai d'abord réfléchi à ce dont j'avais réelement besoin.

Mon blog était en fait assez rudimentaire : un page d'accueil qui listait les différents articles, pas de JavaScript tarabiscoté dans les parages, et aucun besoin d'un backend pour gérer une API. Au final, l'utilisation d'une base de données était-elle nécessaire ?

Il y avait aussi une chose importante à garder en mémoire. Je suis un ingénieur, ce qui fait de moi par définition, un bien piètre designer. Je voulais à tout prix éviter d'avoir à gérer le CSS de mon blog : je voualais me concenter sur le contenu, plutôt que sur le style.

J'ai donc commencé mes recherches, dans l'espoir de trouver un outil qui répondrait à ces critères. Et il ne m'a pas fallu bien longtemps avant de tomber sur la perle rare : [Hugo](https://gohugo.io/).

À peine ai-je atteri sur le site d'Hugo que je fus accueilli oar cet intriguant message : `Le framework le plus rapide du monde pour générer des sites web`. On peut dire que cela à piquer ma curiosité, et je me pressa d'aller fouiller dans la documentation. Et je n'allais pas être déçu.

Hugo se charge de convertir des articles au format markdown (comme l'on trouve sur GitHub par exemple) vers le format HTML. Qui plus est, il existe une [miriade de thèmes](https://themes.gohugo.io/) mis à disposition, ce qui me laissait l'embarras du choix, sans avoir besoin de designer quoi que ce soit !

Sans perdre une seconde, je m'empressa de convertir mon blog WordPress vers un site Hugo (j'ai utilisé pour ça un super petit script intitulé [wordpress-to-hugo-exporter](https://github.com/SchumacherFM/wordpress-to-hugo-exporter) qui convertit une base de données WordPress en fichiers markdown).

Mon site Hugo était désormais prêt ! Il fallait maintenant trouver un moyen de l'héberger quelque part.

## Un hébergeur à la hauteur : AWS

En même temps que je me creusais la tête pour trouver une alternative pour mon blog, j'ai eu une opportunité professionnelle qui m'a amené à travailler dans une entreprise spécialisée dans le Cloud, et plus particulièrement AWS.

À l'époque, le Cloud était tout nouveau pour moi. Mais j'en entendais tellement parler, que je voulais connaître la raison de cet engouement. Était-ce vraiment un "game-changer", comme certains le disaient, ou était-ce encore un de ces mots-clés techniques qui faisait le buzz ?

Pour vous la faire court, AWS était (et est toujours) absolument incroyable ! Ce n'était pas seulement la découverte d'un nouvel outil, il s'agissait là un changement de paradigme qui ne me ferait plus jamais voir aborder un problème de la même manière (si vous ne connaissez pas AWS et pensez que j'en fais trop, attendez de vous y mettre...).

Plus j'en apprenais sur AWS et la multitude de services qui le composait, plus je me disais : n'y a-t-il pas un moyen pour moi d'utiliser le Cloud pour mon blog ?

Avec cette idée en tête, je commençais à me renseigner sur toutes les options qu'offrait AWS. Et compte tenu de ma récente découverte d'Hugo, mon site n'avait ni besoin de PHP, ni d'une base de données pour fonctionner. Il s'agissait maintenant d'un site statique qui, à première vue, pouvait très bien être déployé dans un bucket S3. 

Et non seulement AWS offre une [documentation sur l'hébergement d'un site statique dans un bucket S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html), mais [le coût de stockage d'un site si léger ne représentait que quelques centimes](https://aws.amazon.com/s3/pricing/). 

J'avais trouvé là une manière simple et peu coûteuse de déployer mon site.

Le dernier point qui me chiffonait, est que pour mettre en place tout cela, je devais créer un bucket AWS S3, le configurer convenablement, rajouter le CDN AWS CloudFront, prendre en compte les certificats via AWS ACM, et finalement créer une entrée DNS dans AWS Route53. Tant d'actions qui, si réalisées manuellement, pouvait être difficiles à reproduire si jamais je venais à accidentellement supprimer mon compte AWS.

Il me fallait donc maintenant un moyen simple et robuste de configurer cette infrastructure.

## Terraform à la rescousse

TODO: talk about Terraform to setup S3 + CloudFront

## Oubliez les copier-coller avec GitHub Actions

My website was now perfect. I could focus on its content, just like I wanted. But there was one last thing that I knew I could enhance: the deployment.

You see, everytime I wanted to create a new post, I had to build my website, and drop the files into my S3 bucket, on my AWS account. For a lazy developer like myself, this was of course, a terrible waste of time and energy.

So I dived into the magical world of CI/CD pipelines. And despite Jenkins best effort to get noticed, I quickly turned to what seemed the most logical at the time: GitHub Actions.

GitHub Actions are basically CI/CD pipelines that you can define directly in your source code (assuming that you are using GitHub, of course). The main benefit is that you do not need any additional account, and the syntax is pretty straightforward.

So, I setup the pipeline, and everything went green!

# L'état actuel des choses

TODO: add code example + talk about the theme used + show how someone could do the same

# Et demain ?

Hugo deploy or using GitHub Pages

# Conclusion

At the beginning, I had to maintain a WordPress blog, which was tedious because of versionning, maintainability and ease of deployment.

Today, my blog is stored on GitHub, and on every single change of its content, everything is deployed automatically to AWS, for less than a dollar a month.

After realizing the power of static websites, AWS and GitHub Actions, I migrated three other personal websites to this new workflow, and I am now never scared to make a change!
