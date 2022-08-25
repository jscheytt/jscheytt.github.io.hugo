---
title: ArgoCD is like the Kubernetes Dashboard but for GitOps
date: 2022-08-25T15:00:09+02:00
tags:
    - kubernetes
    - gitops
---

FluxCD was my first love in the GitOps space.
I worked with it when it was still v1, had no chance to use, and since about a year I returned to using it in its glorious, rewritten v2.

I haven't given ArgoCD a try so far until this week somebody suggested trying out [ArgoCD Autopilot](https://argocd-autopilot.readthedocs.io/en/stable/).
The process was super smooth and in less than 10 minutes I had a running ArgoCD dashboard in my local minikube cluster.

And holy moly I have to say:
ArgoCD is awesome!
In the less than one hour I have seen it close up now, I already see so many possibilities that are hard to do when you try to scale Flux:

1. Having a UI at all
1. Managing applications in multiple clusters from 1 Git repo *with explicit assignment to these clusters*
1. The UI is basically the better [Default Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) but for GitOps:
    * The Kubernetes Dashboard gives you a very "relational" view of your resources, much like [k9s](https://k9scli.io/) does (albeit with fewer resource types).
    * I tried [Kubevious](https://github.com/kubevious/kubevious) in some projects because it allows you to view **related resources hierarchically together**.
        * But it is pretty buggy (especially the mysql DB deployed with it) and has not fulfilled its promise for me.
        * Additionally, it's read-only and does not show you a Events or container logs.
    * ArgoCD however gives us the **best of both worlds**:
        * Related resources are **shown hierarchically** (e.g. Deployments create ReplicaSets create Pods).
        * You can even group them into Apps, ApplicationSets, and Projects.
        * If you open a Resource (e.g. Pod), you can see its Events and also its logs!
1. [Preview Environments](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/) seem relatively straightforward.
1. I have heard many rumors that Progressive Delivery is easier with ArgoCD (or at least involves less manually scripted yaml generation pipelines).

As a Cloud Automation Engineer, one of my main missions is to **deliver stable apps**.
And this highly involves **stable processes** for my team.
ArgoCD feels like the perfect fit:
I can deploy my apps with ArgoCD and everybody with access to it can debug resources, see which versions are currently deployed, and maybe even promote apps to the next environment!

There also seem to be use cases (probably especially in a setup with separate platform and app dev teams) where [deploying FluxCD and ArgoCD together](https://youtu.be/QNAiIJRIVWA?t=731) makes sense.
But I am definitively going to give ArgoCD a shot in some important environment soon.
