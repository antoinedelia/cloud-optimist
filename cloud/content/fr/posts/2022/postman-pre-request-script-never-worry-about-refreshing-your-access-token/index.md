---
title: "Postman pre-request script, plus besoin de regénérer votre access token"
date: 2022-05-16T22:49:13+02:00
draft: false
author: Antoine Delia
tags:
    - Postman
    - OAuth
    - API
categories: [ Software Engineering ]
image: astronaut.jpeg
---

L'une des tâches les plus courantes lorsque vous travaillez avec des APIs est de les "pinger" pour vérifier si elles fonctionnent comme prévu (aussi connu sous le nom de : tests).

Un des outils les plus simples et utiles sur le marché est [Postman](https://www.postman.com/), un client API qui vous permet de faire des requêtes à n'importe quelle URL, en utilisant toutes les méthodes que vous pouvez imaginer. Vous pouvez même spécifier des headers HTTP, ce qui est pratique si vous devez passer un token d'accès (access token) dans la requête pour authentifier votre appel API.

Et c'est là que j'ai commencé à rencontrer un problème. Pas un véritable problème, mais quelque chose d'encore plus frustrant pour un ingénieur : <strong>la répétition</strong>.

En fait, pour transmettre cet access token à la requête, vous devez d'abord le générer (généralement via un autre appel API). Le hic, c'est que cet access token est éphémère, et expire après une heure.

Alors, qu'est-ce que cela implique ? Eh bien, chaque heure, avant de faire une nouvelle requête à votre API, vous devez d'abord faire une requête pour obtenir un nouveau token, copier le résultat, et le coller dans l'en-tête de la requête initiale. En tout, <strong>cela vous fera perdre 10 secondes</strong>.

Ouf ! Vous imaginez un peu ? 10 secondes ?! Tout ce que l'on pourrait accomplir si l'on arrivait à récupérer ce temps précieux !

![Is It Worth the Time? - by xkcd](https://imgs.xkcd.com/comics/is_it_worth_the_time.png "Is It Worth the Time?")

Mais avec Postman, je savais que ce problème pouvait être résolu d'une manière ou d'une autre. Et en effet, après une simple recherche sur le web, je suis tombé sur la solution parfaite : [Pre-request script](https://learning.postman.com/docs/writing-scripts/pre-request-scripts/).

L'idée est assez simple : <strong>exécuter un script avant chaque requête</strong>. Voilà.

Comment cela peut-il nous aider, demandez-vous ? Eh bien, nous pouvons maintenant écrire un petit morceau de code qui va récupérer un nouvel access token et le stocker dans les variables de la collection dans laquelle nous nous trouvons. Ensuite, nos requêtes feront toujours référence à cette variable pour s'assurer qu'elles disposent d'un token à jour.

Laissez-moi vous montrer un exemple que j'ai utilisé dans l'un de mes projets où j'avais besoin de récupérer un access token d'AWS Cognito avant chaque requête.

```javascript
pm.sendRequest({
    url: "https://YOUR_COGNITO_DOMAIN_NAME_HERE.auth.eu-west-1.amazoncognito.com/oauth2/token",
    method: 'POST',
    header: {
        'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: {
        mode: 'urlencoded',
        urlencoded: [
            {
                key: "grant_type",
                value: "client_credentials"
            },
            {
                key: "client_id",
                value: "YOUR_CLIENT_ID_HERE"
            },
            {
                key: "client_secret",
                value: "YOUR_CLIENT_SECRET_HERE"
            },
            {
                key: "scope",
                value: "YOUR_SCOPE_HERE"
            }
        ]
    }
}, (err, res) => {
    pm.collectionVariables.set("access_token", res.json().access_token)
});
```

Comme vous pouvez le voir, c'est assez simple, et cela peut probablement être appliqué à n'importe quel projet nécessitant une authentification OAuth.

J'espère que cela vous a été utile et surtout n'oubliez pas : <strong>si vous pouvez économiser 10 secondes, faites-le !</strong>
