---
title: "La Phase d'INIT des Lambdas AWS Bientôt Facturée - Faut-il s'alarmer ?"
date: 2025-05-20T07:30:00+01:00
author: Antoine Delia
draft: true
tags:
    - AWS
categories: [ AWS ]
image: lambda-init-billing.jpeg
---
Si comme moi vous utilisez AWS Lambda pour héberger une partie de vos applications ou de vos APIs, vous savez à quel point ce service peut être pratique et économique. On configure notre fonction, on pousse notre code, et hop, ça tourne sans qu'on ait à se soucier des serveurs ! Mais attention, une petite ligne sur votre facture AWS pourrait bientôt changer, et il vaut mieux être au courant.

AWS a annoncé une modification dans la manière dont la phase d'initialisation (la fameuse phase `INIT`) des fonctions Lambda est facturée. **À partir du 1er août 2025**, cette phase sera systématiquement incluse dans le calcul de la durée facturée, et ce, pour *toutes* les configurations de fonctions Lambda.

Jusqu'à présent, si vous utilisiez des fonctions "on-demand" packagées en ZIP avec des runtimes managés par AWS (comme Python, Node.js, etc.), la durée de cette phase `INIT` n'était pas facturée. C'était un petit "cadeau" qui va donc disparaître. Ce changement vise à standardiser la facturation, car les fonctions utilisant des runtimes custom, la Concurrence Provisionnée (Provisioned Concurrency) ou des images conteneur (OCI) voyaient déjà cette phase `INIT` facturée.

AWS précise que pour la plupart des utilisateurs, l'impact sur la facture globale sera minime, car la phase `INIT` ne se produit que lors des "démarrages à froid" (cold starts), qui représentent généralement une petite fraction des invocations totales. Mais comme on dit, "mieux vaut prévenir que guérir" ! Dans cet article, on va décortiquer ce changement, voir comment vérifier l'impact sur vos propres fonctions et explorer des pistes pour optimiser tout ça.


### **Comprendre le Cycle de Vie d'une Fonction Lambda**

Avant de plonger dans la facturation, rappelons rapidement comment vit une fonction Lambda. Son cycle de vie se compose de trois phases principales :



1. **INIT (Initialisation) :** C'est l'étape du "démarrage à froid". Quand une nouvelle instance (un nouvel environnement d'exécution) de votre fonction doit être créée pour répondre à une requête, Lambda prépare le terrain. Cette phase dure au maximum 10 secondes.
2. **INVOKE (Invocation) :** C'est là que votre code métier (le handler de votre fonction) est exécuté pour traiter la requête.
3. **SHUTDOWN (Arrêt) :** Quand l'environnement d'exécution n'est plus utilisé pendant un certain temps, Lambda peut le terminer pour libérer les ressources.

Pendant la phase `INIT`, Lambda fait plusieurs choses :



* Récupère votre code (depuis S3 pour un ZIP, ou ECR pour une image conteneur).
* Configure l'environnement avec la mémoire allouée, le runtime choisi, etc.
* Initialise les extensions éventuelles (`Extension INIT`).
* Démarre le runtime (`Runtime INIT`).
* Exécute le code statique de votre fonction (en dehors du handler, par exemple l'initialisation de variables globales ou de clients SDK) (`Function INIT`).
* Lance les "runtime hooks" avant checkpoint (si vous utilisez Lambda SnapStart).

Un point clé : la phase `INIT` ne se produit que lors d'un démarrage *à froid*. Si une requête arrive alors qu'un environnement d'exécution est déjà "chaud" (prêt et réutilisé), cette phase est sautée, et on passe directement à l'`INVOKE`. C'est ce qu'on appelle un "démarrage à chaud" (warm start), qui est bien plus rapide.


### **Le Changement de Facturation en Détail**

Actuellement, la facturation Lambda repose sur deux éléments :



* Le nombre de requêtes.
* La durée d'exécution de votre code, arrondie à la milliseconde supérieure. Le coût de cette durée dépend de la mémoire allouée à la fonction.

Jusqu'au 1er août 2025, pour les fonctions on-demand en ZIP avec runtime managé, la durée de la phase `INIT` n'était pas comptée dans la "Durée Facturée" (`Billed Duration`). On pouvait le voir dans les logs CloudWatch :

**Avant le 1er août 2025 :**

REPORT RequestId: xxxxx   Duration: 250.06 ms   Billed Duration: 251 ms   Memory Size: 1024 MB

Max Memory Used: 350 MB   Init Duration: 100.77 ms

Ici, même si l'`Init Duration` est de 100.77 ms, la `Billed Duration` (251 ms) ne prend en compte que la `Duration` (250.06 ms), arrondie à la milliseconde supérieure.

**Après le 1er août 2025 :** Avec la standardisation, la `Billed Duration` inclura la `Init Duration` pour ces fonctions :

REPORT RequestId: xxxxx   Duration: 250.06 ms   Billed Duration: 351 ms   Memory Size: 1024 MB

Max Memory Used: 350 MB   Init Duration: 100.77 ms

Maintenant, la `Billed Duration` (351 ms) correspond à la somme de `Duration` et `Init Duration` (250.06 ms + 100.77 ms = 350.83 ms), arrondie à la milliseconde supérieure.


### **Quel Impact Concret sur la Facture ? (Exemple)**

Prenons un exemple pour y voir plus clair. Imaginons une fonction Lambda en Python (runtime managé, package ZIP) configurée avec 1024 Mo de mémoire, déployée dans la région `eu-west-1` (Irlande).

Supposons :



* Elle reçoit 10 millions d'invocations par mois.
* Le taux de démarrage à froid est de 1% (ce qui est assez typique selon AWS), soit 100 000 démarrages à froid par mois.
* La durée moyenne de l'invocation (`Duration`) est de 250 ms.
* La durée moyenne de l'initialisation (`Init Duration`) est de 100 ms (lors des démarrages à froid).

Utilisons les tarifs de `eu-west-1` (peuvent varier légèrement) :



* Coût par requête : $0.20 par million de requêtes.
* Coût de la durée (x86) : $0.0000166667 par Go-seconde.

**Calcul du coût AVANT le 1er août 2025 :**



1. **Coût des requêtes :** 10 millions req * ($0.20 / 1 million req) = **$2.00**
2. **Coût de la durée :**
    * Invocations "à chaud" (9.9 millions) : Durée facturée = 250 ms.
    * Invocations "à froid" (100 000) : Durée facturée = 250 ms (INIT non facturée).
    * Durée facturée totale (secondes) : (9 900 000 * 0.250 s) + (100 000 * 0.250 s) = 2 475 000 s + 25 000 s = 2 500 000 s.
    * Go-secondes totaux : 2 500 000 s * (1024 Mo / 1024 Mo) = 2 500 000 Go-s.
    * Coût Durée : 2 500 000 Go-s * $0.0000166667/Go-s = **$41.67**
3. **Coût total mensuel (Avant) :** $2.00 + $41.67 = **$43.67**

**Calcul du coût APRÈS le 1er août 2025 :**



1. **Coût des requêtes :** **$2.00** (inchangé)
2. **Coût de la durée :**
    * Invocations "à chaud" (9.9 millions) : Durée facturée = 250 ms.
    * Invocations "à froid" (100 000) : Durée facturée = 250 ms (`Duration`) + 100 ms (`Init Duration`) = 350 ms.
    * Durée facturée totale (secondes) : (9 900 000 * 0.250 s) + (100 000 * 0.350 s) = 2 475 000 s + 35 000 s = 2 510 000 s.
    * Go-secondes totaux : 2 510 000 s * (1024 Mo / 1024 Mo) = 2 510 000 Go-s.
    * Coût Durée : 2 510 000 Go-s * $0.0000166667/Go-s = **$41.83**
3. **Coût total mensuel (Après) :** $2.00 + $41.83 = **$43.83**

**Conclusion de l'exemple :** Dans ce scénario précis, l'augmentation est de **$0.16 par mois**. C'est effectivement minime et confirme la communication d'AWS. Cependant, l'impact *réel* dépendra fortement de :



* La mémoire allouée à vos fonctions (plus de mémoire = coût par ms plus élevé).
* La durée réelle de votre phase `INIT` (peut être bien supérieure à 100 ms si vous chargez beaucoup de dépendances).
* Votre taux de démarrage à froid (peut être plus élevé si le trafic est très irrégulier).

Il est donc judicieux de vérifier vos propres chiffres !


### **Comment Surveiller Votre Phase INIT et Estimer l'Impact ?**

Heureusement, AWS nous donne les outils pour ça :



1. **CloudWatch Metrics :** Vous pouvez suivre la métrique `initDuration` pour chacune de vos fonctions Lambda.
2. **CloudWatch Logs :** Chaque ligne `REPORT` dans les logs de votre fonction inclut la valeur `Init Duration: xxx ms` lorsque la phase INIT a eu lieu (démarrage à froid).
3. **CloudWatch Logs Insights :** Pour une analyse plus globale, vous pouvez utiliser cette requête Logs Insights. Elle vous aidera à estimer la part de la durée `INIT` qui n'était pas facturée jusqu'à présent pour les fonctions concernées :

filter @type = "REPORT" and @billedDuration &lt; (@duration + @initDuration)

| stats sum((@memorySize/1000000/1024) * (@billedDuration/1000)) as BilledGBs,

sum((@memorySize/1000000/1024) * ((ceil(@duration + @initDuration) - @billedDuration)/1000)) as UnbilledInitGBs,

(UnbilledInitGBs / (UnbilledInitGBs + BilledGBs)) * 100 as RatioPercent

Cette requête vous donnera trois informations clés pour les groupes de logs sélectionnés :



* `BilledGBs` : Le total de Go-secondes actuellement facturé.
* `UnbilledInitGBs` : Le total de Go-secondes consommés pendant la phase `INIT` qui n'étaient *pas* facturés auparavant (pour les fonctions concernées par le changement).
* `RatioPercent` : Le pourcentage que représentent ces Go-secondes `INIT` non facturés par rapport au total des Go-secondes consommés. Cela vous donne une idée directe de l'augmentation potentielle en pourcentage de votre coût de durée Lambda.

En utilisant ces outils, vous pouvez identifier les fonctions qui ont les plus longues durées d'`INIT` et évaluer l'impact financier réel du changement pour votre compte.


### **Comprendre et Optimiser la Phase INIT**

Maintenant qu'on sait que cette phase `INIT` va nous coûter quelques centimes (ou plus !), comment peut-on la maîtriser, voire la réduire ?

Rappelons que le code dans la phase `INIT` (le code global, hors du handler) n'est exécuté *que* pendant les démarrages à froid. C'est donc l'endroit idéal pour faire des opérations d'initialisation coûteuses qui pourront être réutilisées par les invocations suivantes (démarrages à chaud) :



* Importer des librairies ou dépendances lourdes.
* Établir des connexions à d'autres services AWS (S3, DynamoDB, etc.) via les SDKs.
* Créer des pools de connexions à des bases de données.
* Récupérer des paramètres ou des secrets depuis Systems Manager Parameter Store ou Secrets Manager.

Mettre ce code dans la phase `INIT` plutôt que dans le handler réduit la latence des invocations "à chaud", car le travail est déjà fait. Mais attention, cela augmente la durée de la phase `INIT` (et donc potentiellement son coût depuis le 1er août 2025). Il faut trouver le bon équilibre.

Qu'est-ce qui influence la durée de la phase `INIT` ?



1. **La taille de votre package de déploiement :** Plus votre ZIP ou image conteneur est gros (beaucoup de dépendances, de librairies, de layers...), plus le temps de téléchargement initial sera long.
2. **La quantité de code d'initialisation :** Le travail que vous faites réellement dans la partie globale de votre code.
3. **La performance des services externes :** Le temps nécessaire pour établir des connexions, par exemple.

Voici quelques stratégies d'optimisation :


#### **1. Optimiser la Taille du Package**

C'est souvent le levier le plus simple. Réduisez la taille de votre code :



* N'incluez que les dépendances strictement nécessaires.
* Utilisez des outils comme `esbuild` (pour JavaScript/TypeScript) ou des techniques de "tree shaking" pour minifier et ne garder que le code utile.
* Pour le SDK AWS en JavaScript, privilégiez la v3 qui permet d'importer uniquement les clients des services dont vous avez besoin. (Pour en savoir plus, AWS a un article :[ Reduce Lambda cold start times: migrate to AWS SDK for JavaScript v3](https://aws.amazon.com/blogs/compute/reduce-lambda-cold-start-times-migrate-to-aws-sdk-for-javascript-v3/)).

Moins de code à télécharger = phase `INIT` plus courte = moins de coût et démarrage à froid plus rapide.


#### **2. Utiliser Stratégiquement la Phase INIT**

Profitez de cette phase pour pré-calculer ou télécharger des données statiques qui serviront à toutes les invocations suivantes. Par exemple, charger une table de lookup depuis S3 ou DynamoDB une seule fois pendant l'`INIT` plutôt qu'à chaque invocation dans le handler.


#### **3. Lambda SnapStart**

Disponible pour les runtimes **Java, .NET et Python**, SnapStart est une fonctionnalité très intéressante pour combattre les démarrages à froid. Quand vous l'activez, Lambda prend un "snapshot" (un instantané) de l'environnement d'exécution initialisé *après* la première phase `INIT`. Pour les démarrages à froid suivants, Lambda restaure ce snapshot au lieu de refaire toute la phase `INIT`.

Résultat : les démarrages à froid suivants sont beaucoup plus rapides, et la durée facturée de la phase `INIT` est considérablement réduite (voire éliminée pour ces démarrages suivants). C'est particulièrement efficace si votre phase `INIT` est longue à cause du chargement de frameworks lourds (comme Spring Boot en Java) ou de beaucoup de dépendances. Attention, votre code doit être compatible avec la restauration depuis un snapshot (quelques limitations existent, notamment sur l'unicité ou le caractère aléatoire lors de l'initialisation).


#### **4. Concurrence Provisionnée (Provisioned Concurrency - PC)**

Si votre application a un trafic prévisible ou si la latence des démarrages à froid est inacceptable, vous pouvez utiliser la Concurrence Provisionnée. Vous demandez à Lambda de garder un certain nombre d'environnements d'exécution pré-initialisés (chauds) en permanence.

Avantage : les requêtes arrivant sur ces instances provisionnées ne subissent *jamais* de démarrage à froid. La phase `INIT` est faite en amont, avant même la première requête. C'est idéal pour les applications sensibles à la latence.

Inconvénient : vous payez pour la durée pendant laquelle ces environnements sont provisionnés, *qu'ils reçoivent des requêtes ou non*. La phase `INIT` est d'ailleurs facturée lors de la pré-initialisation. D'un point de vue coût, la PC est généralement plus intéressante que le mode "on-demand" uniquement si votre fonction a un taux d'utilisation soutenu (AWS mentionne une rentabilité souvent meilleure au-dessus de 60% d'utilisation de la capacité provisionnée).


### **Conclusion**

Le changement de facturation de la phase `INIT` de Lambda qui arrive le **1er août 2025** est avant tout une standardisation. Pour la majorité des fonctions (on-demand, ZIP, runtimes managés), cela signifie que la durée de cette phase sera désormais ajoutée à la durée facturée lors des démarrages à froid.

Même si l'impact financier sera probablement faible pour beaucoup, c'est une excellente occasion de :



1. **Comprendre** le cycle de vie de vos fonctions Lambda et ce qui se passe pendant l'initialisation.
2. **Mesurer** la durée de la phase `INIT` de vos fonctions critiques grâce aux outils CloudWatch.
3. **Optimiser** cette phase si nécessaire, en réduisant la taille de vos packages, en utilisant SnapStart, ou en envisageant la Concurrence Provisionnée pour les cas d'usage appropriés.

N'attendez pas le mois d'août ! Utilisez la requête Logs Insights fournie pour avoir une estimation de l'impact dès maintenant. Cela vous permettra d'identifier les fonctions à optimiser en priorité et d'éviter toute mauvaise surprise sur votre facture AWS.

Alors, prêts à jeter un œil à vos logs et à optimiser vos phases `INIT` ? Happy optimizing !

[Source](https://aws.amazon.com/blogs/compute/aws-lambda-standardizes-billing-for-init-phase/)
