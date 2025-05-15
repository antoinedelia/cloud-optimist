---
title: "Pourquoi tagger vos ressources AWS est indispensable ?"
date: 2025-05-24T07:30:00+02:00
author: Antoine Delia
draft: true
tags:
    - AWS
categories: [ AWS ]
image: aws_tagging.jpeg
---

# Introduction

Plus on déploie de services sur AWS, plus notre console peut ressembler à une jungle luxuriante mais un peu... désordonnée. Retrouver rapidement quelles ressources appartiennent à quel projet, ou identifier celles qui n'ont pas été correctement nettoyées après un PoC, peut vite devenir un casse-tête. Et ne parlons même pas de la ventilation des coûts ! Heureusement, il existe une pratique simple mais incroyablement puissante : le tagging (ou étiquetage, si on veut franciser).

Dans cet article, on va voir pourquoi une bonne stratégie de tags est cruciale et comment deux outils AWS peuvent vous aider à y voir plus clair : AWS Resource Explorer et la bonne vieille AWS CLI.

# Pourquoi les Tags Sont Vos Meilleurs Amis sur AWS ?

Imaginez des étiquettes sur des boîtes de déménagement. Sans elles, impossible de savoir ce qu'il y a dedans ou à quelle pièce elles appartiennent. Les tags sur AWS, c'est pareil ! Un tag est une simple paire clé-valeur que vous assignez à vos ressources (instances EC2, buckets S3, bases de données RDS, etc.).

Une bonne stratégie de tagging vous permet notamment de :

1. Identifier les Ressources Orphelines : C'est le grand classique. Une ressource sans tag Project ou Owner ? Il y a de fortes chances qu'elle ait été oubliée et qu'elle consomme des ressources (et donc de l'argent) pour rien. Lister les ressources non taguées (ou mal taguées) est une première étape essentielle pour faire le ménage.
2. Ventiler les Coûts : En taguant vos ressources avec un identifiant de projet, de centre de coût, ou d'équipe, vous pouvez ensuite utiliser AWS Cost Explorer pour filtrer vos dépenses et comprendre précisément quels projets consomment le plus. Indispensable pour la refacturation interne ou simplement pour optimiser votre budget.
3. Automatiser des Actions : Les tags peuvent servir de déclencheurs pour des scripts d'automatisation (par exemple, sauvegarder toutes les instances avec le tag Backup=Daily).
4. Gérer les Accès et la Sécurité : Les politiques IAM peuvent utiliser les tags pour accorder des permissions granulaires.

Bref, taguer, c'est la base d'une bonne gouvernance Cloud.

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

# Conclusion

Vous l'aurez compris, une stratégie de tagging rigoureuse n'est pas une option, c'est une nécessité pour opérer sereinement sur AWS. Que vous préfériez la convivialité d'AWS Resource Explorer pour une exploration rapide ou la flexibilité de l'AWS CLI pour des analyses plus poussées et de l'automatisation, AWS vous donne les moyens de tirer parti de vos tags.

Alors, un petit conseil : si ce n'est pas déjà fait, définissez une politique de tagging claire dans votre organisation, appliquez-la, et utilisez ces outils pour vérifier régulièrement que tout est en ordre. Votre DSI (et votre portefeuille) vous remercieront !
