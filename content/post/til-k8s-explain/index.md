---
title: kubectl can explain all resource types in detail
date: 2022-02-01T14:53:18+01:00
categories:
    - today-i-learned
tags:
    - kubernetes
    - cli
---

```console
$ kubectl explain statefulset
KIND:     StatefulSet
VERSION:  apps/v1

DESCRIPTION:
     StatefulSet represents a set of pods with consistent identities. Identities
     are defined as:
     - Network: A single stable DNS and hostname.
     - Storage: As many VolumeClaims as requested. The StatefulSet guarantees
     that a given network identity will always map to the same storage identity.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object>
     Spec defines the desired identities of pods in this set.

   status	<Object>
     Status is the current status of Pods in this StatefulSet. This data may be
     out of date by some window of time.
```

I guess this will reduce a lot of my googling in future.

And it even works on nested fields!

```console
$ kubectl explain deployment.spec.template.spec.containers
KIND:     Deployment
VERSION:  apps/v1

RESOURCE: containers <[]Object>

DESCRIPTION:
     List of containers belonging to the pod. Containers cannot currently be
     added or removed. There must be at least one container in a Pod. Cannot be
     updated.

     A single application container that you want to run within a pod.

FIELDS:
   args	<[]string>
     Arguments to the entrypoint. The docker image's CMD is used if this is not
     provided. Variable references $(VAR_NAME) are expanded using the
     container's environment. If a variable cannot be resolved, the reference in
     the input string will be unchanged. The $(VAR_NAME) syntax can be escaped
     with a double $$, ie: $$(VAR_NAME). Escaped references will never be
     expanded, regardless of whether the variable exists or not. Cannot be
     updated. More info:
     https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell

   command	<[]string>
     Entrypoint array. Not executed within a shell. The docker image's
     ENTRYPOINT is used if this is not provided. Variable references $(VAR_NAME)
     are expanded using the container's environment. If a variable cannot be
     resolved, the reference in the input string will be unchanged. The
     $(VAR_NAME) syntax can be escaped with a double $$, ie: $$(VAR_NAME).
     Escaped references will never be expanded, regardless of whether the
     variable exists or not. Cannot be updated. More info:
     https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell

   env	<[]Object>
     List of environment variables to set in the container. Cannot be updated.

   ...
```
