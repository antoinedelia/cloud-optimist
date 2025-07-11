---
title: "AWS Lambda: INIT Phase To Be Billed Soon - Should We Be Alarmed?"
date: 2025-05-13T07:30:00+02:00
author: Antoine Delia
draft: false
tags:
    - AWS
    - Lambda
    - CloudWatch
categories: [ Cloud, FinOps ]
image: lambda-init-billing.jpeg
---

# Introduction
Ah, Lambdas. Probably my favorite AWS service! Almost instantly, they allow you to create a small script or even a fully hosted API backend in the Cloud, all at a low cost thanks to the "pay-as-you-go" model. But is it too good to be true?

A few days ago, [AWS announced a change in how the Lambda initialization phase is billed](https://aws.amazon.com/blogs/compute/aws-lambda-standardizes-billing-for-init-phase). **Starting August 1, 2025**, this phase will systematically be included in the billed duration calculation, for *all* Lambdas.

If you weren't aware, until now, if you used Lambda functions packaged as ZIP archives with AWS-managed runtimes (like Python, Node.js, etc.), the duration of this `INIT` phase wasn't billed. It was a small "gift" from AWS (quite nice of them). But all good things must come to an end, and we will now have to pay for this initialization time for our Lambdas.

So, will this make using Lambdas too expensive? And how can we minimize this initialization part as much as possible? Today, let's explore these questions!

# Understanding the Lambda Lifecycle

Before diving into billing, it's a good opportunity to recall the [Lambda lifecycle](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html).

> For simplicity, I won't go into the details of [Lambda Extensions](https://docs.aws.amazon.com/lambda/latest/dg/lambda-extensions.html) and [Lambda SnapStart](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html).

It consists of three main phases:
1.  **INIT:** This is the "cold start" phase. When a new instance of your function needs to be created to handle a request, Lambda prepares the environment. This phase lasts a maximum of 10 seconds.
2.  **INVOKE:** This is where your code (the function handler) is executed to process the request.
3.  **SHUTDOWN:** When the execution environment hasn't been used for a certain period, the Lambda shuts down to free up resources. If a new request arrives, the Lambda will have to go through the INIT phase again.

![Lambda Lifecycle](/img/aws-lambdas-init-phase-to-be-billed-soon-should-we-be-alarmed/lambda_lifecycle.png)

During the `INIT` phase, [your Lambda performs several actions](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html#runtimes-lifecycle-ib):
* Retrieves your code (from S3 for a ZIP, or ECR for a Docker image).
* Configures the environment with the allocated memory, chosen runtime, etc.
* Starts the runtime (`Runtime INIT`).
* Executes the static code of your function (everything outside the handler, like initializing global variables or `boto3`) (`Function INIT`).

The key takeaway here is that the `INIT` phase only occurs during a *cold start*. If a request arrives while an execution environment is already "warm" (ready and reused), this phase is skipped, and execution goes directly to the `INVOKE` phase. This is called a "warm start," which is much faster.

> AWS doesn't disclose its logic for transitioning a Lambda from 'warm' to 'cold'.

# The Billing Change in Detail

Currently, [Lambda billing](https://aws.amazon.com/lambda/pricing/) is based on two factors:
* The number of requests.
* The execution duration of your code, rounded up to the nearest millisecond (the cost of this duration depends on the memory allocated to the function).

Until August 1, 2025, for functions packaged as ZIPs with managed runtimes, the `INIT` phase duration was not counted in the "Billed Duration". This could be seen in CloudWatch logs:

```
Before August 1, 2025
Note that Billed Duration is the rounded-up value
of Duration without considering Init Duration
REPORT RequestId: xxxxx   Duration: 250.06 ms   Billed Duration: 251 ms   Init Duration: 100.77 ms

After August 1, 2025
Billed Duration is now the rounded-up value
of Duration + Init Duration
REPORT RequestId: xxxxx   Duration: 250.06 ms   Billed Duration: 351 ms   Init Duration: 100.77 ms
```

As you can see, AWS will now take your Init Duration into account in addition to the Duration when calculating the Billed Duration.

# What Impact on the Bill?

So, this all sounds interesting, but will this change break the bank?

Let's take an example to see more clearly. Imagine a Python Lambda configured with 1024 MB of memory, deployed in the `eu-west-1` (Ireland) region.

Assume the following:
* The Lambda receives 10 million invocations per month.
* The cold start rate is 1% ([average provided by AWS](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html#cold-start-latency)), meaning 100,000 cold starts per month.
* The average invocation duration (`Duration`) is 3 seconds.
* The average initialization duration (`Init Duration`) is 1 second.
* Cost per request: $0.20 per million requests.
* Duration cost (x86): $0.0000166667 per GB-second.

<details>
  <summary>Details of the calculation</summary>

**Cost Calculation BEFORE August 1, 2025:**

1.  **Request Cost:** 10 million req * ($0.20 / 1 million req) = **$2.00**
2.  **Duration Cost:**
    * Warm starts (9.9 million): Billed duration = 3 seconds.
    * Cold starts (100,000): Billed duration = 3 seconds (INIT not billed).
    * Total billed duration (seconds): (9,900,000 * 3 s) + (100,000 * 3 s) = 29,700,000 seconds + 300,000 seconds = 30,000,000 seconds.
    * Total GB-seconds: 30,000,000 seconds * (1024 MB / 1024 MB) = 30,000,000 GB-s.
    * Duration Cost: 30,000,000 GB-s * $0.0000166667/GB-s = **$500.00**
3.  **Total Monthly Cost (Before):** $2.00 + $500.00 = **$502.00**

**Cost Calculation AFTER August 1, 2025:**

1.  **Request Cost:** **$2.00** (unchanged)
2.  **Duration Cost:**
    * Warm starts (9.9 million): Billed duration = 3 seconds.
    * Cold starts (100,000): Billed duration = 3 seconds (`Duration`) + 1 second (`Init Duration`) = 4 seconds.
    * Total billed duration (seconds): (9,900,000 * 3 s) + (100,000 * 4 s) = 29,700,000 seconds + 400,000 seconds = 30,100,000 seconds.
    * Total GB-seconds: 30,100,000 seconds * (1024 MB / 1024 MB) = 30,100,000 GB-s.
    * Duration Cost: 30,100,000 GB-s * $0.0000166667/GB-s = **$501.67**
3.  **Total Monthly Cost (After):** $2.00 + $501.67 = **$503.67**

</details>

In this specific scenario, the increase is only **$1.67 per month**. This is indeed minimal and confirms AWS's communication. But be careful, as the *actual* impact will strongly depend on:
* The memory allocated to your Lambdas (more memory = higher cost per ms).
* The actual duration of your `INIT` phase.
* Your cold start rate (can be higher if your traffic is irregular).

Therefore, it's wise to check with your own numbers!

Below is a small script that will allow you to quickly test this on your side.

<details>
  <summary>Python Script</summary>

```python
def calculate_lambda_costs(
    total_invocations_per_month: int,
    cold_start_rate: float,
    average_invocation_duration_sec: float,
    average_init_duration_sec: float,
    allocated_memory_mb: float, # Changed GB to MB for consistency with common AWS console values
    cost_per_million_requests: float = 0.20,
    cost_per_gb_second: float = 0.0000166667,
):
    num_cold_starts = total_invocations_per_month * cold_start_rate
    num_warm_starts = total_invocations_per_month - num_cold_starts

    request_cost = (total_invocations_per_month / 1_000_000) * cost_per_million_requests

    allocated_memory_gb = allocated_memory_mb / 1024 # Convert MB to GB for calculation

    # Duration cost BEFORE
    billed_duration_warm_starts_sec_before = num_warm_starts * average_invocation_duration_sec
    # For cold starts, only invocation duration was billed
    billed_duration_cold_starts_sec_before = num_cold_starts * average_invocation_duration_sec

    total_billed_duration_sec_before = billed_duration_warm_starts_sec_before + billed_duration_cold_starts_sec_before
    total_gb_seconds_before = total_billed_duration_sec_before * allocated_memory_gb
    duration_cost_before = total_gb_seconds_before * cost_per_gb_second

    total_monthly_cost_before = request_cost + duration_cost_before

    # Duration cost AFTER
    billed_duration_warm_starts_sec_after = num_warm_starts * average_invocation_duration_sec
     # For cold starts, invocation + init duration will be billed
    billed_duration_cold_starts_sec_after = num_cold_starts * (average_invocation_duration_sec + average_init_duration_sec)

    total_billed_duration_sec_after = billed_duration_warm_starts_sec_after + billed_duration_cold_starts_sec_after
    total_gb_seconds_after = total_billed_duration_sec_after * allocated_memory_gb
    duration_cost_after = total_gb_seconds_after * cost_per_gb_second

    total_monthly_cost_after = request_cost + duration_cost_after

    return total_monthly_cost_before, total_monthly_cost_after


def display_results(cost_before, cost_after):
    cost_difference = cost_after - cost_before
    print(f"\nEstimated monthly cost BEFORE change: ${cost_before:.2f}")
    print(f"Estimated monthly cost AFTER change: ${cost_after:.2f}")
    print(f"Estimated monthly cost increase: ${cost_difference:.2f}")
    if cost_difference > 0 and cost_before > 0:
        percentage_increase = (cost_difference / cost_before) * 100
        print(f"Percentage increase: {percentage_increase:.2f}%")
    elif cost_difference > 0:
        print("Percentage increase: Infinite (original cost was zero)")


if __name__ == "__main__":
    print("AWS Lambda Cost Calculator (Before/After Init Duration Pricing Change)")
    print("Please enter the values for your scenario or press Enter to use default values.\n")
    default_invocations = 10_000_000
    default_cold_start_rate = 0.01  # 1%
    default_invocation_duration = 3.0  # seconds
    default_init_duration = 1.0  # seconds
    default_memory_mb = 1024.0 # 1024 MB

    try:
        invocations_str = input(f"Total invocations per month (default: {default_invocations:,}): ")
        total_invocations_input = int(invocations_str) if invocations_str else default_invocations

        cold_start_rate_str = input(f"Cold start rate (e.g., 0.01 for 1%, default: {default_cold_start_rate}): ")
        cold_start_rate_input = float(cold_start_rate_str) if cold_start_rate_str else default_cold_start_rate

        invocation_duration_str = input(f"Average invocation duration in seconds (default: {default_invocation_duration}): ")
        invocation_duration_input = float(invocation_duration_str) if invocation_duration_str else default_invocation_duration

        init_duration_str = input(f"Average initialization duration in seconds (default: {default_init_duration}): ")
        init_duration_input = float(init_duration_str) if init_duration_str else default_init_duration

        memory_mb_str = input(f"Memory allocated to Lambda in MB (e.g., 512, default: {default_memory_mb}): ")
        memory_mb_input = float(memory_mb_str) if memory_mb_str else default_memory_mb

        cost_before, cost_after = calculate_lambda_costs(
            total_invocations_per_month=total_invocations_input,
            cold_start_rate=cold_start_rate_input,
            average_invocation_duration_sec=invocation_duration_input,
            average_init_duration_sec=init_duration_input,
            allocated_memory_mb=memory_mb_input,
        )

        display_results(cost_before, cost_after)

    except ValueError:
        print("\nError: Please enter valid numbers.")
    except Exception as e:
        print(f"\nAn unexpected error occurred: {e}")
```
</details>

# How to Monitor Your INIT Phase and Estimate the Impact?

A script is nice, but if you have a bunch of Lambdas to check, you might find the task exhausting.

Fortunately, AWS provides some tools to check this efficiently. As seen earlier, each Lambda will generate a `REPORT` log containing its `Init Duration`. We can easily aggregate this information using CloudWatch Logs Insights. And the icing on the cake, AWS even provides us with the right query.

```
filter @type = "REPORT" and @billedDuration < ceil(@duration + @initDuration)
| stats sum((@memorySize/1024/1000) * (@billedDuration/1000)) as BilledGBs,
        sum((@memorySize/1024/1000) * ((ceil(@duration + @initDuration) - @billedDuration)/1000)) as EstimatedInitGBs,
        (EstimatedInitGBs / (EstimatedInitGBs + BilledGBs)) * 100 as EstimatedInitCostPercent
```

> Keep in mind that CloudWatch Logs Insights is billed at $0.005 per GB of data scanned ([source](https://aws.amazon.com/cloudwatch/pricing/)). Adjust the query time range to limit costs.

Just run this query on your Lambda log groups (using the `/aws/lambda` prefix or specific function prefixes), and you'll get a result like this:

| BilledGBs | UnbilledInitGBs | Ratio  |
|-----------|-----------------|--------|
| 512.8007  | 86.6699         | 0.1446 |

This query gives you three key pieces of information:
* `BilledGBs`: The total GB-seconds currently billed.
* `EstimatedInitGBs`: The total GB-seconds consumed during the `INIT` phase that were not previously billed (this is an estimation based on the difference between current billed duration and potential future billed duration including `INIT`).
* `EstimatedInitCostPercent`: The percentage that these previously unbilled `INIT` GB-seconds represent compared to the total consumed GB-seconds (current billed + estimated init). This approximates the potential percentage increase in your duration costs due to the change.

In our example, the cost share of the `INIT` phase represents approximately **14%** of the total execution cost (current + potential init cost)! Depending on your current bill, this could be significant.

# Understanding and Optimizing Your Lambda

Okay, so you know you might have to pay more. But aren't there levers we can pull to reduce this increase in your bill?

Here are some tips for making the best use of this INIT phase and thus reducing your future costs.

## Strategically Use the INIT Phase

Your first instinct might be to remove all the `INIT` code (code outside the handler) and put it in your handler. That way, no more `INIT` billing! But not only would you just be shifting the problem (because executing that code will still be billed), it would be even worse, because now even your 'warm start' Lambda executions would have to process this code!

Yes, remember that the code in the `INIT` phase is executed _only_ during cold starts. Therefore, it's the ideal place for expensive initialization operations that can be reused by subsequent ("warm start") invocations. This is even [recommended by AWS](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html#function-code). Thus, the `INIT` phase is perfect for:

* Importing heavy libraries or dependencies.
* Establishing connections to other AWS services (S3, DynamoDB, etc.) via SDKs (`boto3` for Python).
* Creating database connection pools.
* Fetching parameters or secrets from Systems Manager Parameter Store or Secrets Manager.

Maximize this initialization phase to reduce the execution time of Lambdas running in 'warm start'.

## Optimize Package Size

This is often the simplest lever, because sometimes we import all sorts of things into our Lambda. So, make sure to include only strictly necessary dependencies. Also, be sure to exclude anything related to your development environment (I can't tell you how many times I've found a `node_modules` or `tests` folder in Lambdas...). Finally, don't hesitate to consult AWS articles, as [some directly tackle the subject of cold starts](https://aws.amazon.com/blogs/developer/reduce-lambda-cold-start-times-migrate-to-aws-sdk-for-javascript-v3/).

## Lambda SnapStart

Available for Java, .NET, and Python runtimes, [SnapStart](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html) is a very interesting feature for combating cold starts. When you enable it, Lambda takes a "snapshot" of the initialized execution environment _after_ the first `INIT` phase. For subsequent cold starts, Lambda restores this snapshot instead of redoing the entire `INIT` phase, saving you significant time.

I imagine reading about this feature, you're thinking "Wow, this is great, I'm going to enable this feature on all my Lambdas!". Except there are a few subtleties to be aware of.

Firstly, SnapStart is currently [only compatible with specific versions of certain languages](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html#snapstart-runtimes) (Python 3.12 minimum, NodeJS not supported...). The same goes for regions; [only a limited number support this feature](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html#snapstart-supported-regions) at the time of writing. Finally, [this feature is not free](https://aws.amazon.com/lambda/pricing/#SnapStart_Pricing) and incurs its own costs. Make sure to check the potential cost if you want to enable it on your Lambdas.

## Provisioned Concurrency
If your application has predictable traffic or if cold start latency is unacceptable, you can use "[Provisioned Concurrency](https://docs.aws.amazon.com/lambda/latest/dg/provisioned-concurrency.html)". You ask Lambda to keep a certain number of execution environments pre-initialized (warm) at all times.

Advantage: Requests hitting these provisioned instances _never_ experience a cold start. The `INIT` phase is done upfront, before the first request.

Disadvantage: You pay for the time these environments are provisioned, _whether they receive requests or not_. The `INIT` phase is also billed during this pre-initialization.

Here too, it's up to you to see if it's worth enabling this on some of your key Lambdas!

# Conclusion
The upcoming change in billing for Lambda's `INIT` phase on **August 1, 2025**, is primarily a standardization. For the majority of Lambdas (specifically those using managed runtimes and ZIP packaging that previously benefited from the free init), this means the duration of this phase will now be added to the billed duration during cold starts.

Even if the financial impact will likely be small for you, it's an excellent opportunity to:

* Understand your Lambda's lifecycle and what happens during initialization.
* Measure the `INIT` phase duration of your critical functions using CloudWatch tools.
* Optimize this phase if necessary, by reducing package sizes, using SnapStart, or considering Provisioned Concurrency for specific use cases.

So, don't wait until August! Familiarize yourself with CloudWatch Logs Insights now. This will allow you to identify which Lambdas to optimize first and avoid any nasty surprises on your AWS bill.
