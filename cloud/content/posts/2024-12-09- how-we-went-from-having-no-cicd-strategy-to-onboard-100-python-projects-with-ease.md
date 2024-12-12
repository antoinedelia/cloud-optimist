---
title: "How we went from having no CI/CD strategy to onboard 100+ Python projects in the blink of an eye"
date: 2024-12-09T12:00:00+02:00
draft: true
---

We all know CI/CD is important. In fact, it seems impossible to imagine a world where we would ship a project without checking the quality of its code, and having a detailed test suite. Moreover, to focus on the development, all of this would be dealt with in an automated fashion.

Well, things are not always so easy.

Today, I want to showcase of we went from having no CI/CD strategy, to onboard 100+ Python projects with ease.

# The real world

When I first came in my current company, I noticed we were working with a ton of Python projects. But when I tried to check for the CI/CD of these, well it was a bit of a mess. Some projects had CI/CD in place, but you not too many. And the ones with one were not using the same rules to verify code compliance. It was clear that putting in place a CI/CD for any given project was treated as best effort. And, to be honest, I cannot blame this on anyone.

Indeed, while it is said everywhere that CI/CD is a core component of a project (just like unit tests), in the real world, things are never this easy.

But I knew we could change that somehow. So before jumping into a strategy to put in place, I wanted to observe what had prevented people to implement a CI/CD to begin with.

## Lack of permissions

The first thing that I realized, is that not all developers had the same level of access to our Jenkins instance. So while some were able to create new pipelines for their projects, some couldn't. In large organizations, it is not uncommon to have this kind of scenario.

> Lesson learned: lack of permissions should not be a drawback to use a CI/CD pipeline.

## Lack of knowledge

When people had the ability to create a pipeline, some did not, as they simply did not have the proper knowledge to do so. Here, I need to mention that our company uses a Jenkins instance, so people with knowledge on other CI/CD tools (such as GitHub Actions, Circle CI) could not fully transfer these knowledge to Jenkins. Moreover, we did not have a clear documentation on the process to follow to create a new pipeline, so beginners, fearing to break something, would simply do not take the risk to mess with it.

> Lesson learned: we should ensure people without proper Jenkins knowledge can use a CI/CD pipeline.

## Lack of time

It takes effort to put in place a CI/CD at the beginning of a project, something that might be overlooked by managers that want to ship a product as fast as possible. Moreover, it is sometimes difficult to quantify the return on investment of putting in place a CI/CD pipeline. And if it is difficult to prove this can bring business value, it will not end up in the "we'll deal with this later" box. And we know all too well that the tasks that end up in this box will never see the light of day again.

> Lesson learned: setting up a CI/CD pipeline for a new or existing project should be easy and straightforward.

## Lack of clear guidelines

Finally, I had a look at the projects that _did_ have a CI/CD pipeline. They were working fine, but I could clearly see that they lacked a common vision. Some of them used the same formatter (black), but they not always used the same line-length. Some included a testing stage, some didn't. Not only did this led to projects not having the same code quality and compliance, I also thought that this could potentially led to confusion for a newcomer, not knowing which standard to use.

> Lesson learned: people should use the same CI/CD pipeline to ensure everyone follows the same guidelines (and we should ensure these guidelines are documented somewhere).

# The global vision

After reviewing what could go wrong, it is now important to think of a solution that could address all of these, while following the company's best practices, and using the tools at our disposal.

Mention that we wanted to have preferably one common pipeline, and something so easy to setup, people would just do it instantly.

## Formatting

The first stage should use a formatter to ensure every line of code in our codebase looks the same. This makes sure we are not ending up with different coding standards across our projects.

As mentioned above, we used to use black before. But after testing the new cool kid in the block, we decided to switch to ruff, as it has the same benefits as black, but with a faster execution.

Regarding the line length to use, this was a tricky decision, as there is no clear standard in the Python community. I already refused to use the PEP8 standard of 79 characters, as it could impact human readability. I ultimately ended up using 127 characters (this is what GitHub uses when you setup the "Python application" workflow in GitHub Actions, mentioning that the GitHub editor is 127 chars wide, so I'll trust them).

We did not want to lower this number to ensure human readability. On the opposite, having a greater number would potentially lead to code smell.

In any case, now, we had a fixed line length number we could all follow.

## Linting

The next stage should use a linter to find potential issues with our code. This makes sure we avoid complexity in our code, as well as identifying code smells or security issues.

In the past, I used flake8 a lot. But given that we were already using ruff, and as it can also act as a linter, it was a no-brainer to keep it for this task.

There are many rules that ruff can apply. We decided to use some of them by default (F, E4, E7, E9, W, S, I, B, SIM, PGH004), while letting developers the choice to update the ones their project would follow.

## Unit tests

Tests are a critical part of the development of any project. It ensures we ship quality code to production, while also being able to trust that our code would run just fine.

We decided to use pytest to run these tests. The default code directory would be called `src`, and all tests should be in a `tests` folder, with files being prefixed by `test_`.

## Code Coverage

Closed to the unit tests topic, code coverage ensures we are able to know how much of our code has been tested. This could quickly tell us if we sufficiently tested our code, as well as pointing out the remaining lines to cover.

As we were using pytest, we decided to use pytest-cov to generate a coverage report, as it integrates nicely with pytest.

And for the minimum coverage allowed, we started at 50%. We didn't wanted lower, to ensure a large portion of code would be tested, but not higher to make sure it wouldn't discourage developers to implement these tests.

## Organization Folders for Jenkins

We had our different stages ready. Now all we needed to do, was find a way to globally apply said pipeline to our Python repositories. So I tried looking for a way to easily do that in Jenkins.

That's when I stumbled upon Organization Folders.

They are pretty much created just for our use case: automatically scan an organization (as in, a GitHub organization), filter the repositories you want, and apply a Jenkins pipeline to them.

In our example, we are able to look for all repositories with the "python" topic, and identify them as Python projects. They will then be automatically built. If a new repository is created with this topic, it will also get picked up by Jenkins.

So, in less than 5 seconds, your project could be onboarded, without having to create it in Jenkins. All is done automatically so you can focus on your code.

## GitHub Rulesets

The last point I wanted to check, was the way to enforce the use of this pipeline. Because, even though you could setup a CI/CD pipeline for your project, and fail to pass its stages, nothing could forbid you to ignore these errors and push to your main branch.

I noticed that in the repositories' settings, you could create some branch protection rules to avoid such bypass. But while it's nice for a single project, our goal is to be able to globally prevent bypassing the pipeline.

That's where GitHub Rulesets come into play.

They essentially act quite the same as branch protection rules, expect you define these rules at the organization level.

This way, we were able to protect our main branches for all our repositories, and require them to successfully pass the CI/CD pipeline before they are able to merge.

## Examples and documentation

Having clear examples so people can check how they can implement tests, run commands (ruff, pytest, ...)

# What we have today

python topic on the repo + pyproject.toml

# Some flaws

We yet cannot enforce it to people, as GitHub Rulesets cannot apply to topis, but only custom properties.
People can cheat by updating the pyproject.toml

# What's next?

Talk about SonarQube, mkdocs, uv...
Talk about Terraform and other stuff
Custom properties (only available in 3.15)

# Conclusion

TBD
