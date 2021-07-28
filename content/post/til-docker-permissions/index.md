---
title: Docker does not really help you a lot trying to get permissions right
date: 2021-07-23T14:42:07+02:00
categories:
    - today-i-learned
tags:
    - docker
---

I really love Docker, and I also come to like security more and more.
One advice I have been hearing a lot (e.g. in this [Container Security Cheat Sheet from Snyk](https://snyk.io/blog/10-docker-image-security-best-practices/)) is that **you should not run your container as a root user**.

"Easy thing," I thought to myself, "I am just going to put something like `USER {app}`" at the top of my Dockerfile."
Well, think again, because:

```Dockerfile
FROM node:lts

USER node
# I would have thought that after this point, every action will happen in the name of this user
# and also that every created directory and file will belong to this user ... 😕 But:

# ⚠️ This directory is created by root:root!
WORKDIR /app

# ⚠️ These files will be copied over to be owned by root:root!
COPY package*.json ./

# 💥 This step fails in some (not all!) environments with errors like "Not enough permissions on /app"
RUN npm install && \
    npm run verify

# ⚠️ If you manage to get to this point, these files, too, will be copied over to be owned by root:root!
COPY . .

ENTRYPOINT ["npm"]
```

I ended up fixing it by creating the directory and then `chown`-ing it.
Equally I executed the `COPY` instructions with the `--chown` flag.
In the end I refactored it a bit using some `ENV`s, too:

```Dockerfile
FROM node:lts

# Ensure that target WORKDIR exists and is owned by target (non-root) user
ENV USERNAME=node
ENV USERID=$USERNAME:$USERNAME
ENV TARGETDIR=/app
RUN mkdir -p $TARGETDIR && chown -R $USERID $TARGETDIR
WORKDIR $TARGETDIR

USER $USERNAME

COPY --chown=$USERID package*.json ./

RUN npm install && \
    npm run verify

COPY --chown=$USERID . .

ENTRYPOINT ["npm"]
```
