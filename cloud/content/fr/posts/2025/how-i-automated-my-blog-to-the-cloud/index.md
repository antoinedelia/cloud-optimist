---
title: "Comment j'ai automatisé la création de mon blog dans le Cloud"
date: 2025-01-27T13:30:00+02:00
author: Antoine Delia
draft: false
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

Et puis, quelques années plus tard, quand me vint l'idée de publier un blog dédié à des sujets professionels, là encore, j'ai fait appel à mon bon vieil ami WordPress.

Les mois passèrent, et l'idyle que je vivais avec WordPress commençait petit à petit à se ternir. Certes, rajouter des articles à travers l'UI de WordPress était pratique, mais pour ce qui était de gérer les backups, c'était une autre paire de manches. En plus, WordPress requiert une base de données pour fonctionner, ce qui rendait le tout très volumineux pour quelques articles, sans compter la facture qui venait avec.

Je me rendais alors compte que, pour un blog aussi simple, et avec si peu de visites, il y avait certainement un moyen d'améliorer les choses.

# Le début d'un nouveau plan

Je vais vous raconter ici le cheminement qui m'a amené au renouveau de mon blog sur lequel vous vous trouvez aujourd'hui. Si vous êtes seulement intéressé par les détails techniques, vous pouvez avancer à la prochain section. Sinon, bonne lecture !

## La découverte d'Hugo

Avant de me mettre en quête d'un nouvel outil pour mon blog, j'ai d'abord réfléchi à ce dont j'avais réelement besoin.

Mon blog était en fait assez rudimentaire : une page d'accueil qui listait les différents articles, pas de JavaScript tarabiscoté dans les parages, et aucun besoin d'un backend pour gérer une API. Au final, l'utilisation d'une base de données était-elle nécessaire ?

Il y avait aussi une chose importante à garder en mémoire. Je suis un ingénieur, ce qui fait de moi par définition, un bien piètre designer. Je voulais à tout prix éviter d'avoir à gérer le CSS de mon blog : je voualais me concenter sur le contenu, plutôt que sur le style.

J'ai donc commencé mes recherches, dans l'espoir de trouver un outil qui répondrait à ces critères. Et il ne m'a pas fallu bien longtemps avant de tomber sur la perle rare : [Hugo](https://gohugo.io/).

À peine eus-je atterri sur le site d'Hugo que je fus accueilli par cet intriguant message : `Le framework le plus rapide du monde pour générer des sites web`. On peut dire que cela a piqué ma curiosité, et je me pressa d'aller fouiller dans la documentation. Et je n'allais pas être déçu.

Hugo se charge de convertir des articles au format markdown (comme l'on trouve sur les README de GitHub par exemple) vers le format HTML. Qui plus est, il existe une [miriade de thèmes](https://themes.gohugo.io/) mis à disposition, ce qui me laissait l'embarras du choix, sans avoir besoin de designer quoi que ce soit !

Sans perdre une seconde, je m'empressai de convertir mon blog WordPress vers un site Hugo (j'ai utilisé pour ça un super petit script intitulé [wordpress-to-hugo-exporter](https://github.com/SchumacherFM/wordpress-to-hugo-exporter) qui convertit une base de données WordPress en fichiers markdown avec l'arborescence requise pour Hugo).

Mon site Hugo était désormais prêt ! Il fallait maintenant trouver un moyen de l'héberger quelque part.

## Un hébergeur à la hauteur : AWS

En même temps que je me creusais la tête pour trouver une alternative pour mon blog, j'ai eu une opportunité professionnelle qui m'a amené à travailler dans une entreprise spécialisée dans le Cloud, et plus particulièrement AWS.

À l'époque, le Cloud était tout nouveau pour moi. Mais j'en entendais tellement parler, que je voulais connaître la raison de cet engouement. Était-ce vraiment un "game-changer", comme certains le disaient, ou était-ce encore un de ces mots-clés techniques qui faisait le buzz ?

Pour vous la faire courte, AWS était (et est toujours) absolument incroyable ! Ce n'était pas seulement la découverte d'un nouvel outil, il s'agissait là d'un changement de paradigme qui ne me ferait plus jamais aborder un problème de la même manière (si vous ne connaissez pas AWS et pensez que j'en fais trop, attendez de vous y mettre...).

Plus j'en apprenais sur AWS et la multitude de services qui le composait, plus je me disais : n'y a-t-il pas un moyen pour moi d'utiliser le Cloud pour mon blog ?

Avec cette idée en tête, je commençais à me renseigner sur toutes les options qu'offrait AWS. Et compte tenu de ma récente découverte d'Hugo, mon site n'avait ni besoin de PHP, ni d'une base de données pour fonctionner. Il s'agissait maintenant d'un site statique qui, à première vue, pouvait très bien être déployé dans un bucket S3. 

Et non seulement AWS offre une [documentation sur l'hébergement d'un site statique dans un bucket S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html), mais [le coût de stockage d'un site si léger ne représentait que quelques centimes](https://aws.amazon.com/s3/pricing/). 

J'avais trouvé là une manière simple et peu coûteuse d'héberger mon site.

Le dernier point qui me chiffonait, est que pour mettre en place tout cela, je devais créer un bucket AWS S3, le configurer convenablement, rajouter le CDN AWS CloudFront, prendre en compte les certificats via AWS ACM, et finalement créer une entrée DNS dans AWS Route53. Tant d'actions qui, si réalisées manuellement, pouvaient être difficiles à reproduire si jamais je venais à accidentellement supprimer mon compte AWS.

Il me fallait donc maintenant un moyen simple et robuste de configurer cette infrastructure.

## Terraform à la rescousse

Quand vous commencez à apprendre le Cloud, vous allez généralement entendre parler d'[Infrastructure as Code](https://fr.wikipedia.org/wiki/Infrastructure_as_code).

Le principe est simple : décrire son infrastructure Cloud avec... du code ! (oui, comme son nom l'indique).

L'avantage d'utiliser un outil d'IaC, c'est que vous allez pouvoir garder en mémoire les changements effectués sur votre infrastructure, et pouvoir ainsi avoir un historique de toutes les modifications effectuées (un peu comme vous pouvez le faire avec du code classique sur GitHub).

Imaginons par exemple que quelqu'un décide de changer la configuration d'un service AWS. Cette personne se connecte sur la console AWS et effectue ces modifications. Mais après plusieurs essais infructueux, cette personne décide de laisser tomber pour le moment, et de revenir en arrière. Mais voilà, elle n'est plus vraiment sûr de la manière dont le service était configuré au départ ! Et à moins d'avoir pris note de l'état initial, cette personne n'a plus qu'à deviner à coups de plusieurs essais l'état dans lequel remettre ce service.

Tout cela aurait pû être évité si le service avait initialement été configuré avec un outil d'Infrastructure as Code. Si tel avait été le cas, un petit coup de déploiement automatique aurait fait l'affaire !

Des outils d'IaC, il en existe un paquet. Mais comment ne pas parler du plus populaire, de celui qui a rendu cette pratique commune dans le milieu du Cloud : [Terraform](https://www.terraform.io/).

Terraform est donc un outil d'Infrastructure as Code avec une approche déclarative, ce qui signifie que c'est à vous de déclarer l'état dans lequel vous souhaitez déployer votre infrastructure. Pour cela, il faut utiliser un langage bien particulier : le hcl (pour HashiCorp Configuration Language). Voici par exemple la création d'un bucket S3 via Terraform.

```terraform
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

Revenons maintenant à mon blog ! Terraform me semblait l'outil parfait pour configurer mon infrastructure qui accueillerait mon blog. Je n'avais plus qu'à passer par une étape d'architecture pour savoir de quels services AWS j'aurais besoin et comment les connecter entre eux, avant de mettre la main dans le code pour définir tout cela en langage Terraform.

Voici d'ailleurs le diagramme d'architecture que j'ai initialement crée pour l'occasion.

![Diagramme d'architecture de mon blog sur AWS, déployé par Terraform](/img/how-i-automated-my-blog-to-the-cloud/blog_architecture_diagram.png)

Tout cela était parfait, mais je me rendis vite compte d'une chose. À chaque fois que j'allais rajouter un article, ou que je devais modifier mon infrastructure, il me fallait cloner le projet sur mon ordinateur, et effectuer tout un tas d'opérations manuelles.

Autant vous dire que cela ne me plaisait pas du tout, et je comptais bien y remédier !

## Oubliez les copier-coller avec GitHub Actions

Comme je le disais juste au-dessus, mon site était fin prêt. La dernière étape qui me manquait concernait le déploiement.

Pour l'instant, quand je voulais créer un nouvel article, il me fallait build le site Hugo à la main, et déplacer les fichiers générés dans mon bucket S3. Quel terrible gâchis de temps et d'énergie !

J'ai donc creusé le sujet des pipelines CI/CD afin de me rendre la vie plus simple (si le sujet vous intéresse, je vous conseille [mon article sur la mise en place d'une stratégie CI/CD](https://cloud.antoinedelia.fr/fr/posts/2025/how-we-built-a-cicd-strategy-that-onboards-100-python-projects-in-under-a-minute/)). Et bien que Jenkins essayait à tout prix de se distinguer, je suis parti sur ce qui semblait être le plus logique : [GitHub Actions](https://github.com/features/actions).

Les GitHub Actions sont en fait des pipelines CI/CD qui sont définies directement dans votre repository GitHub. Le gros avantage, est que vous n'avez pas besoin de créer un compte supplémentaire ou d'installer quoi que ce soit, tout est inclus ! En plus de ça, GitHub Actions utilise une syntaxe YAML très facile à comprendre (contrairement à Jenkins et son groovy des enfers !).

C'est donc assez facilement que j'ai pû créer une pipeline qui me reconfigure Terraform si mon infrastructure a été modifiée, et qui me build et deploy automatiquement mon blog sur mon bucket S3 en cas de modifications ou ajout d'un article.

Toutes les steps de la pipeline sont au vert, mission accomplie !

# Côté technique : L'état actuel des choses

Mon blog est désormais automatisé et se déploie sur AWS automatiquement !

Si vous voulez plonger directement dedans, tout est publique sur mon repository GitHub : https://github.com/antoinedelia/cloud-optimist

Mais laissez-moi détailler un peu tout ça.

## Structure du projet

La structure de mon projet est comme suit :

```sh
cloud-optimist/
├── .github/
│   └── workflows/
│       └── main.yml  # GitHub Actions
├── cloud/
│   └── ...  # Mon blog Hugo
├── terraform/
│   └── ...  # La configuration Terraform
└── README.md
```

Comme vous le voyez, je sépare ce projet en trois dossiers clés :
- `.github` : contient le fichier `main.yml` qui définit les étapes CI/CD de la GitHub Actions
- `cloud` : contient mon blog Hugo
- `terraform` : contient toute l'infrastructure Terraform

## La GitHub Actions

Ma GitHub Actions est assez simple, et se décompose en plusieurs étapes.

### Les étapes de préparation

Regardons d'abord le haut du fichier.

```yml
name: 'Build and Deploy'

on:
  push:
    branches:
    - master
  pull_request:

jobs:
  build-and-deploy:
    name: 'Build & Deploy'
    runs-on: ubuntu-latest
    environment: production

    defaults:
      run:
        shell: bash
        working-directory: cloud
```

Ici, je dis à GitHub de lancer la pipeline uniquement sur la branch `master`, ou s'il s'agit d'une Pull Request. Je vous rassure, je ne déplois rien en production via une Pull Request. Vous verrez un peu plus bas, que cela me permet uniquement de build mon blog afin de tester que tout va bien, mais le déploiement ne sera effectué qu'une fois les changements mergés sur la branch `master`.

J'indique également à GitHub d'utiliser `bash`, et de se baser par défaut dans le dossier `cloud`.

Voyons maintenant la suite :

```yml
    steps:
    - uses: actions/checkout@v3
    - uses: dorny/paths-filter@v2
      id: filter
      with:
        filters: |
          web:
            - 'cloud/**'
          terraform:
            - 'terraform/**'
```

Cette première étape est cruciale si vous voulez accélérer vos temps de CI/CD ainsi qu'économiser de l'argent.

Je me sers de l'actions [dorny/paths-filter](https://github.com/dorny/paths-filter) qui me permet de détecter quels fichiers ont été modifiés lors du dernier commit. Dans mon cas, je regarde en particulier les dossiers `cloud` et `terraform`. Ainsi, si je ne détecte pas de changements côté Terraform, aucun besoin de lancer l'étape qui va reconfigurer mon infrastructure. Idem, si le dossier `cloud` est intact, inutile de build et deploy le blog. Cela vous sauvera quelques centimes liés au coût de transfert de fichiers vers AWS (pas la peine de me remercier !).

La section suivante parle d'elle-même. Je viens récupérer le contenu de mon repository et m'assure de mettre à jour les submodules. Cette dernière étape me servait du temps où j'utilisais les submodules pour mes thèmes Hugo. J'utilise désormais les [Hugo Modules](https://gohugo.io/hugo-modules/use-modules/), et je pourrais donc zapper cette étape.

```yml
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v2
      
    - name: Update Git Submodules
      working-directory: ./
      run: git submodule update --init --recursive
```

### Les étapes Terraform

Passons à la partie Terraform :

```yml
    # Install the latest version of Terraform CLI and configure the Terraform CLI configuration file with a Terraform Cloud user API token
    - name: Setup Terraform
      if: steps.filter.outputs.terraform == 'true'
      uses: hashicorp/setup-terraform@v1
      with:
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
    - name: Terraform Init
      if: steps.filter.outputs.terraform == 'true'
      working-directory: ./terraform
      run: terraform init

    # Checks that all Terraform configuration files adhere to a canonical format
    - name: Terraform Format
      if: steps.filter.outputs.terraform == 'true'
      working-directory: ./terraform
      run: terraform fmt -check

    # Generates an execution plan for Terraform
    - name: Terraform Plan
      if: steps.filter.outputs.terraform == 'true'
      working-directory: ./terraform
      run: terraform plan

      # On push to master, build or change infrastructure according to Terraform configuration files
      # Note: It is recommended to set up a required "strict" status check in your repository for "Terraform Cloud". See the documentation on "strict" required status checks for more information: https://help.github.com/en/github/administering-a-repository/types-of-required-status-checks
    - name: Terraform Apply
      working-directory: ./terraform
      if: steps.filter.outputs.terraform == 'true' && github.ref == 'refs/heads/master' && github.event_name == 'push'
      run: terraform apply -auto-approve
```

C'est déjà bien plus long ! Analysons ça étape par étape.

La première chose qui devrait attirer votre attention, c'est cette ligne :

```yml
if: steps.filter.outputs.terraform == 'true'
```

Vous vous rappelez, c'est ce qui permet de dire si des fichiers ont été modifiés dans le dossier `terraform`. Je vérifie donc ici si j'ai besoin de lancer ces étapes ou non.

Ensuite, je lance quelques commandes basiques de Terraform : un `terraform init` pour initialiser mon projet, un `terraform fmt -check` pour m'assurer que mon code est tout joli, et enfin un `terraform plan` pour voir les changements à effectuer.

Reste une dernière étape, et pas des moindres : le `terraform apply -auto-approve`, qui permettra de déployer les changements. Mais si vous êtes attentifs, vous remarquerez que j'ai rajouté deux conditions :

```yml
github.ref == 'refs/heads/master' && github.event_name == 'push'
```

Cela me garantit que cette étape ne sera uniquement lancée si l'action est un `push` sur la branch `master`. Ainsi, aucun risque de déploiement inopportun si je décide de travailler sur une autre branch ou sur une Pull Request. Ouf !

### Les étapes Hugo et AWS

Maintenant que mon infrastructure est au point, il est temps de publier mon blog !

```yml
    - name: Build
      uses: actions/setup-node@v2
      if: steps.filter.outputs.web == 'true'
    - run: sudo wget https://github.com/gohugoio/hugo/releases/download/v0.142.0/hugo_extended_0.142.0_linux-amd64.deb -O hugo.deb
    - run: sudo dpkg --install ./hugo.deb
    - run: hugo

    - name: Deploy to AWS
      uses: jakejarvis/s3-sync-action@master
      if: steps.filter.outputs.web == 'true' && github.ref == 'refs/heads/master' && github.event_name == 'push'
      with:
        args: --acl public-read --follow-symlinks --delete
      env:
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: 'eu-west-1'
        SOURCE_DIR: 'cloud/public/'
```

Comme pour Terraform, nous vérifions si des modifications ont été effectuées au niveau du blog.

```yml
if: steps.filter.outputs.web == 'true'
```

Ensuite, je récupère une version extended d'Hugo directement depuis la release GitHub, ici la version v0.142.0. Je l'installe et build mon site en lançant la commande `hugo`.

> Cette étape pourrait être simplifiée avec l'utilisation de l'actions [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo)

Enfin, j'utilise l'actions [jakejarvis/s3-sync-action](https://github.com/jakejarvis/s3-sync-action) (je me rends compte en écrivant cet article que cette actions a été archivée quelques jours plus tôt, aïe ! -- je rajouterai un edit plus tard pour parler d'une alternative) pour déplacer mon blog vers mon bucket S3.

Bien sûr, il vous faudra stocker vos credentials au niveau de votre repository GitHub pour autoriser cette opération vers AWS, mais rien de bien sorcier !

## La partie Terraform

Concernant la partie Terraform, je vais essayer d'être bref, car il n'y a rien de bien compliqué.

Une particularité dans mon cas, c'est que j'aime séparer mes fichiers `.tf` en fonction des services AWS utilisés, plutôt que d'avoir un unique fichier `main.tf` qui peut vite devenir difficile à lire. J'ai donc un fichier `s3.tf` pour les ressources liées au service S3, un `cloudfront.tf` pour tout ce qui est lié au service CloudFront, etc.

Un détail important, c'est qu'il est nécessaire de définir à minima la region `us-east-1`, car c'est dans cette region que vous devez créer vos certificats ACM. Pour le reste, toutes mes ressources sont créées dans la region `eu-west-1`. J'utilise pour cela les [alias Terraform](https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations). Voici un exemple :

```terraform
# La configuration par défaut : les ressources qui commencent par `aws_` utiliseront ce provider
provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

resource "aws_s3_bucket" "site" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_acm_certificate" "cert" {
  provider                  = aws.us_east_1  # Utilise le provider AWS dans us-east-1 via son alias
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
}
```

## La partie Hugo

Mon blog Hugo se base sur le theme [Stack](https://themes.gohugo.io/themes/hugo-theme-stack/). Il existe d'ailleurs un [template GitHub](https://github.com/CaiJimmy/hugo-theme-stack-starter) qui vous permet en un clic de récupérer le squelette du blog, et de l'adapter selon vos envies, ou de tout simplement vous concentrer directement sur vos articles.

Pas grande chose de plus à dire sur cette partie, si ce n'est que je vous encourage à voir le fonctionnement des [Hugo Modules](https://gohugo.io/hugo-modules/), ce qui vous évitera de gérer vos thèmes via un submodule (et qui vous simplifiera la vie lors de la mise à jour du thème).

# Pistes d'améliorations

Bien que je sois très satisfait du résultat final, j'ai noté quelques points qui pourraient être améliorés dans le futur.

D'abord, j'ai vu qu'Hugo dispose d'une commande `deploy` qui est capable de déployer directement un blog sur un bucket S3. Parfait ! Je dois donc creuser le sujet de [Hugo Deploy](https://gohugo.io/hosting-and-deployment/hugo-deploy/).

Enfin, même si l'hébergement dans AWS est peu coûteux (moins de 2$ par mois), il n'en est pas moins gratuit. Or, il serait tout à fait possible d'utiliser les [GitHub Pages](https://pages.github.com/) pour rendre ce blog accessible, et profiter de GitHub comme hébergement (là-dessus, je suis un peu moins emballé, car je ne pourrais plus me la péter avec mes jolis diagrammes AWS...).

# Conclusion

Et voilà, vous savez tout !

De mes débuts avec WordPress, qui, bien que pratique, présentait des faiblesses du point de vue backup, maintenance et déploiement.

De mes recherches pour trouver une stack technique parfaite : AWS, Terraform, Hugo et GitHub Actions, tout ça pour permettre un déploiement rapide et à moindre coût !

Quand je compare avec ce que j'avais à l'époque, je ne suis que trop heureux d'avoir sauté le pas !

Et vous aussi, vous avez maintenant toutes les informations pour créer un blog à vous, et déployer tout ça en un clin d'oeil !

Happy blogging !
