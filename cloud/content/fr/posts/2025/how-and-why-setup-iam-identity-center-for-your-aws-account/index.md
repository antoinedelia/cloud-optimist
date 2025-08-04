---
title: "Comment et pourquoi configurer AWS IAM Identity Center sur votre compte AWS"
date: 2025-09-08T09:30:00+02:00
author: Antoine Delia
draft: true
tags:
    - IAM
    - AWS
categories: [ Cloud ]
image: iam-identity-center.jpeg
---

Si vous jonglez avec plusieurs comptes AWS, ou même un seul compte avec différents utilisateurs, vous savez à quel point la gestion des accès peut devenir un véritable casse-tête. Créer des utilisateurs IAM individuels dans chaque compte, gérer leurs permissions, s'assurer que tout le monde utilise le MFA... Ouf, rien que d'y penser, ça peut donner des sueurs froides ! Et si je vous disais qu'il existe une solution élégante, centralisée et bien plus sécurisée pour gérer tout ça ? Mesdames et Messieurs, laissez-moi vous présenter AWS IAM Identity Center !

Depuis que j'ai découvert et mis en place IAM Identity Center (que certains connaissent peut-être sous son ancien nom, AWS Single Sign-On ou AWS SSO), ma vie d'administrateur Cloud a radicalement changé. Et je pèse mes mots ! C'est le genre d'outil qui, une fois adopté, vous fait vous demander comment vous avez pu vivre sans.

Alors, qu'est-ce que c'est exactement, et pourquoi est-ce si génial ? C'est ce qu'on va voir ensemble.

# IAM Identity Center : Késako ?

En termes simples, IAM Identity Center est un service AWS qui vous permet de gérer de manière centralisée l'accès à tous vos comptes AWS et à vos applications Cloud. Que vous ayez une poignée de comptes ou une organisation AWS tentaculaire avec des dizaines, voire des centaines de comptes, IAM Identity Center est là pour vous simplifier la tâche.

Il vous offre un point d'entrée unique (un portail d'accès web) pour vos utilisateurs, leur permettant d'accéder aux rôles et aux comptes auxquels ils ont droit, le tout avec une seule authentification.

# Les avantages d'IAM Identity Center

Si je suis aussi enthousiaste, c'est parce que les bénéfices sont nombreux et significatifs :

* Single Sign-On (SSO) Magique : C'est le Graal ! Vos utilisateurs se connectent une seule fois via le portail AWS (ou via votre fournisseur d'identité existant si vous en avez un) et accèdent ensuite à tous les comptes et rôles qui leur sont assignés, sans avoir à se ré-authentifier pour chaque compte. Un confort incroyable pour eux, et moins de mots de passe à gérer !

* Gestion Centralisée, Esprit Tranquille : Vous gérez tous vos utilisateurs, groupes et leurs permissions (via des "Permission Sets") depuis un seul endroit, même s'ils doivent accéder à des dizaines de comptes AWS différents.

* Identifiants Temporaires = Sécurité Maximale : C'est l'un des points les plus importants ! Lorsque les utilisateurs accèdent à un compte via IAM Identity Center, ils obtiennent des identifiants temporaires à durée de vie limitée. Adieu les clés d'accès IAM longue durée qui traînent et qui représentent un risque de sécurité majeur si elles sont compromises.

* MFA (Multi-Factor Authentication) pour Tous, Facilement : Vous pouvez (et devriez !) imposer l'utilisation du MFA directement au niveau de la connexion à IAM Identity Center. Une seule configuration MFA pour accéder à tous les comptes.

* Audit Amélioré et Transparent : Les logs CloudTrail tracent clairement qui a assumé quel rôle et quand, via IAM Identity Center. Cela simplifie grandement le suivi des actions et l'identification des responsabilités.

* Intégration Parfaite : IAM Identity Center s'intègre nativement avec AWS Organizations, ce qui facilite l'application des configurations d'accès à l'ensemble de vos comptes. Il peut aussi se fédérer avec des fournisseurs d'identité externes (comme Azure AD, Okta, etc.) si votre entreprise en utilise déjà un.

* Plus Besoin d'Utilisateurs IAM Individuels (pour les humains) : Pour l'accès humain à la console ou via la CLI, vous n'avez plus besoin de créer des utilisateurs IAM dans chaque compte membre. Les utilisateurs se connectent via Identity Center et assument des rôles. Les utilisateurs IAM "classiques" restent utiles pour les accès programmatiques (applications, services), mais pour vos équipes, c'est une simplification majeure.

# Se Lancer avec IAM Identity Center : Les Grandes Étapes

Mettre en place IAM Identity Center est étonnamment simple, surtout si vous utilisez l'annuaire intégré d'Identity Center comme source d'identité. Voici les étapes clés pour démarrer :

* Configuration Initiale d'IAM Identity Center : Rendez-vous dans la console AWS, cherchez "IAM Identity Center". Attention, choisissez bien votre région AWS pour héberger IAM Identity Center dès le départ, car il est actuellement complexe de changer la région d'IAM Identity Center une fois configuré. La configuration initiale est souvent guidée et rapide. Vous choisirez votre source d'identité (l'annuaire Identity Center, AWS Managed Microsoft AD, ou un fournisseur externe).

* Création de Groupes et d'Utilisateurs : Définissez des groupes qui ont un sens pour votre organisation (ex: Developers-ProjetA, Admins-Reseau, Auditeurs). Créez ensuite vos utilisateurs et assignez-les à ces groupes. Si vous utilisez un IdP externe, cette étape consistera plutôt à synchroniser vos utilisateurs et groupes existants.

* Création des "Permission Sets" : Un Permission Set est un ensemble de permissions (similaire à une politique IAM) que vous allez pouvoir réutiliser. Vous pouvez partir de politiques managées par AWS (ex: AdministratorAccess, ReadOnlyAccess) ou créer les vôtres, en respectant le principe du moindre privilège.

* Assignation des Accès : C'est ici que la magie opère. Vous assignez un groupe (ou un utilisateur) à un ou plusieurs comptes AWS, en leur donnant le droit d'utiliser un Permission Set spécifique sur ces comptes. Par exemple, le groupe Developers-ProjetA peut avoir le Permission Set PowerUserAccess sur le compte de développement du Projet A.

* Imposer le MFA : Dans les paramètres d'IAM Identity Center, configurez le MFA pour qu'il soit obligatoire pour tous vos utilisateurs. Différentes méthodes MFA sont supportées.

* Partager l'URL du Portail d'Accès AWS : Chaque configuration IAM Identity Center a une URL unique pour le portail d'accès (ex: d-xxxxxxxxxx.awsapps.com/start). C'est cette URL que vos utilisateurs mettront en favori pour se connecter.

Une fois connectés au portail, les utilisateurs verront la liste des comptes AWS et des rôles (définis par les Permission Sets) auxquels ils ont accès. Un clic, et ils sont dans la console du compte choisi avec les bonnes permissions, ou ils peuvent obtenir des identifiants temporaires pour la CLI !
Mon Verdict : Foncez !

# Configurer la CLI

TBD

# Conclusion

Vous l'aurez compris, je suis un grand fan d'AWS IAM Identity Center. Il apporte une couche de sécurité indispensable tout en simplifiant considérablement la gestion des accès, que ce soit pour les administrateurs ou pour les utilisateurs finaux.

Les identifiants temporaires, la centralisation, et l'intégration avec AWS Organizations en font un pilier pour une infrastructure AWS bien gérée et sécurisée. Si vous ne l'utilisez pas encore, je vous encourage vivement à explorer sa mise en place. C'est un investissement en temps minime pour des gains en sécurité et en efficacité énormes.

Votre infrastructure (et vos équipes de sécurité) vous diront merci !
