---
title: "Postman pre-request script, never worry about refreshing your access token"
date: 2023-05-16T22:49:13+02:00
draft: false
---

One of the most common tasks when you work with APIs is trying to ping them to see if they work as intended (also known as: testing).

One of the simplest, more useful tool on the market is [Postman](https://www.postman.com/), an API client that lets you make requests to any URL you like, using all the methods you could dream of. You can even specify some HTTP headers, which are useful if you must pass an access token in the request to authenticate your API call.

And that's where I began encountering a problem. Not a problem, per se, but something even worse for a Cloud Engineer: <strong>repetition</strong>.

You see, in order to pass this access token to the request, you must first generate it (usually from another API call). The thing is, this access token is short-lived, and will expire after 1 hour of its generation.

So, what does that imply? Well, every hour, before making another request to your API, you will have to make a first request to get a brand new access token, copy the result, and paste it in the appropriate header of your initial request. In total, <strong>this will make you lost 10 seconds</strong>.

Ugh! Can you imagine? 10 seconds?! All the things that could be done if we managed to get this precious time back!

![Is It Worth the Time? - by xkcd](https://imgs.xkcd.com/comics/is_it_worth_the_time.png "Is It Worth the Time?")

But in a product like Postman, I knew this could be resolved somehow. And indeed, after literally one single web search, I stumbled across the perfect solution: [Pre-request script](https://learning.postman.com/docs/writing-scripts/pre-request-scripts/).

The idea is pretty simple: <strong>execute a script before any request</strong>. That's it.

How is this going to help us, you ask? Well, we can now write a small piece of code, that will get a new access token and store it it the variables of the collection we're in. Then, our requests will always reference this variable to be sure they have an up-to-date token.

Let me show you an example I used in one of my projects where I needed to get an AWS Cognito access token before each request.

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

As you can see, this is pretty straightforward, and can probably be applied to any of your projects that require OAuth authentication.

I hope this has been helpful and don't forget: <strong>if you can save 10 seconds, do it!</strong>