---
title: "Le jour où j'ai accidentellement supprimé une API, et ce que cela m'a appris sur le DevOps"
date: 2025-12-15T07:30:00+01:00
author: Antoine Delia
draft: true
tags:
    - S3
    - API Gateway
    - CloudFormation
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

## Le déclic

Revenons donc sur le moment du drame. Après avoir réalisé ce qui était arrivé, j'ai eu comme un électrochoc, un éclair de génie (aucune poudre blanche n'ayant pourtant été consommée). Je savais maintenant ce que je devais faire : résoudre l'incident, mais surtout, documenter les actions que j'allais entreprendre.

Car quelques semaines plus tôt, je m'étais intéressé à [l'incident GitLab de 2017](https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/), celui ayant interrompu le service pendant plusieurs heures, et résultant d'une perte de données pour certains utilisateurs. J'ai ainsi découvert le terme de **Post-Morten**, et leur intérêt dans ce genre de situation. Mais je garde ça pour la prochaine section de cet article.

En attendant, si vous êtes intéressés par ces sujets-là, je vous conseille la très bonne [chaîne Youtube de Kevin Fang](https://www.youtube.com/@kevinfaang/videos) qui je le cite : "lit des postmortems et en fait des vidéos de piètre qualité".

## Rollback, impact, et communication

La première chose que je me suis dite, c'est qu'il était peut-être possible de faire une sorte de rollback directement depuis AWS, et d'ainsi réduire au maximum l'impact sur les utilisateurs. Si j'avais correctement lu le message d'avertissement plus haut, j'aurais tout de suite compris que cela était impossible (mais si je l'avais lu, je n'aurais de toute façon pas été dans cette situation).

N'ayant aucun moyen rapide et simple de revenir en arrière, j'étais maintenant confiant que j'étais face à un véritable incident ayant un impact global. J'ai donc dans un premier temps pris soin de comprendre tous les impacts que cette suppression d'API allait avoir. Dans mon cas, non seulement l'API n'était plus disponible (merci Captain Obvious), mais en plus de cela, aucun nouveau déploiement n'était possible jusqu'à ce que l'API soit de nouveau opérationnelle.

Finalement, j'ai fait en sorte d'avertir toute notre équipe interne de la situation. Ainsi, ils étaient au courant de l'incident en cours, et que j'étais en train de travailler à sa résolution.

## Analyse et découverte de problèmes

Il était maintenant temps de se retrousser les manches et de trouver un moyen de redéployer cette API Gateway.

En premier lieu, je me suis rendu dans le service CloudFormation, car j'avais souvenir que cette API avait été initialement déployée via ce service. J'ai d'abord essayé de mettre à jour la stack, en pensant que cela pourrait faire revenir ma chère API comme par magie.

Évidemment, cela n'allait pas être aussi simple. La mise à jour de cette stack était maintenant impossible, car la suppression manuelle de l'API avait fait rentrer la stack dans un état "hybride" dont elle n'arrivait pas à se sortir.

La mise à jour de cette stack étant impossible, la suite logique était de la supprimer afin de la déployer à nouveau proprement. Et c'est là que les ennuis ont commencé. Cette fameuse stack CloudFormation produisait plusieurs Outputs. Deux de ces outputs étaient nécessaires à toutes les stacks "enfants" qui avaient jusqu'alors déployé leurs endpoints sur cette API. Ainsi, CloudFormation m'interdisait de supprimer ma stack, car elle pourrait impacter toutes les autres.

Après plusieurs minutes de réflexion pour essayer de trouver d'autres alternatives, cette forte interdépendance m'amena à prendre une décision difficile : supprimer toutes les stacks "enfants" de CloudFormation, pour un total de 81 stacks.

Pour couronner le tout, ces stacks "enfants" n'avaient pas de tags identifiables qui auraient pour nous permettre d'automatiser cette suppression. Heureusement, la plupart d'entre elles avaient un nom avec un prefix reconnaissable, ce qui m'a permis de faire un bon coup de ménage sur la plupart d'entre elles.

Je vous ai parlé d'interdépendances ? Parce que ce n'est pas fini ! Certaines stacks avaient déployé des buckets S3. Et devinez quoi ? CloudFormation ne voudra pas supprimer votre stack, si votre bucket S3 n'est pas vide ! Et bien sûr, 14 stacks se sont retrouvées dans l'état `DELETE_FAILED` à cause de cela. Heureusement, le problème se résoud assez facilement : après avoir fait un backup de chaque bucket, il suffit de les vider et de relancer la suppression de la stack.

## Déploiement de l'API : Le bout du tunnel ?

Étant venu à bout de toutes ces interdépendances, il était maintenant temps de supprimer la stack CloudFormation de l'API Gateway, et de la déployer à nouveau.

La suppression se passa sans plus de problème (Dieu merci), mais évidemment, cela ne fût pas le cas pour sa création.

Déjà, parlons de la stack elle-même. Un fichier YML existait dans un repo GitHub, mais celui-ci n'avait pas été mis à jour depuis des lustres, et je savais que je ferai mieux d'utiliser la définition de la stack présente dans CloudFormation (et oui, je l'ai quand même gardée, pas fou le gars).

Mais comme vous pouvez l'imaginer,

# Lessons Learned et Post-Mortem

TBD - dire que c'était une API de DEV, donc ouf !

# Conclusion

TBD
