---
title: Trying to simplify k8s labels can be dangerous for your routing
date: 2021-12-03T10:43:01+01:00
categories:
    - today-i-learned
tags:
    - kubernetes
---

Today I was refactoring a bigger configuration setup that is built with [kustomize](https://kustomize.io/).
I see kustomize as a light-weight way of packaging multiple Kubernetes manifests, together with a little bit of logic.

The **base kustomization** of the application config repo I was refactoring looked something like this:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - manifests/cronjob-backup.yaml
  - manifests/deployment.yaml
  - manifests/ingress.yaml
  - manifests/pod-disruption-budget.yaml
  - manifests/service.yaml
commonAnnotations:
  source: java
  tenant: acme
configMapGenerator:
  - name: acme-app-config
    files:
      - configs/10-local.properties
      - configs/30-local.properties
      - configs/40-local.properties
```

I have an almost pathologic tendency to simplify and DRY everything up that I find, especially in configuration code.
And as I saw a lot of **repeating Labels** in the manifests, I thought "Well, let's just unify them."

So I went ahead, removed the repetitive Labels from the manifests and added the following block to the kustomization:

```yaml
commonLabels:
  app: acme-app
```

I knew a bit about Kubernetes Services and that they *use Labels to find the Pods to which they should direct their traffic*.
That's why I thoroughly verified that after my change the Service and the Deployment would still have **the same selector labels**.
🤗 Nothing seemed off ...

I committed and pushed my changes, and after the Deployment had finished restarting, I clicked through the application.
👀 Oddly enough some of the requests succeeded as expected, but some kept failing with a 💥 `502 Bad Gateway` error!
At first I tried troubleshooting quickly, but soon I opted for just reverting my changes and pushing the revert commits to undo my changes.

For debugging I compared the output of `kustomize build` before and after my changes.
After some scrolling I came across the **CronJobs** I defined for backup[^cronjob-purpose].

[^cronjob-purpose]: It does not matter for which purpose I created this CronJob, it could have been any Kubernetes Resource that creates Pods.

I should probably not have been surprised that the CronJob also had the same Labels I gave it via the kustomization.
But now a suspicion started sneaking in:

> What if the **completed Pods** of the CronJob received traffic from the Service because they had **the same Labels**?

Following this idea, I refactored my configs a bit.
Soon, I was able to ensure that requests to the Service would only point to my target Deployment (and not to any other Pods):

```diff
diff --git a/base/kustomization.yaml b/base/kustomization.yaml
index 6c1c6f7..b77b0fc 100644
--- a/base/kustomization.yaml
+++ b/base/kustomization.yaml
@@ -15,7 +15,6 @@ commonAnnotations:
   source: java
   tenant: acme
-commonLabels:
-  app: acme-app
 configMapGenerator:
   - name: acme-app-config
diff --git a/base/manifests/deployment.yaml b/base/manifests/deployment.yaml
index 1e4aa3f..a60a798 100644
--- a/base/manifests/deployment.yaml
+++ b/base/manifests/deployment.yaml
@@ -16,6 +16,9 @@ metadata:
 spec:
   replicas: 1
+  selector:
+    matchLabels:
+      app: acme-app
   template:
     metadata:
       labels:
+        app: acme-app
     spec:
       containers:
diff --git a/base/manifests/service.yaml b/base/manifests/service.yaml
index b05d898..89af021 100644
--- a/base/manifests/service.yaml
+++ b/base/manifests/service.yaml
@@ -10,3 +10,5 @@ spec:
     - name: api
       port: 8080
+  selector:
+    app: acme-app
```

(Notice that the Deployment needs the Label both in `.spec.selector.matchLabels` and `.spec.template.metadata.labels`!)

And surely enough, after deploying this fix, the request to the application worked flawlessly 😊✅.
