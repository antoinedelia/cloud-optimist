---
title: "Comment et pourquoi configurer AWS IAM Identity Center sur votre compte AWS"
date: 2025-11-08T09:30:00+02:00
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

Si je suis aussi enthousiaste, c'est parce que les bénéfices sont nombreux et significatifs. Pour vous citer les plus importants :

* Single Sign-On (SSO) : Vos utilisateurs se connectent une seule fois via le portail AWS (ou via votre fournisseur d'identité existant si vous en avez un) et accèdent ensuite à tous les comptes et rôles qui leur sont assignés, sans avoir à se ré-authentifier pour chaque compte.
* Gestion Centralisée, Esprit Tranquille : Vous gérez tous vos utilisateurs, groupes et leurs permissions (via des "Permission Sets") depuis un seul endroit, même s'ils doivent accéder à des dizaines de comptes AWS différents.
* Identifiants Temporaires : C'est l'un des points les plus importants ! Lorsque les utilisateurs accèdent à un compte via IAM Identity Center, ils obtiennent des identifiants temporaires à durée de vie limitée. Adieu les clés d'accès IAM longue durée qui traînent et qui représentent un risque de sécurité majeur si elles sont compromises.
* MFA (Multi-Factor Authentication) : Vous pouvez (et devriez !) imposer l'utilisation du MFA directement au niveau de la connexion à IAM Identity Center.

Si j'ai piqué votre curiosité et que vous souhaitez en savoir plus, je vous laisse consulter la [documentation AWS sur IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html). Pour ceux qui sont déjà convaincus, continuons ensemble !

# Se Lancer avec IAM Identity Center

Mettre en place IAM Identity Center est étonnamment simple, surtout si vous utilisez l'annuaire intégré d'Identity Center comme source d'identité. Voici les étapes clés pour démarrer :

* Configuration initiale : Rendez-vous dans la console AWS, et cherchez "IAM Identity Center". Attention, choisissez bien votre région AWS pour héberger IAM Identity Center dès le départ, car il est actuellement complexe de changer la région d'IAM Identity Center une fois configuré. La configuration initiale est souvent guidée et rapide. Vous choisirez votre source d'identité (l'annuaire Identity Center, AWS Managed Microsoft AD, ou un fournisseur externe).
* Création de groupes et d'utilisateurs : Définissez des groupes pertinents pour votre organisation (ex: Developers, Administrators, ...). Créez ensuite vos utilisateurs et assignez-les à ces groupes. Si vous utilisez un IdP externe, cette étape consistera plutôt à synchroniser vos utilisateurs et groupes existants.
* Création des "Permission Sets" : Un Permission Set est un ensemble de permissions (similaire à une policy IAM) que vous allez pouvoir réutiliser. Vous pouvez partir de policies managées par AWS (ex: AdministratorAccess, ReadOnlyAccess) ou créer les vôtres.
* Assignation des accès : C'est ici que la magie opère. Vous assignez un groupe (ou un utilisateur) à un ou plusieurs comptes AWS, en leur donnant le droit d'utiliser un Permission Set spécifique sur ces comptes. Par exemple, le groupe Developers peut avoir le Permission Set `PowerUserAccess` sur les comptes AWS de développement.
* Imposer le MFA : Dans les paramètres d'IAM Identity Center, configurez le MFA pour qu'il soit obligatoire pour tous vos utilisateurs.
* Partager l'URL d'accès AWS : Chaque configuration IAM Identity Center a une URL unique pour le portail d'accès (ex: d-xxxxxxxxxx.awsapps.com/start). C'est cette URL que vos utilisateurs mettront en favori pour se connecter.

Une fois connectés au portail, les utilisateurs verront la liste des comptes AWS et des rôles (définis par les Permission Sets) auxquels ils ont accès. Un clic, et ils sont dans la console du compte AWS choisi avec les bonnes permissions ! Ils peuvent aussi obtenir des identifiants temporaires pour la CLI. Mais d'ailleurs, comment faire pour se connecter à un compte AWS en CLI via IAM Identity Center ? Voyons ça ensemble !

# Configurer les accès CLI

La [documentation d'AWS pour configurer l'authentification CLI avec IAM Identity Center](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) est assez claire, mais je vais tout de même vous décrire les étapes. Je pars du principe que vous avez déjà votre [AWS CLI](https://aws.amazon.com/cli/) d'installée.

La première et **seule** commande à lancer sera la suivante :
```sh
aws configure sso
```

Ensuite, vous allez devoir rentrer quelques informations propre à votre IAM Identity Center. Le plus important étant le "SSO start URL" (que vous pouvez trouver dans IAM Identity Center sous le nom de "AWS access portal URL", URL qui finit par `/start`). Il faut ensuite rentrer la region dans laquelle se trouve votre configuration, quant au "SSO registration scopes", vous pouvez laisser la valeur par défaut.

```sh
SSO session name (Recommended): default
SSO start URL [None]: https://xxxxxxxxxxxx.awsapps.com/start
SSO region [None]: eu-west-1
SSO registration scopes [sso:account:access]:
```

Si tout se passe bien, une fenêtre devrait s'ouvrir dans votre navigateur pour valider votre identité. Une fois cela fait, retournez dans votre terminal.

Dans mon cas, je ne possède qu'un seul compte AWS, et IAM Identity Center me le sélectionne par défaut. Mais vous aurez peut-être le choix dans le compte AWS à sélectionner. Idem pour le role.

Enfin, choisissez un nom de profile à utiliser pour vos futurs appels API. Je vous conseille d'utiliser `default`, ce qui vous permettra de ne pas avoir à rajouter `--profile my-aws-profile` à la fin de chacune de vos commandes.

```sh
The only AWS account available to you is: xxxxxxxxxxxx
Using the account ID xxxxxxxxxxxx
The only role available to you is: AdministratorAccess
Using the role name "AdministratorAccess"
Default client Region [None]: eu-west-1
CLI default output format (json if not specified) [None]: json
Profile name [AdministratorAccess-xxxxxxxxxxxx]: default
The AWS CLI is now configured to use the default profile.
Run the following command to verify your configuration:

aws sts get-caller-identity
```

Et voilà, le tour est joué !

# Conclusion

Vous l'aurez compris, je suis un grand fan d'AWS IAM Identity Center. Il apporte une couche de sécurité indispensable tout en simplifiant considérablement la gestion des accès, que ce soit pour les administrateurs ou pour les utilisateurs.

C'est un véritable pilier pour une infrastructure AWS bien gérée et sécurisée. Si vous ne l'utilisez pas encore, je vous encourage vivement à explorer sa mise en place. C'est un investissement en temps minime pour des gains en sécurité et en efficacité énormes.

Votre infrastructure (et vos équipes de sécurité) vous diront merci !
