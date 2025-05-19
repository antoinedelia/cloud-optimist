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

L'un des avantages les plus concrets du tagging est la visibilité qu'il apporte sur vos dépenses. AWS Cost Explorer est l'outil de prédilection pour cela.

Une fois vos ressources correctement taguées (par exemple, avec le tag `Project` ou `CostCenter`), vous devez activer ces tags pour l'allocation des coûts dans la console de gestion de la facturation AWS (Billing and Cost Management Dashboard -> Cost Allocation Tags). Attention, il peut y avoir un délai avant que les tags activés n'apparaissent dans Cost Explorer.

Une fois activés, vous pouvez :
* Filtrer les rapports par tag : Dans Cost Explorer, vous pouvez filtrer vos coûts par la valeur d'un tag spécifique. Par exemple, afficher uniquement les coûts liés au `Project=MonSuperProjetCRM`.
* Grouper les coûts par tag : Vous pouvez également choisir de grouper vos dépenses par clé de tag. Cela vous donnera une vue d'ensemble de la répartition des coûts entre les différents projets, environnements, etc.
* Créer des budgets basés sur les tags : Avec AWS Budgets, vous pouvez définir des seuils d'alerte pour les coûts associés à des tags spécifiques, vous aidant à éviter les mauvaises surprises.

Cette capacité à disséquer votre facture AWS par tags transforme la gestion des coûts d'une corvée obscure en un exercice transparent et contrôlable. C'est un must pour toute organisation soucieuse de son budget Cloud.

# Retrouver ses Petits : Les Outils à Votre Service
Maintenant que l'on est convaincu de l'utilité des tags, comment fait-on pour lister nos ressources en fonction de ces précieuses étiquettes ?

## AWS Resource Explorer : L'Exploration Visuelle
Si vous n'êtes pas encore familier avec AWS Resource Explorer, c'est le moment de le découvrir ! Ce service, relativement récent, vous permet de rechercher et de découvrir vos ressources AWS à travers toutes les régions de votre compte, en utilisant une interface simple, un peu comme un moteur de recherche.

L'avantage principal de Resource Explorer est sa capacité à vous donner une vue unifiée. Plus besoin de sauter de région en région. Vous activez l'indexation, et ensuite, vous pouvez rechercher vos ressources par nom, ID, et bien sûr... par tag !

C'est un excellent outil pour :
* Avoir une vue d'ensemble rapide.
* Explorer visuellement les ressources associées à un tag spécifique.
* Identifier rapidement des ressources sans avoir à scripter.

Pour l'utiliser, activez-le dans les régions souhaitées (ou toutes), laissez-le indexer vos ressources, puis utilisez la barre de recherche avec une syntaxe comme tag:Project=MonSuperProjet ou tag:Environment=Production.

## AWS CLI : La Puissance de la Ligne de Commande
Pour ceux qui, comme moi, aiment avoir la main via la ligne de commande, ou qui ont besoin d'automatiser ces recherches, l'AWS CLI reste une alliée de choix. Plus précisément, c'est le service resourcegroupstaggingapi qui va nous intéresser.

La commande clé est get-resources. Voici un exemple typique pour lister les ARN (Amazon Resource Names) de toutes les ressources ayant le tag Project avec la valeur mon-projet :

```sh
aws resourcegroupstaggingapi get-resources \
    --tag-filters "Key=Project,Values=mon-projet" \
    | jq "[.ResourceTagMappingList[].ResourceARN]"
```

Décortiquons un peu :

* `aws resourcegroupstaggingapi get-resources` : C'est l'appel à l'API.
* `--tag-filters "Key=Project,Values=mon-projet"` : C'est ici qu'on spécifie notre filtre. On cherche le tag Project qui a la valeur mon-projet. Vous pouvez ajouter plusieurs filtres.
* `| jq "[.ResourceTagMappingList[].ResourceARN]"` : jq est un outil formidable pour manipuler du JSON en ligne de commande. Ici, on l'utilise pour extraire proprement la liste des ARN des ressources trouvées.

Cette commande est extrêmement puissante car vous pouvez l'intégrer dans des scripts pour :
* Générer des rapports réguliers sur les ressources par projet.
* Détecter automatiquement les ressources qui ne respectent pas votre politique de tagging.
* Combiner avec d'autres commandes AWS CLI pour effectuer des actions sur les ressources listées.

Par exemple, pour trouver les ressources non taguées avec une clé Project spécifique, c'est un peu plus indirect, mais vous pourriez lister toutes les ressources puis filtrer celles qui n'ont pas ce tag, ou utiliser Resource Explorer avec une requête négative si supportée pour ce cas. Souvent, on se concentre sur les ressources qui ont certains tags pour vérifier la conformité ou l'inventaire. Pour les "orphelines", une approche peut être de lister toutes les ressources d'un type (ex: toutes les EC2) et de vérifier manuellement ou par script celles qui manquent des tags essentiels.

# Automatiser le Nettoyage : Une Lambda à la Rescousse (Avec Prudence !)

Identifier les ressources non taguées, c'est bien. Les nettoyer automatiquement, c'est encore mieux... mais cela demande une extrême prudence ! Une suppression ou un arrêt automatisé mal configuré peut avoir des conséquences désastreuses.

Cela dit, pour des actions moins destructrices (comme stopper des instances EC2 de développement non taguées après une certaine période, ou simplement notifier une équipe), une fonction Lambda peut être très utile.

L'idée serait d'avoir une Lambda, déclenchée régulièrement (par exemple, via Amazon EventBridge Scheduler), qui utilise l'API `resourcegroupstaggingapi` pour lister les ressources. Elle vérifierait ensuite l'absence de tags critiques (comme `Project` ou `Owner`). Si une ressource est jugée "orpheline" selon vos critères :
* Pour commencer (et pour la sécurité) : Logguez simplement l'information dans CloudWatch Logs ou envoyez une notification (SNS, Slack via un webhook, etc.).
* Avec plus de confiance (et de tests !) : Vous pourriez envisager des actions comme stopper une instance EC2 (si vous êtes sûr qu'elle n'est pas critique et qu'elle correspond à des critères précis, par exemple, un tag `Environment=dev` manquant le tag `Project`). La suppression automatique est rarement recommandée sans de multiples garde-fous et validations humaines.

Je vous fournirai un exemple de script Python pour une telle Lambda dans un instant. Rappelez-vous que ce script sera un point de départ et devra être adapté et testé minutieusement dans un environnement de non-production avant toute utilisation sur des ressources réelles.

# Conclusion

Vous l'aurez compris, une stratégie de tagging rigoureuse n'est pas une option, c'est une nécessité pour opérer sereinement sur AWS. Que vous préfériez la convivialité d'AWS Resource Explorer pour une exploration rapide ou la flexibilité de l'AWS CLI pour des analyses plus poussées et de l'automatisation, AWS vous donne les moyens de tirer parti de vos tags.

Alors, un petit conseil : si ce n'est pas déjà fait, définissez une politique de tagging claire dans votre organisation, appliquez-la, et utilisez ces outils pour vérifier régulièrement que tout est en ordre. Votre DSI (et votre portefeuille) vous remercieront !
