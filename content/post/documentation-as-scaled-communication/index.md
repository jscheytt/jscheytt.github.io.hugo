---
title: Documentation as Scaled Communication
date: 2023-10-24T08:21:20+02:00
tags:
    - devops
    - platform-engineering
---

Technical documentation is important, but almost no one enjoys writing it.
At least, I have yet to meet anyone who shares my passion for writing docs.
To me, documentation is not just a chore you do to check a compliance box.
In fact, I believe it can even be a rewarding experience.

I am also convinced that writing documentation is a *core skill for Platform Engineers* running any [Internal Developer Platforms](https://internaldeveloperplatform.org).
Developer Platforms need a product mindset, and products need documentation so that users can understand usage and discover features.
And I believe that **technical documentation is a means to scale up your communication**, especially in the platform context.

Let me explain with an example:
If someone pings me directly and asks about a specific technical problem in using the platform (e.g. "How do I restart my application in staging?"), I could respond via a video call (most expensive option, but sometimes necessary) or by giving them the necessary steps directly.
As an alternative, I could also take a few extra minutes to write a documentation article (e.g. a runbook) about it and send the person a link to the article.
The next time someone asks about this specific problem, I can *save a lot of time* by not writing out the steps in all detail again.
Instead, I can get into the habit of responding to common questions with links to documentation.

This can not only reduce the time *you alone* spend handling requests:
If your documentation platform has a good search functionality, you may eventually be able to *teach people to search through the docs* before making requests, saving time for both Platform Engineers and Developers.
If your documentation tools are configured as openly as possible for contributions, you might even get people to *actively participate* in improving your articles, perhaps even writing new ones themselves.

I have witnessed some of these effects firsthand.
Let me name this observation **Documentation as Scaled Communication** (or DASC, if you feel like using acronyms).
I am sure that this principle applies very broadly, but I want to keep the focus of this post on *technical documentation* and on *Platform Engineers* because that is my primary background.

## Challenges

So why is writing docs so *hard*?
From my point of view, we have several challenges to address:

1. We need to learn **communication** through practice, review, and feedback.
1. We also need to learn **writing** (again, through practice, review, and feedback).
1. Documentation tools need **extremely low friction** (i.e. very good UX).
1. Tools need to be **configured as wide open** as possible for contributions.

### Practicing Communication

How can you communicate effectively?
Effectiveness is always determined by the goals of your communication.
Let's say we have the following goals for platform engineering:

* Enable developers to be highly productive
* Enable development teams to deploy to production quickly and with confidence

These goals put us in a position where **empathy** plays a critical role.
I am not talking specifically about *technical means* like surveys or specific SLOs.
What I am talking about is a certain *attitude* towards the consumers of our services.

Raw data and measurements are helpful, and they can certainly guide us as we try to learn from incidents or understand certain usage patterns.
But numbers have their limits, and the people who use our services are not distant technical entities, but *blood and flesh humans struggling to deploy features and fix bugs*.
Learning to empathize with our users can include the following:

* Sit down with a user (maybe even in person, if possible) and ask for feedback on how they use the platform.
  * **Asking proactively** is radically different from waiting for bug tickets and incident reports.
* Listen actively:
  * First, listen (you may even want to take notes).
      Then keep asking questions to find out what the user is *really* trying to accomplish.
  * Your primary focus should not be to get fodder for your bug tracker.
      (Take notes, though, if something comes up that you did not know about.)
      Instead, **focus on understanding the user's overall interaction with your services:
  * How do they develop and generally work as a team?
      What is their workflow like?
      Where are they least productive?
      Are they using tools outside your platform that could or should be integrated?
* **Don't insist on your preferences**.
  The platform is not there for its own sake, but to enable the developers.
  * This is most evident when I answer complaints with "But that's not how the system is supposed to be used! Did you even read xyz?"
  * I struggle with this point a lot.
      When you build a platform, you design for certain usage patterns.
      But you can never anticipate how those needs might change in the future.
      And if those needs change drastically, you may have to refactor your platform to a greater extent (which will cause you a lot of work).
  * I'm not advocating blindly following every user suggestion --- your product owner will have to prioritize things anyway.
      I am also not discouraging helping people understand how to use the existing platform effectively.
      My point is:
      If you scold people for trying to get things done, you will discourage them.

There are a few more resources I recommend for learning to communicate effectively as a Platform Engineer:

* Watch this talk about "[How did it make sense at the time?](https://www.infoq.com/presentations/incidents-investigation)" (HDIMSATT).
  It is focused on incidents but the same reasoning is helpful for learning empathy with your users.
* *[SRE Embedding](https://sre.google/sre-book/operational-overload)*:
  Sometimes, you can take empathy to a more extreme level by embedding a Platform Engineer into an app dev team for a period of time.
  You as a Platform Engineer will put on your SRE hat and work alongside the developer team in their everyday challenges.
* Read about and learn from some of the great models of empathy, such as Jesus of Nazareth (e.g. in the first four books of the New Testament), the God who became human (this allowed Him to empathize more with us, but also us to empathize more with Him).

### Practicing Writing

Everyone at work communicates all the time.
Working remotely has forced us to do so in more written form than ever before --- and I think this is a good thing overall!
Sure, it's faster to work together in the office, where it's super easy to quickly ask questions and show things, but asynchronous written communication is much more inclusive and promotes transparency.

There are many ways to improve your written communication (e.g. [don't make people wait](https://nohello.net)).
Your written communication will always be better the more you *empathize* with the other person(s) (see previous point).
Still, you can practice the following skills to improve your writing in chats:

1. Write **complete sentences** by default.
1. Adhere to **basic grammar and syntax** (just as you would when writing code).
    * You can use AI assistance for this like [DeepL Write](https://www.deepl.com/de/write).
      (Hint: I refined this blog post using DeepL Write.)
1. Write **short and clear sentences**.
    * If your message gets longer, use bullets and headings to break your message into more readable chunks.
    * Familiarize yourself with the **formatting options** your chat tool offers.
      Some tools allow Markdown, for example.
1. *In group chats* (i.e. when communicating with several people at once):
    1. Avoid using **literal backreferences** ("this thing", "that").
      Use the "reply to" feature (or better yet, if available, start a **thread**) to maintain/restore context.
    1. Use @-**mentions** to notify a subset of people in the current chat, if your message does not address everyone.

In the spirit of SRE and [Learning From Incidents](https://www.learningfromincidents.io), we can also look back at past communications and learn from them.
Feel free to try these steps as an example:

1. Search through your chat history, especially group chats where there are a lot of people and a lot of communication.
1. Try to find situations where misunderstandings occurred.
  Pick a situation and think about the following questions:
    1. What were the basic assumptions that the different people involved had?
    1. To what extent were the different mental models of these people wrong? Why?
    1. How could the mismatch between mental model and reality have been uncovered earlier?

### Low-Friction Editing

Now we turn briefly to the tool side of things:
If you do not make editing pages and creating documents *as fast and convenient as possible*, you will frustrate people and lose potential editors.
Those editors could be people on the platform team *and* on the development teams!

I see this as a very limiting factor when trying to choose a documentation tool.
One category of documentation tools I have specifically avoided *for internal development platforms* are *Static Site Generators (SSGs) fed from a Git repo*.

Let me be clear about this:
I am a huge fan of Git!
[My writing a book about GitOps](https://www.linkedin.com/feed/update/urn:li:activity:7120420743795892225) should leave no doubt about that.
But even if you have a template where editing any single page is just a click away *and* you link directly to a web IDE *and* you can enable automerge on the instantly created feature branch, you still have to wait for a green build to pass.
(Allowing commits directly to the default branch would be careless, because it might break the build --- and you will never get around waiting for the build pipeline on the default branch anyway).
And that wait is (I think) still way too long, and makes the barrier to contributing way too high.

My current preference is Confluence Cloud (Cloud, not self-hosted!), but my experience is very limited.
Please send suggestions!

### A Culture of Contributing

Whenever I see organizations talking about *approval processes in documentation tools*, I get sad.
Because sure enough, they will get exactly what they asked for:
Documentation that is picture perfect and set in stone --- it cannot be changed unless you explicitly ask for permission.
But at the same time they **lose everything that makes documentation valuable**:

* Documentation becomes **outdated** extremly quickly because you cannot live a *Culture of Contributing*.
* **RBAC** becomes difficult, and those who maintain it may not always be available.
  This will make even users who have permission to edit and manage certain parts of the content to feel reluctant to write shareable documentation instead of directly responding to requests.
* People will **always make direct requests** because they can get a faster response.
  * They may *not always* get it faster because everyone is busy, but by texting a human you at least have a small chance that someone will respond faster than you will find something in the potentially outdated docs.
* When documentation becomes outdated and permissions are complex to obtain, you end up with *shadow documentation* (e.g. in Word documents on shared drives) or (by default and by far the worst) *no documentation at all* happens and **valuable knowledge is lost**.

I have never seen an organization suffer from vandalism or other malicious overuse of documentation tools.
The only organizations I have encountered are those with typical people who are just trying to do their jobs well and are naturally reluctant to write anything down unless they are forced to.

For this reason, I believe that **documentation tools should be configured with maximum editability** to encourage a Culture of Contributing.
You may want to disable deletion and only allow archiving to protect content from disappearing accidentally, but otherwise everything should be as *welcoming* towards contributions as possible!
Choose a tool that allows versioning / page history so that you can revert to a known good state if any unwanted changes are made.

## Documentation Devices for Platform Engineers

I have identified a few types of technical documentation that, in my experience, are particularly valuable in the context of Platform Engineering:

1. Runbooks
    * By giving step-by-step instructions you enable people to perform certain typical actions themselves.
      For an example of a very simple runbook, see the list at the end of [Practicing Writing](#practicing-writing).
    * If the amount of code snippets in a runbook gets too large, you might consider writing a script, putting it into a Git repo and creating an automated runbook that can be triggered by any user through a manual pipeline.
1. [Architectural Decision Records](https://adr.github.io) (ADRs)
    * This is in the spirit of HDIMSATT (see [Practicing Communication](#practicing-communication)) and allows you to foster collaboration and structured discussion around important technical decisions.
    * It allows you to better understand the assumptions and constraints that were in place at the time.
      When you return later, you can re-evaluate whether those assumptions still hold true and revisit the decision in light of new constraints.
      (Remember to create another ADR for the new decision you take.)
1. [draw.io](https://app.diagrams.net) or [Mermaid](https://mermaid.js.org) for diagrams
    * Many documentation tools come with integrations for these.

In addition, there are also overarching documentation frameworks such as [arc42](https://arc42.org/overview).
At [Mimacom](https://www.mimacom.com), we have used arc42 in several projects and found the structure very helpful.
To keep the momentum though, don't think too much about which section a single page belongs to; you can always restructure later after writing your current piece of content.
Fortunately, there are [downloads available](https://arc42.org/download) for Asciidoc, Markdown, LaTeX, and a few other formats.
