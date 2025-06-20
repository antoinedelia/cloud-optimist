---
title: "Simplifiez vos GitHub Actions avec les Reusable Workflows"
date: 2025-07-26T07:30:00+02:00
author: Antoine Delia
draft: true
tags:
    - CI/CD
    - GitHub
categories: [ CI/CD, GitHub ]
image: reusable_workflows.jpg
---

Il y a quelques semaines, j'étais tout fier. J'avais enfin mis en place une pipeline CI/CD complète avec GitHub Actions pour déployer [mon premier projet AWS CDK](https://github.com/antoinedelia/aws-spotify-cover-automation). Installation des dépendances, configuration des credentials AWS via OIDC, déploiement vers AWS... Tout était automatisé, propre, parfait. Une bonne pipeline CI/CD comme je les aime !

Puis, est arrivé le deuxième projet CDK ([une super appli web de blindtest, basé sur vos chansons likées dans Spotify](https://github.com/antoinedelia/spotify-blindtest)). Et là, quelque chose m'a dérangé. Comme un sentiment de malaise. J'ai eu ce sentiment de déjà-vu : j'allais devoir copier-coller l'intégralité de mon premier workflow, en changeant à peine une ou deux variables. Et je savais déjà que pour le troisième projet, ce serait la même histoire.

C'est là que mes sonnettes d'alarme se sont mises à retentir. Non pas que je ne sois pas friand d'un petit <kbd>Cmd</kbd>+<kbd>C</kbd>/<kbd>Cmd</kbd>+<kbd>V</kbd> (désolé pour les <kbd>Ctrl</kbd> guys) de temps en temps, mais là, je voyais les problèmes arriver : une upgrade à faire ? C'est autant de repositories à mettre à jour. Un copier/coller fait à la va-vite ? Un cauchemar de maintenance en perspective...

Je ne pouvais tout simplement pas me permettre de laisser passer ça ! Mon temps est précieux, et mes touches <kbd>C</kbd> et <kbd>V</kbd> se font vieilles.

Heureusement, GitHub a une solution élégante à ce problème : les [**Reusable Workflows**](https://docs.github.com/en/actions/sharing-automations/reusing-workflows).

# Les Reusable Workflows

Un Reusable Workflow, c'est un type spécial de workflow GitHub Actions conçu pour être appelé par d'autres workflows. L'idée est simple mais géniale : vous définissez votre logique de déploiement (ou de test, de build, etc.) une seule fois dans un repository unique. Ensuite, vos autres repositories n'ont plus qu'à "appeler" ce workflow centralisé en lui passant les quelques paramètres spécifiques dont ils ont besoin (comme le nom d'un service ou l'environnement de déploiement).

Cette approche applique le fameux principe DRY (Don't Repeat Yourself), ce qui apporte des bénéfices immédiats :

* Maintenabilité : Une mise à jour de la logique ? Vous la faites à un seul endroit, et tous les projets qui utilisent le workflow en bénéficient instantanément.
* Standardisation : Vous imposez un processus de déploiement cohérent, testé et approuvé pour tous vos projets.
* Sécurité : Vous centralisez la gestion des actions et des permissions. Vous avez l'assurance que chaque projet utilise une méthode de déploiement validée.
* Lisibilité : Les workflows dans vos dépôts d'applications deviennent incroyablement plus simples et clairs. Ils ne spécifient plus que ce qu'il faut déployer (le WHAT), et non plus comment (le HOW).

# Mise en Place d'un Reusable Workflow

Convaincu ? Voyons comment mettre ça en place (c'est plus simple que ça en a l'air).

## Étape 1 : Créez un repository central pour vos workflows
La première étape est de créer un repository dédié dans votre organisation GitHub pour stocker vos workflows réutilisables. Un nom comme `reusable-workflows` ou tout simplement `workflows` est parfait. Ce repository peut être public, interne (si vous utilisez GitHub Enterprise), ou privé.

## Étape 2 : Définissez le workflow
Dans ce nouveau repo, créez le fichier YAML qui contiendra votre logique de déploiement (je prendrai pour exemple AWS CDK). Le chemin doit être `.github/workflows/`. Nommons notre fichier `cdk.yml` (ou `cdk-deploy.yml` si vous voulez être plus explicite).

Ce fichier ressemblera beaucoup à votre workflow actuel, mais avec deux différences clés : le trigger `on: workflow_call:` et l'utilisation des blocs `inputs` et `secrets` pour recevoir les données du workflow appelant (caller).

Voici à quoi pourrait ressembler un exemple complet :

```yml
name: Reusable AWS CDK Deployment

on:
  workflow_call:
    inputs:
      python-version:
        description: 'The version of Python to set up'
        required: false
        type: string
        default: '3.13'
      node-version:
        description: 'The version of Node.js to set up'
        required: false
        type: string
        default: '22'
      working-directory:
        description: 'The directory where the CDK app is located'
        required: false
        type: string
        default: '.'
      aws-region:
        description: 'The AWS region where to deploy the infrastructure'
        required: false
        type: string
        default: 'eu-west-1'

    secrets:
      AWS_ROLE_ARN:
        description: "The AWS IAM Role to assume for deployment"
        required: true

jobs:
  deploy-cdk-stack:
    runs-on: ubuntu-latest

    permissions:
      id-token: write
      contents: read

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ inputs.python-version }}

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}

      - name: Install AWS CDK
        run: npm install -g aws-cdk

      - name: Install Python dependencies
        working-directory: ${{ inputs.working-directory }}
        run: pip install -r requirements.txt

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ inputs.aws-region }}

      - name: Deploy CDK Stack
        working-directory: ${{ inputs.working-directory }}
        run: cdk deploy --all --require-approval never
```

## Étape 3 : Autorisez l'appel du workflow

> [!NOTE]
>
> J'ai beau avoir essayé de tout prendre en compte, il ne m'est pas impossible d'avoir raté une option.
>
> Si tel est le cas, n'hésitez pas à le mentionner en commentaire !

Autoriser l'appel d'un workflow réutilisable va dépendre de certains facteurs.

### Tout public

Si vous utilisez le GitHub public (aka: github.com), que vous n'avez pas d'organisation, et que votre repo `workflows` est public, vous n'avez rien à faire !

### Organization

Si vous avez une organisation, vous devez explicitement autoriser votre organisation d'utiliser des worfklows publiques.

### Privé

Si votre repo `workflows` est privé ou interne, vous devez explicitement autoriser vos autres repositories à l'utiliser.

1. Allez dans les `Settings` de votre repo `workflows`.
2. Cliquez sur `Actions` > `General`.
3. Dans la section `Access`, choisissez l'option appropriée. Pour autoriser tous les repos de votre organisation, sélectionnez "Accessible from repositories in the 'ORG' organization".

Si vos repositories sont privées, vous aurez sans doute besoin de plus de configuration. Je vous laisse consulter [Access to reusable workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows#access-to-reusable-workflows) et [Sharing actions and workflows with your organization](https://docs.github.com/en/actions/sharing-automations/sharing-actions-and-workflows-with-your-organization) pour plus d'informations.

## Étape 4 : Appelez le Workflow Réutilisable
C'est maintenant que l'on récolte les fruits de notre travail ! Dans chaque repository de vos applications CDK, votre ancien workflow de déploiement se transforme en ce fichier épuré :

```yml
name: Deploy CDK App to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    # C'est ici qu'on appelle le workflow réutilisable.
    # Pensez à utiliser un tag de version (@v1) pour la stabilité !
    # Sinon, vous pouvez utiliser le nom de votre branch principale (main)
    uses: MaSuperOrganisation/workflows/.github/workflows/cdk.yml@v1

    # On fournit les 'inputs' définis dans le workflow réutilisable.
    with:
      # Optionnel, car on a une valeur par défaut, mais utile si votre projet
      # a une structure spécifique (ex: code CDK dans un sous-dossier).
      working-directory: 'infra'

    # On fournit les 'secrets' attendus par le workflow réutilisable.
    # Ce secret doit être configuré dans les "Actions secrets" de ce dépôt.
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
```

Et voilà ! Propre, simple, et maintenable !

# Reusable Workflows vs. Custom Actions

On pourrait se demander quelle est la différence avec une ["Custom Action"](https://docs.github.com/en/actions/sharing-automations/creating-actions/about-custom-actions) que l'on peut aussi créer sur GitHub. La distinction est importante :

* Une Custom Action est une step unique et réutilisable. C'est comme une fonction ou un script que vous pouvez appeler. Pensez à l'action actions/checkout@v4 : elle fait une seule chose, le checkout du code.

* Un Reusable Workflow est une séquence complète de jobs et de steps. C'est une pipeline que vous réutilisez. Elle peut appeler plusieurs Custom Actions.

# Conclusion
En résumé, l'utilisation des Reusable Workflows vous apporte :

* Cohérence : Tous vos projets suivent le même processus de déploiement fiable.
* Efficacité : Une seule mise à jour est propagée partout.
* Simplicité : Les pipelines de vos projets deviennent faciles à lire et à écrire.
* Sécurité : La gestion des permissions et des outils utilisés est maîtrisée à un seul endroit.

C'est un petit investissement initial, mais pour un gain de temps, de sécurité et de sérénité immense sur le long terme. Si vous vous retrouvez à copier-coller des workflows, arrêtez tout et prenez une petite heure pour mettre en place un Reusable Workflow !
