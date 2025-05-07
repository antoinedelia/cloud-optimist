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
# Introduction
Ah, les Lambdas. Probablement le service AWS que j'affectionne le plus ! En moins de temps qu'il ne faut pour le dire, elles permettent de créer un petit script ou carrément un backend API hosté dans le Cloud, et tout cela à moindre coût avec le "pay as you go". Mais cela serait-il trop beau pour être vrai ?

Il y a quelques jours, [AWS a annoncé une modification dans la manière dont la phase d'initialisation des Lambdas est facturée](https://aws.amazon.com/blogs/compute/aws-lambda-standardizes-billing-for-init-phase). **À partir du 1er août 2025**, cette phase sera systématiquement incluse dans le calcul de la durée facturée, et ce, pour *toutes* les Lambdas.

Si vous n'étiez pas au courant, sachez que jusqu'à présent, si vous utilisiez des fonctions Lambdas avec un code packagé en ZIP avec des runtimes managés par AWS (comme Python, Node.js, etc.), la durée de cette phase `INIT` n'était pas facturée. C'était un petit "cadeau" de la part d'AWS (plutôt sympa de leur part). Mais toutes les bonnes choses ont une fin, et il faudra maintenant payer ce temps d'initialisation de nos Lambdas.

Alors, cela va t'il rendre l'usage des Lambdas trop cher ? Et comment faire en sorte de réduire au maximum cette partie d'initialisation ? Je vous propose aujourd'hui de répondre à toutes ces questions !

# Comprendre le cycle de vie d'une Lambda

Avant de plonger dans la facturation, c'est l'occasion de se rappeler du [cycle de vie d'une Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html).

> Pour simplifier la lecture, je ne rentrerai pas dans les détails des [Lambda Extensions](https://docs.aws.amazon.com/lambda/latest/dg/lambda-extensions.html) et de [Lambda SnapStart](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html).

Cela se compose de trois phases principales :
1. **INIT :** C'est l'étape du "démarrage à froid" ou cold start. Quand une nouvelle instance de votre fonction doit être créée pour répondre à une requête, Lambda prépare le terrain. Cette phase dure au maximum 10 secondes.
2. **INVOKE :** C'est là que votre code (le handler de votre fonction) est exécuté pour traiter la requête.
3. **SHUTDOWN :** Quand l'environnement d'exécution n'est plus utilisé pendant un certain temps, la Lambda se "shutdown" pour libérer les ressources. Si une nouvelle requête arrive, la Lambda devra de nouveau passer par la phase d'INIT.

Pendant la phase `INIT`, [notre Lambda fait plusieurs choses](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html#runtimes-lifecycle-ib) :
* Récupère notre code (depuis S3 pour un ZIP, ou ECR pour une image Docker).
* Configure l'environnement avec la mémoire allouée, le runtime choisi, etc.
* Démarre le runtime (`Runtime INIT`).
* Exécute le code statique de votre fonction (tout ce qui est en dehors du handler, par exemple l'initialisation de variables globales ou de `boto3`) (`Function INIT`).

Le point clé à retenir de tout cela, c'est que la phase `INIT` ne se produit que lors d'un démarrage *à froid* (ce fameux cold start). Si une requête arrive alors qu'un environnement d'exécution est déjà "chaud" (prêt et réutilisé), cette phase est sautée, et on passe directement à l'`INVOKE`. C'est ce qu'on appelle un "démarrage à chaud" (warm start), qui est bien plus rapide.

> AWS ne communique pas sur son calcul pour passer une Lambda "warm" à "cold".

# Le changement de facturation en détail

Actuellement, [la facturation des Lambdas](https://aws.amazon.com/lambda/pricing/) repose sur deux éléments :
* Le nombre de requêtes.
* La durée d'exécution de votre code, arrondie à la milliseconde supérieure (le coût de cette durée dépend de la mémoire allouée à la fonction).

Jusqu'au 1er août 2025, pour ces fonctions en ZIP avec runtime managé, la durée de la phase `INIT` n'était pas comptée dans la "Durée Facturée" (`Billed Duration`). On pouvait le voir dans les logs CloudWatch :

```
# Avant le 1er août 2025
# Notez que la Billed Duration est l'arrondie au supérieur
# de la Duration sans tenir compte de la Init Duration
REPORT RequestId: xxxxx   Duration: 250.06 ms   Billed Duration: 251 ms   Init Duration: 100.77 ms

# Après le 1er août 2025
# La Billed Duration est maintenant l'arrondie au supérieur
# de la Duration + la Init Duration
REPORT RequestId: xxxxx   Duration: 250.06 ms   Billed Duration: 351 ms   Init Duration: 100.77 ms
```

Comme vous pouvez le voir, AWS prendra maintenant en compte votre Init Duration en plus de la Duration pour réaliser son calcul de la Billed Duration.

# Quel impact sur la facture ?

Alors tout ça, c'est bien beau, mais allons-nous tous finir ruiner par ce changement ?

Prenons un exemple pour y voir plus clair. Imaginons une Lambda en Python configurée avec 1024 Mo de mémoire, déployée dans la région `eu-west-1` (Irlande).

Supposons les points suivants :
* La Lambda reçoit 10 millions d'invocations par mois.
* Le taux de cold start est de 1% ([moyenne fournie par AWS](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html#cold-start-latency)), soit 100'000 démarrages à froid par mois.
* La durée moyenne de l'invocation (`Duration`) est de 3 secondes.
* La durée moyenne de l'initialisation (`Init Duration`) est de 1 seconde.
* Coût par requête : $0.20 par million de requêtes.
* Coût de la durée (x86) : $0.0000166667 par GB-seconde.

**Calcul du coût AVANT le 1er août 2025 :**

1. **Coût des requêtes :** 10 millions req * ($0.20 / 1 million req) = **$2.00**
2. **Coût de la durée :**
    * Invocations "à chaud" (9.9 millions) : Durée facturée = 3 secondes.
    * Invocations "à froid" (100 000) : Durée facturée = 3 secondes (INIT non facturée).
    * Durée facturée totale (secondes) : (9'900'000 * 3 s) + (100'000 * 3 s) = 29'700'000 secondes + 300'000 secondes = 30'000'000 secondes.
    * Go-secondes totaux : 30'000'000 secondes * (1024 Mo / 1024 Mo) = 30'000'000 Go-s.
    * Coût Durée : 30'000'000 Go-s * $0.0000166667/Go-s = **$500.00**
3. **Coût total mensuel (Avant) :** $2.00 + $500.00 = **$502.00**

**Calcul du coût APRÈS le 1er août 2025 :**

1. **Coût des requêtes :** **$2.00** (inchangé)
2. **Coût de la durée :**
    * Invocations "à chaud" (9.9 millions) : Durée facturée = 3 secondes.
    * Invocations "à froid" (100 000) : Durée facturée = 3 secondes (`Duration`) + 1 seconde (`Init Duration`) = 4 secondes.
    * Durée facturée totale (secondes) : (9'900'000 * 3 s) + (100'000 * 4 s) = 29'700'000 secondes + 400'000 secondes = 30'100'000 secondes.
    * Go-secondes totaux : 30'100'000 secondes * (1024 Mo / 1024 Mo) = 30'100'000 Go-s.
    * Coût Durée : 30'100'000 Go-s * $0.0000166667/Go-s = **$501.67**
3. **Coût total mensuel (Après) :** $2.00 + $501.67 = **$503.67**

**Conclusion :** Dans ce scénario précis, l'augmentation est seulement de **$1.67 par mois**. C'est effectivement minime, et cela confirme la communication d'AWS. Mais faites quand même attention, car l'impact *réel* dépendra fortement de :
* La mémoire allouée à vos Lambdas (plus de mémoire = coût par ms plus élevé).
* La durée réelle de votre phase `INIT`.
* Votre taux de cold start (peut être plus élevé si votre trafic est irrégulier).

Il est donc judicieux de vérifier avec vos propres chiffres !

Je vous mets ci-dessous un petit script qui vous permettra de rapidement tester cela de votre côté.

```python
def calculate_lambda_costs(
    total_invocations_per_month: int,
    cold_start_rate: float,
    average_invocation_duration_sec: float,
    average_init_duration_sec: float,
    allocated_memory_gb: float,
    cost_per_million_requests: float = 0.20,
    cost_per_gb_second: float = 0.0000166667,
):
    num_cold_starts = total_invocations_per_month * cold_start_rate
    num_warm_starts = total_invocations_per_month - num_cold_starts

    request_cost = (total_invocations_per_month / 1_000_000) * cost_per_million_requests

    # Duration cost BEFORE
    billed_duration_warm_starts_sec_before = num_warm_starts * average_invocation_duration_sec
    billed_duration_cold_starts_sec_before = num_cold_starts * average_invocation_duration_sec

    total_billed_duration_sec_before = billed_duration_warm_starts_sec_before + billed_duration_cold_starts_sec_before
    total_gb_seconds_before = total_billed_duration_sec_before * allocated_memory_gb / 1.024
    duration_cost_before = total_gb_seconds_before * cost_per_gb_second

    total_monthly_cost_before = request_cost + duration_cost_before

    # Duration cost AFTER
    billed_duration_warm_starts_sec_after = num_warm_starts * average_invocation_duration_sec
    billed_duration_cold_starts_sec_after = num_cold_starts * (average_invocation_duration_sec + average_init_duration_sec)

    total_billed_duration_sec_after = billed_duration_warm_starts_sec_after + billed_duration_cold_starts_sec_after
    total_gb_seconds_after = total_billed_duration_sec_after * allocated_memory_gb / 1.024
    duration_cost_after = total_gb_seconds_after * cost_per_gb_second

    total_monthly_cost_after = request_cost + duration_cost_after

    return total_monthly_cost_before, total_monthly_cost_after


def display_results(cost_before, cost_after):
    cost_difference = cost_after - cost_before
    print(f"\nMonthly cost increase: ${cost_difference:.2f}")
    if cost_difference > 0:
        percentage_increase = (cost_difference / cost_before) * 100 if cost_before > 0 else float("inf")
        print(f"Percentage increase: {percentage_increase:.2f}%")


if __name__ == "__main__":
    print("AWS Lambda Cost Calculator (before/after Init Duration pricing change)")
    print("Please enter the values for your scenario or press Enter to use default values.\n")
    default_invocations = 10_000_000
    default_cold_start_rate = 0.01  # 1%
    default_invocation_duration = 3.0  # seconds
    default_init_duration = 1.0  # seconds
    default_memory_gb = 1.024  # 1024 MB (1.024 GB)

    try:
        invocations_str = input(f"Total invocations per month (default: {default_invocations:,}): ")
        total_invocations_input = int(invocations_str) if invocations_str else default_invocations

        cold_start_rate_str = input(f"Cold start rate (e.g., 0.01 for 1%, default: {default_cold_start_rate}): ")
        cold_start_rate_input = float(cold_start_rate_str) if cold_start_rate_str else default_cold_start_rate

        invocation_duration_str = input(f"Average invocation duration in seconds (default: {default_invocation_duration}): ")
        invocation_duration_input = float(invocation_duration_str) if invocation_duration_str else default_invocation_duration

        init_duration_str = input(f"Average initialization duration in seconds (default: {default_init_duration}): ")
        init_duration_input = float(init_duration_str) if init_duration_str else default_init_duration

        memory_gb_str = input(f"Memory allocated to Lambda in GB (e.g., 0.512 for 512MB, default: {default_memory_gb}): ")
        memory_gb_input = float(memory_gb_str) if memory_gb_str else default_memory_gb

        cost_before, cost_after = calculate_lambda_costs(
            total_invocations_per_month=total_invocations_input,
            cold_start_rate=cold_start_rate_input,
            average_invocation_duration_sec=invocation_duration_input,
            average_init_duration_sec=init_duration_input,
            allocated_memory_gb=memory_gb_input,
        )

        display_results(cost_before, cost_after)

    except ValueError:
        print("\nError: Please enter valid numbers.")
    except Exception as e:
        print(f"\nAn unexpected error occurred: {e}")
```

# Comment surveiller votre phase INIT et estimer l'impact ?

Un script, c'est bien, mais si vous avez un paquet de Lambdas à checker, vous risquez de vous épuiser à la tâche.

Heureusement, AWS nous donne quelques outils pour vérifier ça efficacement. En effet, comme vu plus haut, chaque Lambda va faire un `REPORT` de son `Init Duration`. Il nous est donc facile d'aggréger tout cela dans **CloudWatch Logs Insights**.

```
filter @type = "REPORT" and @billedDuration &lt; (@duration + @initDuration)
| stats sum((@memorySize/1000000/1024) * (@billedDuration/1000)) as BilledGBs,
sum((@memorySize/1000000/1024) * ((ceil(@duration + @initDuration) - @billedDuration)/1000)) as UnbilledInitGBs,
(UnbilledInitGBs / (UnbilledInitGBs + BilledGBs)) * 100 as RatioPercent
```

Cette requête vous donnera trois informations clés pour les groupes de logs sélectionnés :
* `BilledGBs` : Le total de Go-secondes actuellement facturé.
* `UnbilledInitGBs` : Le total de Go-secondes consommés pendant la phase `INIT` qui n'étaient *pas* facturés auparavant (pour les fonctions concernées par le changement).
* `RatioPercent` : Le pourcentage que représentent ces Go-secondes `INIT` non facturés par rapport au total des Go-secondes consommés. Cela vous donne une idée directe de l'augmentation potentielle en pourcentage de votre coût de durée Lambda.

En utilisant ces outils, vous pouvez identifier les fonctions qui ont les plus longues durées d'`INIT` et évaluer l'impact financier réel du changement pour votre compte.


# Comprendre et optimiser la phase INIT

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

## Optimiser la taille du package

C'est souvent le levier le plus simple. Réduisez la taille de votre code :
* N'incluez que les dépendances strictement nécessaires.
* Utilisez des outils comme `esbuild` (pour JavaScript/TypeScript) ou des techniques de "tree shaking" pour minifier et ne garder que le code utile.
* Pour le SDK AWS en JavaScript, privilégiez la v3 qui permet d'importer uniquement les clients des services dont vous avez besoin. (Pour en savoir plus, AWS a un article :[ Reduce Lambda cold start times: migrate to AWS SDK for JavaScript v3](https://aws.amazon.com/blogs/compute/reduce-lambda-cold-start-times-migrate-to-aws-sdk-for-javascript-v3/)).

Moins de code à télécharger = phase `INIT` plus courte = moins de coût et démarrage à froid plus rapide.


## Utiliser stratégiquement la phase INIT

Profitez de cette phase pour pré-calculer ou télécharger des données statiques qui serviront à toutes les invocations suivantes. Par exemple, charger une table de lookup depuis S3 ou DynamoDB une seule fois pendant l'`INIT` plutôt qu'à chaque invocation dans le handler.

## Lambda SnapStart

Disponible pour les runtimes **Java, .NET et Python**, SnapStart est une fonctionnalité très intéressante pour combattre les démarrages à froid. Quand vous l'activez, Lambda prend un "snapshot" (un instantané) de l'environnement d'exécution initialisé *après* la première phase `INIT`. Pour les démarrages à froid suivants, Lambda restaure ce snapshot au lieu de refaire toute la phase `INIT`.

Résultat : les démarrages à froid suivants sont beaucoup plus rapides, et la durée facturée de la phase `INIT` est considérablement réduite (voire éliminée pour ces démarrages suivants). C'est particulièrement efficace si votre phase `INIT` est longue à cause du chargement de frameworks lourds (comme Spring Boot en Java) ou de beaucoup de dépendances. Attention, votre code doit être compatible avec la restauration depuis un snapshot (quelques limitations existent, notamment sur l'unicité ou le caractère aléatoire lors de l'initialisation).


## Concurrence Provisionnée (Provisioned Concurrency - PC)

Si votre application a un trafic prévisible ou si la latence des démarrages à froid est inacceptable, vous pouvez utiliser la Concurrence Provisionnée. Vous demandez à Lambda de garder un certain nombre d'environnements d'exécution pré-initialisés (chauds) en permanence.

Avantage : les requêtes arrivant sur ces instances provisionnées ne subissent *jamais* de démarrage à froid. La phase `INIT` est faite en amont, avant même la première requête. C'est idéal pour les applications sensibles à la latence.

Inconvénient : vous payez pour la durée pendant laquelle ces environnements sont provisionnés, *qu'ils reçoivent des requêtes ou non*. La phase `INIT` est d'ailleurs facturée lors de la pré-initialisation. D'un point de vue coût, la PC est généralement plus intéressante que le mode "on-demand" uniquement si votre fonction a un taux d'utilisation soutenu (AWS mentionne une rentabilité souvent meilleure au-dessus de 60% d'utilisation de la capacité provisionnée).

# Conclusion

Le changement de facturation de la phase `INIT` de Lambda qui arrive le **1er août 2025** est avant tout une standardisation. Pour la majorité des fonctions (on-demand, ZIP, runtimes managés), cela signifie que la durée de cette phase sera désormais ajoutée à la durée facturée lors des démarrages à froid.

Même si l'impact financier sera probablement faible pour beaucoup, c'est une excellente occasion de :
1. **Comprendre** le cycle de vie de vos fonctions Lambda et ce qui se passe pendant l'initialisation.
2. **Mesurer** la durée de la phase `INIT` de vos fonctions critiques grâce aux outils CloudWatch.
3. **Optimiser** cette phase si nécessaire, en réduisant la taille de vos packages, en utilisant SnapStart, ou en envisageant la Concurrence Provisionnée pour les cas d'usage appropriés.

N'attendez pas le mois d'août ! Utilisez la requête Logs Insights fournie pour avoir une estimation de l'impact dès maintenant. Cela vous permettra d'identifier les fonctions à optimiser en priorité et d'éviter toute mauvaise surprise sur votre facture AWS.

Alors, prêts à jeter un œil à vos logs et à optimiser vos phases `INIT` ? Happy optimizing !
