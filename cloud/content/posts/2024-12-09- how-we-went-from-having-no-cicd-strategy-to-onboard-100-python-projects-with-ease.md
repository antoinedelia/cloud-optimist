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

Talk about the use of black before

## Linting

## Unit tests

## Code Coverage

## Organization Folders for Jenkins

## GitHub Rulesets

## Examples

Having clear examples so people can check how they can implement tests, run commands (ruff, pytest, ...)

# What we have today

python topic on the repo + pyproject.toml

# Some flaws

We yet cannot enforce it to people.
People can cheat by updating the pyproject.toml

# What's next?

Talk about SonarQube, mkdocs, uv...
Talk about Terraform and other stuff
Custom properties (only available in 3.15)

# Conclusion

TBD
