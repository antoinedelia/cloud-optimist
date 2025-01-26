---
title: "How We Built a CI/CD Strategy That Onboards 100+ Python Projects in Under a Minute"
author: Antoine Delia
date: 2025-01-19T16:45:00+02:00
tags:
    - Python
    - CI/CD
    - Jenkins
categories: [ Python, CI/CD, Jenkins ]
draft: false
image: ci-cd-strategy.jpeg
---

We all know CI/CD is important. In fact, it seems impossible to imagine a world where we would ship a project without checking the quality of its code, and having a detailed test suite. Moreover, to enable developers to focus on development, all of this should be automated.

Well, things are not always so easy.

Today, I’ll share how we transitioned from having no CI/CD strategy to onboarding 100+ Python projects in under a minute.

# The Real World

When I joined my current company, I noticed we were managing a large number of Python projects. But when I tried to check for the CI/CD of these, well it was a bit of a mess. Some projects had CI/CD in place, but not too many. And the ones with one were not using the same rules to verify code compliance. It was clear that putting in place a CI/CD for any given project was treated as best effort. And, to be honest, I cannot blame this on anyone.

Indeed, while CI/CD is widely recognized as a core component of any project, implementing it in the real world often proves challenging.

But I knew we could change that somehow. So before jumping into a strategy to put in place, I wanted to observe what had prevented people to implement a CI/CD to begin with.

## Lack of Permissions

The first thing that I realized, is that not all developers had the same level of access to our Jenkins instance. So while some were able to create new pipelines for their projects, some couldn't. In large organizations, it is not uncommon to have this kind of scenario.

> **Lesson learned: a lack of permissions should not be a drawback to use a CI/CD pipeline.**

## Lack of Knowledge

When people had the ability to create a pipeline, some did not, as they simply did not have the proper knowledge to do so. Here, I need to mention that our company uses a Jenkins instance, so developers familiar with other CI/CD tools (e.g., GitHub Actions, CircleCI) could not fully transfer these knowledge to Jenkins. Moreover, we did not have a clear documentation on the process to follow to create a new pipeline, so beginners, fearing to break something, would simply do not take the risk to mess with it.

> **Lesson learned: we should ensure people without proper Jenkins knowledge can use a CI/CD pipeline.**

## Lack of Time

It takes effort to put in place a CI/CD at the beginning of a project, something that might be overlooked by managers that want to ship a product as fast as possible. Moreover, it is sometimes difficult to quantify the return on investment of putting in place a CI/CD pipeline. And if it is difficult to prove this can bring business value, it will end up in the "we'll deal with this later" box. And we know all too well that the tasks that end up in this box will never see the light of day again.

> **Lesson learned: setting up a CI/CD pipeline for a new or existing project should be easy and straightforward.**

## Lack of Clear Guidelines

Finally, I had a look at the projects that _did_ have a CI/CD pipeline. They were working fine, but I could clearly see that they lacked a common vision. Some of them used the same formatter (black), but they not always used the same line-length. Some included a testing stage, some didn't. Not only did this led to projects not having the same code quality and compliance, I also thought that this could potentially led to confusion for a newcomer, not knowing which standard to use.

> **Lesson learned: people should use the same CI/CD pipeline to ensure everyone follows the same guidelines (and we should ensure these guidelines are documented somewhere).**

# The Global Vision

After reviewing what could go wrong, it is now important to think of a solution that could address all of these, while following the company's best practices, and using the tools at our disposal.

## Formatting

The first stage should use a formatter to ensure every line of code in our codebase looks the same. This makes sure we are not ending up with different coding standards across our projects.

Previously, we used black as our formatter. But after hearing all the good news and testing the new cool kid in the block, we decided to switch to ruff, as it has the same benefits as black, but with a faster execution.

## Linting

The next stage should use a linter to find potential issues with our code. This makes sure we avoid complexity in our code, as well as identifying code smells or security issues.

In the past, I used flake8 a lot. But given that we were already using ruff, and as it can also act as a linter, it was a no-brainer to keep it for this task.

There are many rules that ruff can apply. We decided to use some of them by default, while letting developers the choice to update the ones their project would follow.

## Unit Tests

Tests are a critical part of the development of any project. It ensures we ship quality code to production, while also being able to trust that our code would run just fine.

We decided to use pytest to run these tests. The default code directory would be called `src`, and all tests should be in a `tests` folder, with files being prefixed by `test_`.

## Code Coverage

Closely related to unit tests, code coverage ensures we are able to know how much of our code has been tested. This could quickly tell us if we sufficiently tested our code, as well as pointing out the remaining lines to cover.

As we were using pytest, we decided to use pytest-cov to generate a coverage report, as it integrates nicely with pytest.

We set the minimum coverage threshold at 50%. Anything lower would risk overlooking significant portions of code, while setting it higher might discourage developers from writing the necessary tests.

![Detailed view of the code coverage step](/img/how-we-built-a-cicd-strategy-that-onboards-100-python-projects-in-under-a-minute/detailed-view-of-the-code-coverage-step.png)

## Organization Folders for Jenkins

We had our different stages ready. Now all we needed to do, was find a way to globally apply said pipeline to our Python repositories. So I tried looking for a way to easily do that in Jenkins.

That's when I stumbled upon [Organization Folders](https://www.jenkins.io/doc/book/using/best-practices/#use-organization-folders).

Organization Folders are designed for scenarios like ours: automatically scan an organization (as in, a GitHub organization), filter the repositories you want, and apply a Jenkins pipeline to them.

In our example, we are able to look for all repositories with the "python" topic, and identify them as Python projects. They will then be automatically built. If a new repository is created with this topic, it will also get picked up by Jenkins.

So, in less than 5 seconds, your project could be onboarded, without having to create it in Jenkins. All is done automatically so you can focus on your code.

## Examples and Documentation

All of this was great, but I was fearing of one last obstacle. What would happen if developers adopted the CI/CD pipeline only to find stages failing, with no clear documentation to resolve issues? They would probably give up or try to fix it later, which would destroy the initial goal.

So I knew that if I wanted to onboard people in this, we needed to deliver clear documentation with direct examples, so they would be able to understand why these errors might appear, and how to fix them.

Especially on the unit tests stage, as I know this is always a daunting task to start with. So I prepared a project in advance with some unit tests that I knew they could have a look at to take some inspiration, or that directly covered some tricky parts (mocking boto3 API calls, etc.).

The last step was to make a presentation on all of the above. This was key to give meaning to people, so they could really understand the point of doing all this, while making sure they had all the keys to be autonomous.

# What We Have Today

From a developer's view, all he has to do to get his Python project onboarded, is to add the `python` topic in his repository, and ensures a `pyproject.toml` file is created at the root of the repository.

These two requirements are here to tell Jenkins which project it should take into account. Moreover, the `pyproject.toml` file is mandatory for the ruff stages in the pipeline.

![Two simple steps to get onboarded with CI/CD pipelines](/img/how-we-built-a-cicd-strategy-that-onboards-100-python-projects-in-under-a-minute/two-simple-steps-to-get-onboarded-with-cicd-pipelines.png)

With that done, his Python project will now check for formatting issues, linting errors, validation of unit tests, and code coverage.

![Jenkins Python CI/CD pipeline](/img/how-we-built-a-cicd-strategy-that-onboards-100-python-projects-in-under-a-minute/jenkins-python-cicd-pipeline.png)

All in all, we are now able to setup CI/CD pipelines in less than a minute, whether you have a new or existing project!

# Some Flaws

While this simplifies things a lot, there is still room for improvements.

## The pipeline cannot be enforced

Currently, this CI/CD pipeline cannot be enforced because developers can simply remove the `python` topic to bypass it. And while this is fine at first, as we do not want to block developers in their work, at some point, the goal is still to make sure we are applying the same best practices in all Python projects.

This might be resolved in the future by the use of [GitHub Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets).

They essentially act quite the same as branch protection rules, expect you define these rules at the organization level.

This way, we could be able to protect our main branches for all our repositories that matches a specific custom properties, and require them to successfully pass the CI/CD pipeline before they are able to merge.

## The pipeline's stages can be ignored

The `pyproject.toml` is used to say to ruff which format it should apply, or which rules to follow for the linting part.

And because we are currently using the `pyproject.toml` inside each repository, a developer could just update the rules on his own, bypassing all the guidelines we were trying to apply in the first place.

Again, while we are allowing this for now to account for the number of fixes to resolve at first, in the end, we might want to prevent this from happening.

We could either use a common and fixed `pyproject.toml` file, or add it in the GitHub's CODEOWNERS file to ensure it cannot be modified without strict approval.

# What's Next?

With these in place, we can now think about the evolution of this pipeline.

For example, our company has a SonarQube instance. We would be interested to add a stage that could scan the repository for code smells.

We are also exploring the use of mkdocs, so that projects can share a common style for documentation.

And one of my personal favorites, we might want to explore the use of `uv` to install requirements, as it is significantly faster than the old `pip` guy!

You might have also noticed that while I talked about CI/CD throughout this post, at no point do we have a step that, well, deploys anything (which basically leaves us with a CI pipeline). We are already thinking about a way to build and deploy Python packages to our Artifactory repository manager, which would finally make this a CI/CD pipeline!

Finally, we only covered Python in this post, but the same logic could apply to other types of projects. To give you an example, we are also working on a CI/CD pipeline for Terraform.

# Conclusion

By tackling permissions, knowledge gaps, and inconsistent guidelines, we built a unified CI/CD strategy that now supports over 100 Python projects. It’s proof that with the right approach, automation is achievable for any organization

It’s been a long but rewarding journey!

I hope this post proved the value of CI/CD, helped you understand what could prevent it from being applied, and gave you some ideas on how to implement a similar strategy in your organization!
