---
title: I Install Washing Machines (My Latest Job Metaphor)
date: 2022-10-04T14:30:29+01:00
tags:
    - automating
    - devops
---

## So What Exactly Do You Do For A Living?

Whenever we meet new people (or good friends, it sometimes doesn't make a big difference 😄), the above question will come up.
My wife (who is a doctor and has understably fewer problems explaining her job) is always excited to get yet another chance to "finally understand" what it is that I am doing at work as a **Cloud Automation Engineer**.

That is the fancy title we at [mimacom](https://flowable.wd3.myworkdayjobs.com/de-DE/mimacom/details/Cloud-Automation-Engineer--m-f-d-_JR100074?q=cloud%20automation%20engineer) give to people working in *Site Reliability Engineering* and *DevOps Engineering*, and I have grown to really like it because it starts to convey a lot of meaning right away.
Unfortunately, it's also long and not particularly established (yet).

In this blog post I will explore one analogy that came to my mind recently.
I have not tried it out in the wild yet, but I am fascinated by the similarities between deploying washing machines and deploying web applications.

## My Latest Metaphor

Let's say I work in a company that builds, delivers, and maintains washing machines for laundromats.
The colleagues in my team whom I work most closely with design new washing machine models.
You could say they design or "develop" the washing machines.

They do this very frequently — even so frequently, that they tweak the current model mostly on a daily basis.
Whenever they change the model, we want to bring these improvements to our customers as quickly as possible.

And here begins my responsibility as Laundry Automation Engineer™️.

### Delivering New Washing Machines

There are several steps that now need to happen in succession until the new model lands at our customers (the laundromats).
We also call this a **pipeline**:

1. The designers/developers wrote some simulations to check if the models they produce really work as they should.
   I run these simulations on a computer.
1. I send the model to the factory to let some construction robots assemble it.
1. I take the assembled model, plug it into current and water and run some standard washing programs and test for potential leaks and similar problems.
1. I package up the assembled model (together with its necessary accessories) and put it into a van.
1. And finally, I drive the new washing machine to the customer, connect the new washing machine, disconnect the old one and dispose of it.

But a good Laundry Automation Engineer™️ will normally not do any of these steps above themselves.
Instead, he or she will build robots to do it for them.
Robots are a lot more reliable, faster, and cheaper when it comes to repetitive tasks.

So, in short:
**I build robots that automate all the above steps.**

And if there is an error during any of the above steps, the pipeline for the current model change will stop (so we don't deliver broken machines).
I will then look what caused the error and fix it.

Let's zoom in on a few details around the last step when the robots install the new machines:

### Zero-Downtime

Our laundromats are very highly frequented, basically around the clock, even on weekends.
People come and go all the time.
They put their clothes into a machine, select a program, pay with coins or by card, set it off running, and return when their laundry is supposed to be ready.

For simplicity, I will now switch back to me as the one doing the actual work (instead of the robots).
Whenever I install a new washing machine to replace a currently running one, I have to be very careful:
The people running the laundromat want to have as few interruptions as possible so that people can start washing programs all the time.
They know that if they have to many interruptions, potential customers will get annoyed because a queue will form, and if they have to wait for too long they will go elsewhere.

So normally, I will install the new washing machine first (connect to current and water), mark the old machine as "stale" (so customers can only get their laundry from it but not start any new programs), then disconnect the old one.
This does introduce a little bit of energy and water overhead for the laundromat, but they happily pay that price.
And good for me that in reality I have robots managing all this for me.

## Behind The Scenes: A Glossary

Washing Machine:
: A web application that communicates over HTTP.
  It receives requests (dirty laundry and some program parameters) and delivers responses (clean laundry in the happy path).

Laundromat:
: A company that makes most of its business value through running web applications and processing data in a value-adding way.

Designer/Developer:
: An application developer writing code in a programming language.

Bringing Improvements To The Customer Asap:
: We call this Continuous Delivery or Continuous Deployment.

Laundry Automation Engineer:
: Just made this up. This would be the Cloud Automation Engineer / DevOps Engineer.

Pipeline:
: The above example describes a Continuous Integration pipeline that also deploys at the end.

Pipeline Step 1:
: This step could map to linting, unit testing, and static code analysis.

Pipeline Step 2:
: This is a "build" or "compile" step.

Pipeline Step 3:
: This step could map to integration testing, end-to-end-testing, fuzzying, and security testing of sorts.

Pipeline Step 4:
: This is a "container image build" step.

Pipeline Step 5:
: This is a "deploy" or "release" step.

Robot:
: A script with prescribed steps which is executed automatically whenever a new change is published.

Zero-Downtime:
: This is just a rough description of how I understand the default `Deployment.spec.strategy.type=RollingUpdate`.
  I think it's not perfect but still fits good because in both situations you have the (somewhat conflicting) unbroken, continuous streams of requests/people and electricity.
