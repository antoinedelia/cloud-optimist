---
title: "Sur la piste de la ressource perdue : Mon enquête avec Athena et CloudTrail"
date: 2025-07-24T07:30:00+02:00
author: Antoine Delia
draft: true
tags:
    - AWS
    - CloudTrail
    - S3
    - Athena
categories: [ AWS, CloudTrail, S3, Athena ]
image: aws_lost_resource.jpeg
---

# Introduction

Récemment, j'ai dû jouer les détectives sur notre compte AWS.

Une ressource était là (un Cognito User Pool), bien présente, mais personne ne se souvenait de son origine. Et évidemment, pas de tags pour nous aider (si seulement ils avaient lu [mon article sur le tagging des resources AWS](/fr/posts/2025/why-tagging-your-aws-resources-is-a-must/)).

Ma mission, si je l'acceptais : découvrir qui l'avait créée. Le problème ? L'événement datait d'il y a environ quatre mois.

Mon premier réflexe a été de me tourner vers AWS CloudTrail. Et là, premier mur : l'historique des événements n'est consultable que sur les 90 derniers jours. Raté !

Heureusement, je savais que nos logs CloudTrail étaient archivés sur le long terme dans un bucket S3. Mon plan B, un peu désespéré : télécharger manuellement les archives du bon mois, décompresser des dizaines de fichiers JSON, et lancer un <kbd>Ctrl+F</kbd> en priant très fort. Autant vous dire que ce n'est ni efficace, ni agréable, ni rapide.

C'est cette expérience douloureuse qui m'a poussé à enfin mettre en place une solution bien plus propre et puissante : **AWS Athena**.

# Athena à la Rescousse : Interroger vos Logs S3 avec du SQL

Pour ceux qui ne connaissent pas, AWS Athena est un service de requête interactif qui facilite l'analyse de données directement dans Amazon S3 en utilisant du SQL standard. En gros, vous pouvez faire des requêtes sur des fichiers plats (JSON, CSV, Parquet...) comme s'il s'agissait d'une base de données traditionnelle. Plus besoin de télécharger quoi que ce soit !

L'idée est donc de "mapper" nos logs CloudTrail stockés dans S3 à une table virtuelle dans Athena. Pour cela, on utilise une seule requête `CREATE EXTERNAL TABLE`. En suivant [la documentation d'AWS sur le sujet](https://docs.aws.amazon.com/athena/latest/ug/create-cloudtrail-table-partition-projection.html), j'ai lancé la requête suivante dans la console Athena.

Cette requête crée une table et utilise une fonctionnalité très pratique appelée "partition projection". Cela permet à Athena de déduire l'emplacement des logs en fonction de la date, sans avoir à gérer manuellement les partitions.

```sql
CREATE EXTERNAL TABLE cloudtrail_logs_pp (
    eventversion STRING,
    useridentity STRUCT<
        arn:STRING
    >,
    eventtime STRING,
    eventsource STRING,
    eventname STRING,
    awsregion STRING,
    requestparameters STRING,
    responseelements STRING,
    additionaleventdata STRING,
    requestid STRING,
    eventid STRING,
    resources ARRAY<STRUCT<
        arn:STRING,
        accountid:STRING,
        type:STRING
    >>,
    eventtype STRING,
    eventcategory STRING
)
PARTITIONED BY (
    `timestamp` string
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS INPUTFORMAT 'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://BUCKET-NAME/AWSLogs/ACCOUNT-ID/CloudTrail/REGION' -- Remplacez par le chemin de votre bucket S3
TBLPROPERTIES (
    'projection.enabled'='true',
    'projection.timestamp.format'='yyyy/MM/dd',
    'projection.timestamp.interval'='1',
    'projection.timestamp.interval.unit'='DAYS',
    'projection.timestamp.range'='2024/01/01,NOW', -- Remplacez par la date de début
    'projection.timestamp.type'='date',
    'storage.location.template'='s3://BUCKET-NAME/AWSLogs/ACCOUNT-ID/CloudTrail/REGION/${timestamp}' -- Remplacez par le chemin de votre bucket S3
)
```

**Attention :** N'oubliez pas de remplacer les URLs `s3://...` par le chemin exact de votre bucket S3 où sont stockés vos logs CloudTrail, et d'ajuster la `projection.timestamp.range` à la période qui vous intéresse.

# L'Heure de l'Enquête : Trouver l'Information

Une fois la table créée (ce qui ne prend que quelques secondes), le plus dur est fait ! Mon enquête pouvait enfin commencer.

Je cherchais à savoir qui avait créé un `UserPoolClient` pour Cognito à une date précise. Ma requête SQL ressemblait donc à ça :

```sql
SELECT
    eventTime,
    eventName,
    userIdentity.arn
FROM
    cloudtrail_logs_pp
WHERE
    timestamp = '2025/02/25'
    AND eventName = 'CreateUserPoolClient';
```

En quelques secondes, Athena a scanné les logs du jour demandé et m'a retourné le résultat.

J'avais l'heure exacte, l'événement, et surtout, l'ARN de l'utilisateur qui avait effectué l'action. Mission accomplie !

# Le Verdict... et le Coupable

Le plus drôle dans cette histoire ?

Après avoir mis en place cette solution et retrouvé l'information si facilement, j'ai découvert que l'ARN du "coupable" qui avait créé cette ressource il y a quatre mois... était le mien. J'avais complètement oublié !

Au-delà de l'anecdote, cette expérience m'a confirmé une chose : prendre quelques minutes pour configurer Athena sur vos logs CloudTrail est un investissement incroyablement rentable. Vous vous offrez une capacité d'audit et de recherche sur le long terme qui vous sauvera des heures de recherche manuelle le jour où vous en aurez vraiment besoin. Ne faites pas comme moi, n'attendez pas d'être coincé pour le mettre en place !
