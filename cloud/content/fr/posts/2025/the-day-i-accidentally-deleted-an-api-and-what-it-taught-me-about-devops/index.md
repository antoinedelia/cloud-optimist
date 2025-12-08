---
title: "Le jour où j'ai accidentellement supprimé une API, et ce que cela m'a appris sur le DevOps"
date: 2025-12-15T07:30:00+01:00
author: Antoine Delia
draft: true
tags:
    - S3
    - API Gateway
    - Cognito
    - Terraform
    - AWS
    - Postmortem
categories: [ Infrastructure as Code, DevOps, CI/CD, Cloud ]
image: deleted-api.jpeg
---

# Introduction

La journée du 4 Avril 2024 avait bien commencé. Un petit café en main, un VS Code en plein ébulition, et de la douce musique électro dans les oreilles, tant de facteurs positifs qui ne pouvaient présager de la catastrophe à venir.

Mais laissez-moi vous donner un peu de contexte.

# Le contexte

Je travaillais alors dans une équipe avec pour but de mettre à disposition une API Gateway globale sur AWS, avec plusieurs endpoints managés par différentes équipes. Concrètement, la mise en place de cette API Gateway était l'étape initiale du projet. Cela comprenait un record DNS qui pointait vers cette API, l'API Gateway elle-même, ainsi qu'un Cognito Authorizer configuré avec plusieurs clients.

Une fois cette API prête, des équipes externes pouvaient alors déployer leurs propres endpoints sur cette API. Pour cela, une pipeline CI/CD était mise en place, et via CloudFormation, les endpoints se rattachaient directement à l'API déjà créée.

> [!NOTE]
>
> Je simplifie au maximum, si des détails techniques vous intéressent, n'hésitez pas à me contacter !

De mon côté, en plus d'être responsable de l'infrastrcture globale de l'API, il m'arrivait de travailler ou de troubleshooter certains services.

# Le début du drame

Si vous avez déjà travaillé avec CloudFormation, vous êtes peut-être familier avec le terme `UPDATE_ROLLBACK_FAILED`. C'est ce qui arrive lorsque vous essayez de mettre à jour une stack CloudFormation, mais que celle-ci a rencontré un problème. Elle essaiera donc de faire un rollback. Mais si ce rollback n'aboutit pas, votre stack sera alors en `UPDATE_ROLLBACK_FAILED`.

Et ce `UPDATE_ROLLBACK_FAILED` est bien embêtant, car vous ne pouvez plus relancer de déploiements tant que vous n'avez pas résolu le problème.

C'est exactement ce qui s'est passé ce fameux 4 Avril 2024. Un de nos services s'est retrouvé dans cet état, et j'ai commencé à investiguer le pourquoi du comment.

Après quelques minutes, j'ai constaté que le problème venait de la resource API elle-même. Sans trop réfléchir, et dans une optique de débloquer le problème rapidemement, je me suis rendu directement sur la console AWS, sur le service API Gateway. J'ai cherché la resource en question, et me suis empressé de la supprimer.

À ce moment précis, quelque chose de très étrange s'est produit. Un comportement innatendu qui m'a glacé le sang. Au lieu de me retrouver sur la même page, AWS m'a renvoyé sur la page principal du service API Gateway. Cette même page qui liste vos APIs disponible, et qui affichait maintenant le nombre `0`.

J'ai ainsi réalisé que je n'avais pas supprimé la ressource API, mais bien l'API Gateway dans sa totalité.

# Les détails d'un échec

Jamais je n'aurais pensé commettre une telle bêtise. Et j'imagine que vous lisant ces lignes, vous vous disez la même chose.

Car pour se tromper, il fallait le faire !

Laissez-moi vous faire une reconstitution de la scène du crime. Voici ce que j'ai vu au moment où j'ai pris la décision de supprimer une resource de l'API Gateway.

![Vue de la ressource API Gateway](/img/the-day-i-accidentally-deleted-an-api-and-what-it-taught-me-about-devops/api_gateway_view.png)

_Toute ressemblance avec une situation réelle est totalement fortuite_

Dans ma situation, sur quel bouton auriez-vous cliqué ? Facile ! Le bouton _Delete_ juste à droite de la ressource !

Pour ma part (et je ne sais toujours pas ce qui m'a poussé à faire cela), j'ai préféré cliquer sur le bouton _API actions_. Après tout, je voulais en effet faire une action !

Et que se passe-t-il quand on clique sur ce bouton ?

![Menu déroulant du bouton API Actions](/img/the-day-i-accidentally-deleted-an-api-and-what-it-taught-me-about-devops/api_actions.png)

Oula ! De suite, on voit que ce n'est pas du tout ce qu'on veut faire. Mais pensez-vous que cela m'a découragé ? Absolument pas ! J'étais venu pour supprimer une ressource, et quand j'ai vu le mot _Delete_, je n'ai pas réfléchi plus longtemps ! J'aurais dû, car ainsi, j'aurais sûrement vu le mot _API_ juste à côté.

Heureusement, nos amis de chez AWS ont pensé à tout ! Lorsque vous cliquez sur _Delete API_, on va tout de même vous demander si vous êtes bel et bien certain de vouloir supprimer cette API. Un beau message s'affiche, vous indiquant le nom de l'API en question, et vous demandant de taper le mot _confirm_ pour valider cette opération.

![Demande de confirmation de suppression de l'API](/img/the-day-i-accidentally-deleted-an-api-and-what-it-taught-me-about-devops/delete_api_dialog.png)

Tout ça, c'est bien beau, mais les ingénieurs d'AWS ont sous-estimé mon impatience. À ce moment-là, cette demande de confirmation n'était pas une mise en garde, mais un obstacle à mon but de supprimer ma ressource. Ni une ni deux, j'ai entré le mot _confirm_, et validé l'opération.

Voici donc la dernière chose que j'ai vu avant de finalement réaliser l'erreur que j'avais commise.

![L'API a été supprimée avec succès](/img/the-day-i-accidentally-deleted-an-api-and-what-it-taught-me-about-devops/successfully_deleted_api.png)

_Une vision d'horreur_

Je voulais absolument vous retracer ce petit parcours pour vous faire comprendre une chose : vous aurez beau mettre en place toutes les sécurtiés possibles, **vous ne pourrez jamais rien faire contre un individu impatient**, car ce dernier ne saura pas lire vos avertissements.

Alors, la prochaine fois que vous devrez faire une action somme toute innofensive, prenez bien le temps de lire et de vous assurer que vous êtes bel et bien sur le bon chemin.

Cela étant dit, passons maintenant à une étape cruciale : la résolution de cet incident !

# Résolution

TBD

# Lessons Learned et Post-Mortem

TBD

# Conclusion

TBD
