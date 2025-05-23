---
title: "Pourquoi taguer vos ressources AWS est indispensable ?"
date: 2025-05-24T07:30:00+02:00
author: Antoine Delia
draft: true
tags:
    - AWS
categories: [ AWS ]
image: aws_tagging.jpeg
---

# Introduction

Plus on déploie de services sur AWS, plus on commence à s'y perdre. Au début, on connaît par coeur tous les services qu'on utilise, le nombre de Lambdas ou d'EC2 qui sont lancées. Mais petit à petit, il est facile de ne plus savoir où donner de la tête, surtout lorsque différents projets s'accumulent. Retrouver rapidement quelles ressources appartiennent à quel projet, ou identifier celles qui n'ont pas été correctement nettoyées après un PoC, tout cela peut vite devenir un casse-tête. Et c'est sans parler de la vision des coûts !

Heureusement, il existe une pratique simple mais incroyablement puissante : le tagging.

Dans cet article, j'aimerai vous montrer qu'une bonne stratégie de tags est cruciale. Nous aurons également l'occasion de découvrir un service AWS fait pour ça : AWS Resource Explorer.

A vos marques. Prêt ? Taguez !

# Pourquoi les tags sont-ils utiles ?

Imaginez des étiquettes sur des boîtes de déménagement. Sans elles, impossible de savoir ce qu'il y a dedans ou à quelle pièce elles appartiennent. Les tags sur AWS, c'est pareil ! Un tag est une information (sous la forme clé-valeur) que vous assignez à vos ressources (instances EC2, buckets S3, bases de données RDS, etc.).

Une bonne stratégie de tagging vous permet notamment de :

1. Identifier des ressources orpheline : C'est le grand classique. Une ressource sans tag `Project` ou `Owner` ? Il y a de fortes chances qu'elle ait été oubliée et qu'elle consomme des ressources (et donc de l'argent) pour rien. Lister les ressources non taguées (ou mal taguées) est une première étape essentielle pour faire le ménage.
2. Ventiler les Coûts : En taguant vos ressources avec un identifiant de projet, de centre de coût, ou d'équipe, vous pouvez ensuite utiliser AWS Cost Explorer pour filtrer vos dépenses et comprendre précisément quels projets consomment le plus. Indispensable pour la refacturation interne ou simplement pour optimiser votre budget.
3. Automatiser des Actions : Les tags peuvent servir de déclencheurs pour des scripts d'automatisation (par exemple, sauvegarder toutes les instances avec le tag `Backup=Daily`).
4. Gérer les Accès et la Sécurité : Les politiques IAM peuvent utiliser les tags pour accorder des permissions granulaires.

Bref, taguer, c'est la base d'une bonne gouvernance Cloud. Pour plus de détails, je vous invite à consulter le [guide de tagging proposé par AWS](https://aws.amazon.com/solutions/guidance/tagging-on-aws/).

# Quels tags utiliser ?

On peut fort heureusement associer plusieurs tags à une même ressource. Mais cela pose la question : combien de tags sont nécessaires ?

Cela va dépendre de votre entreprise et de chaque projet, mais globalement, il y a des tags qui ne font pas de mal, peu importe votre situation :
* **Project** : Le nom du projet lié à la ressource. Générallement, le nom du repository GitHub fait l'affaire
* **Environment** : L'environnement désiré (dev, val, prod, ...). Même si vous avez des comptes AWS cloisonnés, cela vous permettra d'identifier si une ressource s'est perdue durant un déploiement
* **Owner** : L'owner de la ressource. Cela pourrait être une personne, mais plus idéallement une équipe (frontend, backend, security, ...)

Selon votre usage, vous aurez sûrement d'autres idées de tags, mais avec ceux ci-dessus, ce sera déjà un bon début !

# Suivre les coûts grâce aux tags

L'un des avantages les plus concrets du tagging est la visibilité qu'il apporte sur vos dépenses. [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) est l'outil de prédilection pour cela.

Une fois vos ressources correctement taguées (par exemple, avec le tag `Project`), vous devez activer ces tags pour l'allocation des coûts dans la console de gestion de la facturation AWS (Billing and Cost Management -> Cost Organization -> Cost Allocation Tags). Attention, il peut y avoir un délai avant que les tags activés n'apparaissent dans Cost Explorer.

Une fois activés, vous pouvez :
* Filtrer par tag : Dans Cost Explorer, vous pouvez filtrer vos coûts par la valeur d'un tag spécifique.
* Grouper par tag : Vous pouvez également choisir de grouper vos dépenses par tag. Cela vous donnera une vue d'ensemble de la répartition des coûts entre les différents projets, environnements, etc.
* Créer des budgets basés sur les tags : Avec AWS Budgets, vous pouvez définir des seuils d'alerte pour les coûts associés à des tags spécifiques, vous aidant à éviter les mauvaises surprises.

![Exemple de filtrage par tag](/img/why-tagging-your-aws-resources-is-a-must/cost_explorer_tag_filtering.png)
_Exemple de filtrage par tag pour mon blog : les coûts sont minimes_

Cette capacité à disséquer votre facture AWS par tags transforme la gestion des coûts d'une corvée obscure en un exercice transparent et contrôlable. C'est un must pour toute organisation soucieuse de son budget Cloud. Vous pourrez désormais rajouter _FinOps_ dans votre bio LinkedIn !

# Garder un œil sur les ressources déployées

Maintenant que l'on est convaincu de l'utilité des tags, comment fait-on pour lister toutes les ressources qui utilisent un tag précis ? Nous allons le voir ensemble avec une partie dans la console AWS, et une partie qui se passera dans le terminal (pour tous les geeks qui lisent cet article !).

## AWS Resource Explorer : L'Exploration Visuelle
Si vous n'êtes pas encore familier avec [AWS Resource Explorer](https://aws.amazon.com/resourceexplorer/), c'est le moment de le découvrir ! Ce service, relativement récent, vous permet de rechercher et de découvrir vos ressources AWS à travers toutes les régions de votre compte, en utilisant une interface simple, un peu comme un moteur de recherche.

L'avantage principal de Resource Explorer est sa capacité à vous donner une vue unifiée. Plus besoin de sauter de région en région. Vous activez l'indexation, et ensuite, vous pouvez rechercher vos ressources par nom, ID, et bien sûr... par tag !

C'est un excellent outil pour :
* Avoir une vue d'ensemble rapide.
* Explorer visuellement les ressources associées à un tag spécifique.
* Identifier rapidement des ressources sans avoir à coder quoi que ce soit.

Pour l'utiliser, activez-le dans les régions souhaitées (ou toutes), laissez-le indexer vos ressources, puis utilisez la barre de recherche avec une syntaxe comme `tag.key:Project tag.value:Cloud*`.

![Recherche des ressources par tag](/img/why-tagging-your-aws-resources-is-a-must/resource_explorer_search_tags)
_Exemple de recherche par tag pour mon blog : seulement trois ressources permettent de gérer ce blog !_


## AWS CLI : Pour ceux qui aiment la CLI
Pour ceux qui, comme moi, aiment avoir la main via la ligne de commande, ou qui ont besoin d'automatiser ces recherches, l'[AWS CLI](https://aws.amazon.com/cli/) reste une alliée de choix. Plus précisément, c'est le service [resourcegroupstaggingapi](https://docs.aws.amazon.com/cli/latest/reference/resourcegroupstaggingapi/) qui va nous intéresser.

La commande clé est [get-resources](https://docs.aws.amazon.com/cli/latest/reference/resourcegroupstaggingapi/get-resources.html). Voici un exemple typique pour lister les ARN de toutes les ressources ayant le tag Project avec la valeur "Cloud Antoine Delia" :

```sh
aws resourcegroupstaggingapi get-resources \
    --tag-filters "Key=Project,Values=Cloud Antoine Delia" \
    | jq "[.ResourceTagMappingList[].ResourceARN]"
```

Ce qui nous donne : 
```json
[
  "arn:aws:s3:::antoiXXXXXXXXXXXXX"
]
```

Décortiquons un peu :

* `aws resourcegroupstaggingapi get-resources` : C'est l'appel à l'API, jusqu'ici, tout va bien.
* `--tag-filters "Key=Project,Values=Cloud Antoine Delia"` : C'est ici qu'on spécifie notre filtre. On cherche le tag Project qui a la valeur "Cloud Antoine Delia". Vous pouvez ajouter plusieurs filtres.
* `| jq "[.ResourceTagMappingList[].ResourceARN]"` : [jq](https://jqlang.org/) est un outil formidable pour manipuler du JSON en ligne de commande. Ici, on l'utilise pour extraire proprement la liste des ARN des ressources trouvées.

> Eh attends une minute ! Dans la console, tu nous montres trois ressources, et là il n'y en a plus qu'une ! Elle est où l'arnaque ?

Habillement remarqué ! Il faut savoir que lorsque vous faites votre appel à l'API, vous utilisez une region par défaut. Hors, si vous avez des ressources dans diverses régions, il faudra le spécifier. Ainsi, si l'on rajoute `--region us-east-1` juste avant le pipe jq, on obtient bien nos deux ressources manquantes.

```json
[
  "arn:aws:acm:us-east-1:6XXXXXXXXXXX0:certificate/f4ca3b13-XXXXXXXXXXXXX",
  "arn:aws:cloudfront::6XXXXXXXXXXX0:distribution/ERSXXXXXXXXXX"
]
```

Outre ce détail qu'il ne vous faudra pas oublier, cette commande est extrêmement puissante car vous pouvez l'intégrer dans des scripts pour :
* Générer des rapports réguliers sur les ressources par projet.
* Détecter automatiquement les ressources qui ne respectent pas votre politique de tagging.
* Combiner avec d'autres commandes AWS CLI pour effectuer des actions sur les ressources listées.

Par exemple, vous pourriez ainsi lister toutes vos ressources d'un certain type (ex: toutes vos instances EC2) et de vérifier celles à qui il manque des tags essentiels.

Et si vous vous demandez si AWS n'offre pas déjà un service pour ça... C'est le cas ! Mais nous en parlerons dans un futur article (pour les curieux, je veux parler d'[AWS Config](https://aws.amazon.com/config/)).

# Conclusion

Vous l'aurez compris, une stratégie de tagging rigoureuse n'est pas une option, c'est une nécessité pour opérer sereinement sur AWS. Que vous préfériez la convivialité d'AWS Resource Explorer pour une exploration rapide ou la flexibilité de l'AWS CLI pour des analyses plus poussées et saupoudrer le tout d'automatisation, AWS vous donne les moyens de tirer parti de vos tags.

Alors, un petit conseil : si ce n'est pas déjà fait, définissez une politique de tagging claire dans votre organisation, appliquez-la, et utilisez ces outils pour vérifier régulièrement que tout est en ordre. Vous m'en remercierez plus tard !
