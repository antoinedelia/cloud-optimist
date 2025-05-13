---
title: "AWS Lambda : La phase d'INIT devient payante - faut-il s'alarmer ?"
date: 2025-05-13T07:30:00+01:00
author: Antoine Delia
draft: false
tags:
    - AWS
categories: [ AWS ]
image: lambda-init-billing.jpeg
---
# Introduction
Ah, les Lambdas. Probablement le service AWS que j'affectionne le plus ! En moins de temps qu'il ne faut pour le dire, elles permettent de créer un petit script ou carrément un backend API hosté dans le Cloud, et tout cela à moindre coût avec le "pay as you go". Mais cela serait-il trop beau pour être vrai ?

Il y a quelques jours, [AWS a annoncé une modification dans la manière dont la phase d'initialisation des Lambdas est facturée](https://aws.amazon.com/blogs/compute/aws-lambda-standardizes-billing-for-init-phase). **À partir du 1er août 2025**, cette phase sera systématiquement incluse dans le calcul de la durée facturée, et ce, pour *toutes* les Lambdas.

Si vous n'étiez pas au courant, sachez que jusqu'à présent, si vous utilisiez des fonctions Lambdas avec un code packagé en ZIP avec des runtimes managés par AWS (comme Python, Node.js, etc.), la durée de cette phase `INIT` n'était pas facturée. C'était un petit "cadeau" de la part d'AWS (plutôt sympa de leur part). Mais toutes les bonnes choses ont une fin, et il faudra maintenant payer ce temps d'initialisation de nos Lambdas.

Alors, cela va-t-il rendre l'usage des Lambdas trop cher ? Et comment faire en sorte de réduire au maximum cette partie d'initialisation ? Je vous propose aujourd'hui de répondre à toutes ces questions !

# Comprendre le cycle de vie d'une Lambda

Avant de plonger dans la facturation, c'est l'occasion de se rappeler du [cycle de vie d'une Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html).

> Pour simplifier la lecture, je ne rentrerai pas dans les détails des [Lambda Extensions](https://docs.aws.amazon.com/lambda/latest/dg/lambda-extensions.html) et de [Lambda SnapStart](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html).

Cela se compose de trois phases principales :
1. **INIT :** C'est l'étape du "démarrage à froid" ou cold start. Quand une nouvelle instance de votre fonction doit être créée pour répondre à une requête, Lambda prépare le terrain. Cette phase dure au maximum 10 secondes.
2. **INVOKE :** C'est là que votre code (le handler de votre fonction) est exécuté pour traiter la requête.
3. **SHUTDOWN :** Quand l'environnement d'exécution n'est plus utilisé pendant un certain temps, la Lambda se "shutdown" pour libérer les ressources. Si une nouvelle requête arrive, la Lambda devra de nouveau passer par la phase d'INIT.

![Lambda Lifecycle](/img/aws-lambdas-init-phase-to-be-billed-soon-should-we-be-alarmed/lambda_lifecycle.png)

Pendant la phase `INIT`, [votre Lambda fait plusieurs choses](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html#runtimes-lifecycle-ib) :
* Récupère votre code (depuis S3 pour un ZIP, ou ECR pour une image Docker).
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

<details>
  <summary>Détails des calculs</summary>
    
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

</details>

Dans ce scénario précis, l'augmentation est seulement de **$1.67 par mois**. C'est effectivement minime, et cela confirme la communication d'AWS. Mais faites quand même attention, car l'impact *réel* dépendra fortement de :
* La mémoire allouée à vos Lambdas (plus de mémoire = coût par ms plus élevé).
* La durée réelle de votre phase `INIT`.
* Votre taux de cold start (peut être plus élevé si votre trafic est irrégulier).

Il est donc judicieux de vérifier avec vos propres chiffres !

Je vous mets ci-dessous un petit script qui vous permettra de rapidement tester cela de votre côté.

<details>
  <summary>Script Python</summary>

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

</details>

# Comment surveiller votre phase INIT et estimer l'impact ?

Un script, c'est bien, mais si vous avez un paquet de Lambdas à checker, vous risquez de vous épuiser à la tâche.

Heureusement, AWS nous donne quelques outils pour vérifier ça efficacement. En effet, comme vu plus haut, chaque Lambda va faire un `REPORT` de son `Init Duration`. Il nous est donc facile d'aggréger tout cela dans **CloudWatch Logs Insights**. Et cerise sur le gâteau, AWS nous offre même la requête qui va bien.

```
filter @type = "REPORT" and @billedDuration < (@duration + @initDuration) 
| stats sum((@memorySize/1000000/1024) * (@billedDuration/1000)) as BilledGBs, 
sum((@memorySize/1000000/1024) * ((ceil(@duration + @initDuration) - @billedDuration)/1000)) as UnbilledInitGBs, 
(UnbilledInitGBs/ (UnbilledInitGBs+BilledGBs)) as Ratio
```

> Gardez en mémoire que CloudWatch Logs Insights vous est facturé $0.005 par GB de data scanné ([source](https://aws.amazon.com/cloudwatch/pricing/))

Plus qu'à lancer cette requête sur vos Lambdas (en utilisant le prefix `/aws/lambda`), et vous obtiendrez le résultat suivant :

| BilledGBs | UnbilledInitGBs | Ratio  |
|-----------|-----------------|--------|
| 512.8007  | 86.6699         | 0.1446 |

Cette requête vous donne ainsi trois informations clés :
* `BilledGBs` : Le total de Go-secondes actuellement facturé.
* `UnbilledInitGBs` : Le total de Go-secondes consommés pendant la phase `INIT` qui n'étaient *pas* facturés auparavant.
* `Ratio` : Le pourcentage que représentent ces Go-secondes `INIT` non facturés par rapport au total des Go-secondes consommés.

Dans notre exemple, la part du coût de l'`INIT` représente **14%** de notre future facture ! Selon votre facture actuelle, cela pourrait être non négligeable.

# Comprendre et optimiser sa Lambda

Bon, vous savez que vous allez devoir sortir la carte bleue. Mais n'y a-t-il pas un levier d'action pour diminuer cette augmentation dans votre facture ?

Je vous donne ici quelques conseils pour utiliser cette phase INIT au mieux et ainsi réduire vos futurs coûts.

## Utiliser stratégiquement la phase INIT

Votre premier réflexe serait peut-être de vous dire qu'il faudrait enlever tout ce code `INIT` (celui hors du handler) pour le mettre dans votre handler. Comme ça, plus de facturation de l'`INIT` ! Mais non seulement vous ne feriez que déplacer le problème (car l'exécution de ce code vous sera tout de même facturé), cela sera encore pire, car maintenant, mêmes vos executions de Lambda "warm start" devront traiter ce code !

Car oui, rappelons que le code dans la phase `INIT` est exécuté *uniquement* pendant les "cold start". C'est donc l'endroit idéal pour faire des opérations d'initialisation coûteuses qui pourront être réutilisées par les invocations suivantes ("warm start"). Cela est même [recommandé par AWS](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html#function-code). Ainsi, cette phase d'`INIT` est parfaite pour :

* Importer des librairies ou dépendances lourdes.
* Établir des connexions à d'autres services AWS (S3, DynamoDB, etc.) via les SDKs (`boto3` pour Python).
* Créer des pools de connexions à des bases de données.
* Récupérer des paramètres ou des secrets depuis Systems Manager Parameter Store ou Secrets Manager.

Maximisez cette phase d'inititalisation pour réduire ainsi le temps d'exécutions des Lambdas qui elles tourneront en "warm start".

## Optimiser la taille du package

C'est souvent le levier le plus simple, car parfois, on importe un peu tout et n'importe quoi dans notre Lambda. Alors, soyez sûr de n'inclure que des dépendances strictement nécessaires. Veillez également à exclure tout ce qui est lié à votre environnement de développement (je ne vous dis pas le nombre de fois que j'ai trouvé un dossier `node_modules` ou `tests` dans des Lambdas...). Enfin, n'hésitez pas à consulter les articles d'AWS, car [certains taclent directement le sujet des cold start](https://aws.amazon.com/blogs/developer/reduce-lambda-cold-start-times-migrate-to-aws-sdk-for-javascript-v3/).

## Lambda SnapStart

Disponible pour les runtimes **Java, .NET et Python**, [SnapStart](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html) est une fonctionnalité très intéressante pour combattre les "cold start". Quand vous l'activez, Lambda prend un "snapshot" de l'environnement d'exécution initialisé *après* la première phase `INIT`. Pour les "cold start" suivants, la Lambda va restaurer ce snapshot au lieu de refaire toute la phase d'`INIT`, ce qui vous fera gagner pas mal de temps.

J'imagine qu'à la lecture de cette fonctionnalité, vous vous dites "mais enfin c'est super, je vais activer cette feature sur toutes mes Lambdas !". Sauf qu'il y a quelques subtilités à connaître.

Premièrement, SnapStart n'est pour l'instant [compatible qu'avec des versions bien précises de certains langages](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html#snapstart-runtimes) (Python 3.12 minimum, NodeJS pas supporté, ...). Idem pour les régions, [seulement 9 d'entre elles supportent cette feature](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html#snapstart-supported-regions) pour Python et .NET. Enfin, [cette feature n'est pas gratuite](https://aws.amazon.com/lambda/pricing/#SnapStart_Pricing). Vérifiez bien le coût que cela pourrait engendrer si vous souhaitez l'activer sur vos Lambdas.
ialisation).

## Provisioned Concurrency

Si votre application a un trafic prévisible ou si la latence des cold start n'est pas envisageable, vous pouvez utiliser ce qu'on appelle la "[Provisioned Concurrency](https://docs.aws.amazon.com/lambda/latest/dg/provisioned-concurrency.html)". Vous demandez à votre Lambda de garder un certain nombre d'environnements d'exécution pré-initialisés (chauds) en permanence.

Avantage : les requêtes arrivant sur ces instances provisionnées ne subissent *jamais* de cold start. La phase `INIT` est faite en amont, avant même la première requête.

Inconvénient : vous payez pour la durée pendant laquelle ces environnements sont provisionnés, *qu'ils reçoivent des requêtes ou non*. La phase `INIT` est d'ailleurs facturée lors de la pré-initialisation.

Là aussi, à vous de voir si cela vaut le coup d'activer cela sur certaines de vos Lambdas clées !

# Conclusion

Le changement de facturation de la phase `INIT` de Lambda qui arrive le **1er août 2025** est avant tout une standardisation. Pour la majorité des Lambdas, cela signifie que la durée de cette phase sera désormais ajoutée à la durée facturée lors des cold start.

Même si l'impact financier sera probablement faible pour vous, c'est une excellente occasion de :
1. **Comprendre** le cycle de vie de vos Lambdas et ce qui se passe pendant l'initialisation.
2. **Mesurer** la durée de la phase `INIT` de vos fonctions critiques grâce aux outils CloudWatch.
3. **Optimiser** cette phase si nécessaire, en réduisant la taille de vos packages, en utilisant SnapStart, ou en envisageant la Provisioned Concurrency pour des cas spécifiques.

Alors, n'attendez pas le mois d'août ! Familiarisez-vous avec CloudWatch Logs Insights dès maintenant. Cela vous permettra d'identifier les Lambdas à optimiser en priorité et d'éviter toute mauvaise surprise sur votre facture AWS.
