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

TBD - Montrer des screenshots de la console AWS API Gateway.

# Résolution

TBD

# Lessons Learned et Post-Mortem

TBD

# Conclusion

TBD
