---
title: Kubernetes is still willing to show you Dangling Resources in your Terminating Namespace
date: 2021-10-29T12:11:47+02:00
categories:
    - today-i-learned
tags:
    - kubernetes
---

```sh
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found "$NAMESPACE"
```

Props to [RedHat](https://cloud.redhat.com/blog/the-hidden-dangers-of-terminating-namespaces).
