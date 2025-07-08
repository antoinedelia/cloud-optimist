---
title: "On The Trail of The Lost Resource - My Investigation With Athena and CloudTrail"
date: 2025-07-24T07:30:00+02:00
author: Antoine Delia
draft: true
tags:
    - CloudTrail
    - Athena
    - S3
    - Cognito
categories: [ AWS ]
image: aws_lost_resource.jpeg
---

# Introduction

Recently, I had to play detective in our AWS account.

A resource was there (a Cognito User Pool), plain as day, but nobody could remember where it came from. And of course, there were no tags to help us (if only they had read [my post on why tagging your AWS resources is a must](/en/posts/2025/why-tagging-your-aws-resources-is-a-must/)).

My mission, should I choose to accept it: find out who created it. The problem? The event was about four months old.

My first instinct was to turn to AWS CloudTrail. And there, I hit my first wall: [the event history is only viewable for the last 90 days](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/view-cloudtrail-events.html#event-history-limitations). Dead end.

Luckily, I knew our CloudTrail logs were archived in an S3 bucket. My first thought was to manually download the archives for the right month, unzip dozens of JSON files, and hit <kbd>Ctrl+F</kbd> while praying for a miracle. Let's just say it was neither efficient, pleasant, nor fast.

So, I wondered if there wasn't a simpler way to search through this pile of logs, and I finally found the perfect solution: **AWS Athena**.

# Querying your S3 logs with Athena

For those unfamiliar, [AWS Athena](https://docs.aws.amazon.com/athena/latest/ug/what-is.html) is an interactive query service that makes it easy to analyze data directly in Amazon S3 using standard SQL. Basically, you can run queries on files (JSON, CSV, etc.) as if they were in a traditional database. No more downloading anything!

The idea, then, is to "map" our CloudTrail logs stored in S3 to a table in Athena. To do this, we use a single `CREATE EXTERNAL TABLE` query. Following [the AWS documentation on the subject](https://docs.aws.amazon.com/athena/latest/ug/create-cloudtrail-table-partition-projection.html), I ran the following query in the Athena console.

This query creates a table and uses a very handy feature called "partition projection." This allows Athena to infer the location of the logs based on the date, without having to manually manage partitions. This is very convenient when the structure is standardized, as is the case with AWS CloudTrail.

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
LOCATION 's3://BUCKET-NAME/AWSLogs/ACCOUNT-ID/CloudTrail/REGION' -- Replace with your S3 bucket path
TBLPROPERTIES (
    'projection.enabled'='true',
    'projection.timestamp.format'='yyyy/MM/dd',
    'projection.timestamp.interval'='1',
    'projection.timestamp.interval.unit'='DAYS',
    'projection.timestamp.range'='2024/01/01,NOW', -- Replace with your start date
    'projection.timestamp.type'='date',
    'storage.location.template'='s3://BUCKET-NAME/AWSLogs/ACCOUNT-ID/CloudTrail/REGION/${timestamp}' -- Replace with your S3 bucket path
)
```

**Warning:** Don't forget to replace the `s3://...` URLs with the exact path to your S3 bucket where your CloudTrail logs are stored, and to adjust the `projection.timestamp.range` property to the period you're interested in.

# Investigation Time: Finding the Information

Once the table is created (which only takes a few seconds), the hardest part is over! My investigation could finally begin.

I was looking for who had created a Cognito `UserPoolClient` on a specific date. So my SQL query looked like this:


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

In just a few seconds, Athena scanned the logs for the requested day and returned the result.

![Athena query to search CloudTrail logs in S3](/img/on-the-trail-of-the-lost-resource-my-investigation-with-athena-and-cloudtrail/running_the_athena_query.png)

I had the exact time, the event, and most importantly, the ARN of the user who performed the action. Mission accomplished!

# The Verdict... and the Culprit

The funniest part of this story?

After setting up this solution and finding the information so easily, I discovered that the "culprit" who had created this resource four months ago... **was me**. I had completely forgotten!

Jokes aside, this experience confirmed one thing for me: taking a few minutes to set up Athena on your CloudTrail logs is an incredibly worthwhile investment. You're giving yourself a long-term auditing and search capability that will save you hours of manual searching the day you really need it. Don't be like me; don't wait until you're stuck to set it up!
