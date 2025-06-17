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

Il y a quelque temps, j'étais tout fier. J'avais enfin mis en place une pipeline CI/CD complète avec GitHub Actions pour déployer mon premier projet AWS CDK. Installation des dépendances, configuration des credentials AWS via OIDC, déploiement du CDK... Tout était automatisé, propre, parfait.

Puis est arrivé le deuxième projet CDK. Et là, le drame. En ouvrant l'éditeur pour créer le nouveau workflow, j'ai eu ce sentiment de déjà-vu peu agréable : j'allais devoir copier-coller l'intégralité de mon premier workflow, en changeant à peine une ou deux variables. Et je savais déjà que pour le troisième projet, ce serait la même histoire.

C'est là que les sonnettes d'alarme se sont mises à retentir. Multiplier les copier-coller, c'est la porte ouverte aux problèmes : une mise à jour de sécurité à appliquer à 15 endroits différents, une logique de déploiement qui diverge entre les projets, un cauchemar de maintenance en perspective. Heureusement, GitHub a une solution élégante à ce problème : les [**Reusable Workflows**](https://docs.github.com/en/actions/sharing-automations/reusing-workflows) (ou workflows réutilisables).

# Les Reusable Workflows : Le Principe du "Ne Vous Répétez Pas" (DRY)

Un Reusable Workflow, c'est un type spécial de workflow GitHub Actions conçu pour être appelé par d'autres workflows. L'idée est simple mais géniale : vous définissez votre logique de déploiement (ou de test, de build, etc.) une seule fois dans un dépôt central. Ensuite, tous les dépôts de vos applications n'ont plus qu'à "appeler" ce workflow centralisé en lui passant les quelques paramètres spécifiques dont ils ont besoin (comme le nom d'un service ou l'environnement de déploiement).

Cette approche applique le sacro-saint principe DRY (Don't Repeat Yourself), ce qui apporte des bénéfices immédiats :

* Maintenabilité : Une mise à jour de la logique ? Vous la faites à un seul endroit, et tous les projets qui utilisent le workflow en bénéficient instantanément.
* Standardisation : Vous imposez un processus de déploiement cohérent, testé et approuvé pour tous vos projets.
* Sécurité : Vous centralisez la gestion des actions et des permissions. Vous avez l'assurance que chaque projet utilise la méthode de déploiement validée.
* Lisibilité : Les workflows dans vos dépôts d'applications deviennent incroyablement plus simples et clairs. Ils ne spécifient que ce qu'il faut déployer, et non plus comment.

# Mise en Place : Le Guide Pratique

Convaincu ? Voyons comment mettre ça en place. C'est plus simple que ça en a l'air.

## Étape 1 : Créez un Dépôt Central pour vos Workflows
La première étape est de créer un dépôt dédié dans votre organisation GitHub pour stocker vos workflows réutilisables. Un nom comme reusable-workflows ou org-actions est parfait. Ce dépôt peut être public, interne ou privé.

## Étape 2 : Définissez le Workflow Réutilisable
Dans ce nouveau dépôt, créez le fichier YAML qui contiendra votre logique de déploiement CDK. Le chemin doit être .github/workflows/. Nommons notre fichier reusable-cdk-deploy.yml.

Ce fichier ressemblera beaucoup à votre workflow actuel, mais avec deux différences clés : le déclencheur on: workflow_call: et l'utilisation de blocs inputs et secrets pour recevoir des données du workflow appelant.

Voici à quoi pourrait ressembler un exemple complet :

```yml
# /reusable-workflows/.github/workflows/reusable-cdk-deploy.yml

name: Reusable AWS CDK Deployment

on:
  # Ce déclencheur spécial indique que ce workflow peut être appelé par un autre.
  workflow_call:
    # Définit les paramètres que le workflow appelant peut passer.
    inputs:
      python-version:
        description: 'La version de Python à utiliser'
        required: false
        type: string
        default: '3.13'
      node-version:
        description: 'La version de Node.js à utiliser'
        required: false
        type: string
        default: '22'
      working-directory:
        description: "Le répertoire où se trouve l'application CDK"
        required: false
        type: string
        default: '.'
      cdk-outputs-artifact-name:
        description: "Le nom de l'artefact pour les outputs CDK"
        required: false
        type: string
        default: 'cdk-outputs'
      aws-region:
        description: 'La région AWS où déployer l'infrastructure'
        required: false
        type: string
        default: 'eu-west-1'

    # Définit les secrets que le workflow appelant DOIT fournir.
    secrets:
      AWS_ROLE_ARN:
        description: "L'ARN du rôle IAM à assumer pour le déploiement"
        required: true

jobs:
  deploy-cdk-stack:
    runs-on: ubuntu-latest

    # Ces permissions sont nécessaires pour utiliser OIDC avec AWS.
    permissions:
      id-token: write # Requis pour la fédération d'identité
      contents: read  # Requis pour l'action checkout

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
        run: cdk deploy --all --require-approval never --outputs-file ${{ inputs.cdk-outputs-artifact-name }}.json

      - name: Upload CDK Outputs as Artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ inputs.cdk-outputs-artifact-name }}
          path: ${{ inputs.working-directory }}/${{ inputs.cdk-outputs-artifact-name }}.json
          retention-days: 1
```

## Étape 3 : Autorisez l'Appel du Workflow

Si votre dépôt reusable-workflows est privé ou interne, vous devez explicitement autoriser les autres dépôts à l'utiliser.

1. Allez dans les Settings de votre dépôt reusable-workflows.
2. Cliquez sur Actions > General.
3. Dans la section Actions permissions, choisissez l'option appropriée. Pour autoriser tous les dépôts de votre organisation, sélectionnez "Allow [VOTRE_ORGANISATION] actions and reusable workflows".

Si vos repositories sont privées, vous aurez sans doute besoin de plus de configuration. Je vous laisse consulter [Access to reusable workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows#access-to-reusable-workflows) et [Sharing actions and workflows with your organization](https://docs.github.com/en/actions/sharing-automations/sharing-actions-and-workflows-with-your-organization).

## Étape 4 : Appelez le Workflow Réutilisable
C'est maintenant que l'on récolte les fruits de notre travail ! Dans chaque dépôt de vos applications CDK, votre workflow de déploiement complexe se transforme en ce fichier épuré :

```yml
# /mon-app-cdk/.github/workflows/deploy.yml

name: Deploy CDK App to AWS

on:
  push:
    branches: [master]

jobs:
  deploy:
    # C'est ici qu'on appelle le workflow réutilisable.
    # Pensez à utiliser un tag de version (@v1) pour la stabilité !
    uses: MaSuperOrganisation/reusable-workflows/.github/workflows/reusable-cdk-deploy.yml@v1

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

Et voilà ! Propre, simple, et maintenable.

# Reusable Workflows vs. Custom Actions : Quelle Différence ?

On pourrait se demander quelle est la différence avec une ["Custom Action"](https://docs.github.com/en/actions/sharing-automations/creating-actions/about-custom-actions) que l'on peut aussi créer sur GitHub. La distinction est importante :

* Une Custom Action est un outil unique et réutilisable. C'est comme une fonction ou un script que vous pouvez appeler. Pensez à l'action actions/checkout@v4 : elle fait une seule chose, le checkout du code.

* Un Reusable Workflow est une séquence complète de jobs et d'étapes. C'est un pipeline entier que vous réutilisez. Il peut lui-même appeler plusieurs Custom Actions.

Pour faire une analogie : la Custom Action est le tournevis. Le Reusable Workflow est le plan de montage complet qui vous dit quand et comment utiliser le tournevis, le marteau et les vis.

# Conclusion : Adoptez-les Sans Hésiter !
En résumé, l'utilisation des Reusable Workflows vous apporte :

* Cohérence : Tous vos projets suivent le même processus de déploiement fiable.
* Efficacité : Une seule mise à jour est propagée partout. Fini les modifications fastidieuses et sujettes aux erreurs dans de multiples dépôts.
* Simplicité : Les pipelines de vos projets deviennent triviaux à lire et à écrire.
* Sécurité Centralisée : La gestion des permissions et des outils utilisés est maîtrisée à un seul endroit.

C'est un petit investissement initial pour un gain de temps, de sécurité et de sérénité immense sur le long terme. Si vous vous retrouvez à copier-coller des workflows, arrêtez tout et prenez une heure pour mettre en place un Reusable Workflow. Votre futur vous remerciera !