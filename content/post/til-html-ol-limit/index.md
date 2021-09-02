---
title: HTML limits you to a 31-bit integer in ordered lists
date: 2021-09-02T08:55:22+02:00
categories:
    - today-i-learned
tags:
    - html
---

HTML allows you to specify a starting number from which an ordered list (`<ol>`) should start.
I thought "Is there an upper bound?".

Turns out: Yes, there is.
It's 2147483647 (i.e. 2<sup>31</sup>-1).
No idea why it's not 2<sup>32</sup>-1, though ...

```html
<ol start=2147483645>
    <li>I am still in order</li>
    <li>As am I</li>
    <li>Me too</li>
    <li>Limit reached</li>
    <li>Limit reached</li>
    <li>Limit reached</li>
</ol>
```

The above snippet will render as the following:

<ol start=2147483645>
    <li>I am still in order</li>
    <li>As am I</li>
    <li>Me too</li>
    <li>Limit reached</li>
    <li>Limit reached</li>
    <li>Limit reached</li>
</ol>
