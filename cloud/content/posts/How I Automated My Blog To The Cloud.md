---
title: "How I Automated My Blog To The Cloud"
date: 2024-09-04T14:00:00+02:00
draft: true
---

# How it started
When I started blogging, I was still in engineering school. And the world of websites and blogs was still new to me. So when I wanted to create a personal blog, I turned to what I thought was the best solution at the time: WordPress.

Like it or not, WordPress is quite easy to use for beginners, even more for me who was still discovering how to host a website at the time.

So, with a brand new OVH account, I was able to quickly setup my personal blog in a few clicks!

And when the time came where I wanted to create a blog dedicated to professional topics, I naturally came back to my ol' friend WordPress.

# Issues arised

But after some months, the glory of WordPress started to fade into a darker view. Sure, it was convenient to add a new post by going through WordPress' UI, but maintaining the website was always boresome. Moreover, a WordPress installation requires using a database, which incured a higher bill at the end of each month.

All of this for a blog that I knew did not receive many visits each day.

Surely there was a better way to do this.

# A new challenger appeared: AWS

In parallel, I had an opportunity working for a company that focused on the Cloud, more specifically AWS.

At the time, Cloud was brand new to me. But I was hearing more and more about it, and I wanted to check what was all the fuss around it. Would this be a true life-changer, as people would call it, or would it be yet again another buzz word, and become a dying trend?

Long story short, it was (and still is) amazing! Not only was it an amazing discovery, I could simply not see a world without Cloud anymore.

The more I learned about all these amazing AWS services, the more I thought: isn't there a way for me to leverage the Cloud to host my blog?

With that in mind, I started looking for options.

I wanted to make a quick shift to AWS, so I was first considering services that would offer WordPress support. And while I found some, there were still some levels of complexity that I would sure I could get rid of.

So I decided to think again. Maybe the issue was not about the hosting services. Maybe the issue was that I was using an inappropriate tool for my project. Maybe it was time to let go of WordPress.

# Discovering Hugo

Before searching for a new tool, I tried to think of what I needed.

My blog was essentially a simple webpage, a static website with no fancy JavaScript or stuff like that. Plus, there was no backend to handle API calls for user authentication for example, so I could simply not use any database at all.

So what I needed was essentially a way to focus on the content of the blog, and make sure I could attach to it a nice theme, and that was it!

But, as I'm an engineer, so in essence, a real bad designer, I wanted to avoid having to deal with CSS as much as possible. Again, I wanted to focus on the content, rather than the looks. So I searched and searched for the perfect tool. And I didn't had to look too long to find it: Hugo.

Upon arriving on its website, I was greeted by an intriging message message: `The world’s fastest framework for building websites`. Surely, I was curious, and dug into the documentation. And oh boy, was I not disappointed.

This was exactly what I wanted. A framework where I had to write in markdown format, that would be converted to HTML for me. Plus, it came with a bunch of themes, so I didn't even had to bother about the design. I could just pick one that I liked, and move on.

So, without losing any more time, I started to setup this new blog. I came across a handy script that converted my whole Wordpress database into compatible markdown syntax, and I was ready to go!

# Terraform to the rescue

TODO: talk about Terraform to setup S3 + CloudFront

# Copy and paste my website? Ain't no way

My website was now perfect. I could focus on its content, just like I wanted. But there was one last thing that I knew I could enhance: the deployment.

You see, everytime I wanted to create a new post, I had to build my website, and drop the files into my S3 bucket, on my AWS account. For a lazy developer like myself, this was of course, a terrible waste of time and energy.

So I dived into the magical world of CI/CD pipelines. And despite Jenkins best effort to get noticed, I quickly turned to what seemed the most logical at the time: GitHub Actions.

GitHub Actions are basically CI/CD pipelines that you can define directly in your source code (assuming that you are using GitHub, of course). The main benefit is that you do not need any additional account, and the syntax is pretty straightforward.

So, I setup the pipeline, and everything went green!

# Wrapping up

At the beginning, I had to maintain a WordPress blog, which was tedious because of versionning, maintainability and ease of deployment.

Today, my blog is stored on GitHub, and on every single change of its content, everything is deployed automatically to AWS, for less than a dollar a month.

After realizing the power of static websites, AWS and GitHub Actions, I migrated three other personal websites to this new workflow, and I am now never scared to make a change!
