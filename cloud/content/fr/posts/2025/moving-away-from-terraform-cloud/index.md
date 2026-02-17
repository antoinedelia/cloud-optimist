---
title: "Comment migrer son State de Terraform Cloud vers AWS S3 ?"
date: 2025-12-17T07:30:00+02:00
author: Antoine Delia
draft: false
tags:
    - AWS
    - S3
    - Terraform
categories: [ Cloud, Infrastructure as Code ]
image: terraform.png
---

# Introduction

Quand j'ai commencé à utiliser Terraform (notamment pour [le déploiement de mon blog](/fr/posts/2025/how-i-automated-my-blog-to-the-cloud/)), je me suis tourné vers l'utilisation de **Terraform Cloud** (ce nom a ensuite été modifié en HCP Terraform).

# Terraform et le State

Si vous connaissez un peu Terraform, vous êtes sûrement familier avec le terme [_State_](https://developer.hashicorp.com/terraform/language/state), qui correspond en fait à l'état actuel de votre infrastructure, et qui permet à Terraform de savoir quelles modifications seront à prévoir si vous venez à modifier vos fichiers Terraform. Ce _State_ est représenté par un fichier : **terraform.tfstate**.

Par défaut, Terraform stocke ce fichier en local sur votre machine, mais recommande d'utiliser un _backend storage_ (comprenez : "stockez ce fichier ailleurs bon sang !").

Évidemment, Terraform vous propose en premier la solution HashiCorp : Terraform Cloud. En créant un compte, vous pourrez gratuitement utiliser leur backend pour stocker vos fichiers de state. C'est tout naturellement ce que j'ai fait il y a quelques années.

# La fin de Terraform Cloud

Jusqu'à cette semaine, où j'ai reçu ce mail d'HashiCorp.

![Mail de Terraform annonçant la fin du plan Free de Terraform Cloud](/img/moving-away-from-terraform-cloud/terraform-mail-free-plan-expiration.png)

Aïe ! Il fallait s'en douter, toutes les bonnes choses ont une fin ! L'option gratuite de l'époque n'existera bientôt plus, et il me faut donc faire un choix : mettre à jour mon "plan" HashiCorp, ou aller stocker mes states ailleurs.

En regardant de plus près [leurs offres actuelles](https://developer.hashicorp.com/terraform/cloud-docs/overview), HashiCorp propose encore une version gratuite, bien que limitée dans le nombre de ressources pouvant être déployées (500 aujourd'hui). C'est une offre assez généreuse, mais ne sachant pas comment celle-ci pourra évoluer, je prends la décision de déménager mes States une bonne fois pour toutes.

Adieu, Terraform Cloud !

# Une alternative pour stocker vos states

Heureusement pour moi, il existe bien des moyens pour stocker son state Terraform, et ce grâce au [Remote State](https://developer.hashicorp.com/terraform/language/state/remote).

Pour faire simple, il suffit de dire à Terraform où sera stocké votre fichier de state. On utilise pour cela [le block `backend`](https://developer.hashicorp.com/terraform/language/backend).

Il en existe une bonne poignée, mais possédant un compte AWS sur lequel je déploie toutes mes ressources, je me dirige tout naturellement vers le backend S3.

Voici par exemple comment configurer un backend S3 avec Terraform.

```terraform
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key/terraform.tfstate"
    region = "eu-west-1"
  }
}
```

Maintenant qu'une alternative a été trouvée, il est temps de passer à la migration !

# Migration du state vers S3

Je vais prendre en exemple la migration du state dont je me sers pour déployer ce blog.

Actuellement, si on regarde [mon workflow GitHub Actions de déploiement](https://github.com/antoinedelia/cloud-optimist/blob/4f8f95c177c490e3383c8b554e8d8ca4b3df249b/.github/workflows/main.yml#L28-L33), on voit que je m'authentifie avec un token à mon compte Terraform Cloud. Cette partie-là n'aura plus de raison d'exister (du  moins pour les credentials, il faudra toujours initialiser la CLI Terraform).

Ensuite, il va falloir créer un bucket S3 qui contiendra les futurs fichiers de state.

Enfin, il faudra rajouter un block `backend` à mon projet afin d'indiquer à Terraform de ne plus utiliser Terraform Cloud, mais bien S3 lorsqu'il viendra utiliser le state.

Attention, nous n'avons pas encore fini ! Car si je laisse ce bucket vide, la prochaine fois que j'essaierai de déployer mon blog, Terraform viendra se baser sur un state... inexistant ! Et pensera donc qu'aucune ressource n'a encore été déployée sur mon compte AWS. Terraform essaiera ainsi de recréer des ressources déjà existantes.

La dernière étape sera donc de récupérer le fichier de state de mon projet de blog, et de le déplacer dans mon bucket S3.

![Téléchargement du Terraform State dans Terraform Cloud](/img/moving-away-from-terraform-cloud/downloading_terraform_state.png)

Je dois ensuite m'assurer que les informations que j'ai fournies dans le block `backend` correspondent bien à la réalité.

Une fois tout cela prêt, il est temps de tester et de déployer tout ça !

J'ai volontairement omis quelques étapes de cette migration (des variables de workspace à migrer, l'utilisation de GitHub Secrets pour le nom du bucket S3, l'ajout des credentials AWS dans la GitHub Actions, ...) pour rendre cet article plus concis. Si vous voulez en voir plus, rendez-vous dans la [Pull Request que j'ai ouverte](https://github.com/antoinedelia/cloud-optimist/pull/116) pour réaliser cette migration.

Si tout s'est passé comme prévu, vous devriez voir apparaitre la phrase `No changes. Your infrastructure matches the configuration.` lors de votre `terraform plan` !

# Conclusion

Il est toujours pénible de devoir réaliser des migrations sur des infrastructures qui sont déjà en place. Mais avec un peu de temps, et avec une bonne volonté, c'est le genre de tâche qui ne prend au final que quelques heures.

Alors, n'attendez pas le dernier moment, et lancez-vous !