---
title: Guessing UUIDs would actually take very long
date: 2021-10-06T08:32:23+02:00
tags:
    - maths
math: true
---

UUIDs are 128-bit numbers.
That means they have $2^{128}$ possible values which is roughly $3 \cdot 10^{38}$ (or in scientific notation, 3e38).

Does this range make it safe for cryptographic purposes?
Most people on the internet say an emphatic "No!", so I am just keeping this here as a 🚨 disclaimer.

But is it at least **collision-safe**?
I think definitely yes.
And is it also **guess-safe**?
Let's explore that question with a bit of maths:

## Example Scenario

Let's say you have an API and you know the records are referenced by their UUID.
And let's say you wanted to guess any valid record (because [💰 money](https://stackoverflow.com/questions/3652944/how-securely-unguessable-are-guids)).

What is a realistic scenario, i.e. a reasonably expectable time it would take you to find a valid record?
Let's just naively assume you find a valid UUID after randomly iterating over half of all possible UUIDs.

## How long would that take you?

Imagine you had started firing requests at your hypothetical API **at the beginning of the observable universe**, i.e. about 1.3772e10 years (or 4.3437e17 seconds) ago.
And you send requests at a rate of **1 trillion (1e12) requests per second** (and, of course, your target API responds at the same rate 😉).
(You would have to be *very* physically close to the API server - at a trillionth of a second, light and therefore information travels only a measly 0.3 millimeters ...)

How many UUIDs would you have covered?
You would have processed barely **1 billionth of all possible UUIDs** (to be precise: 1e12 * 4,3437e17 / 2^128 ≈ 1.2765e-9).
That is not even remotely close to half of all UUIDs.
To cover half of all possible UUIDs you would have to continue for another ... how many years?

$$
\frac{(1.2765 \cdot 10^{9} - 1) \cdot 4.3437 \cdot 10^{17} \ seconds}{2} = 2.7725 \cdot 10^{26} \ seconds = 8.786 \cdot 10^{18} \ years
$$

And these roughly 10 quintillion years are roughly **1 billion times the age of the universe**.
So you would very probably never live to see the matching of the UUID.

But, just hypothetically assuming you have started your client's requests at the dawn of time and can continue to run it on this Earth unattended for as long as this planet exists:
Would you still **physically have enough time** to execute your requests (for half of all UUIDs)?

We are going into [lots of speculation](https://en.wikipedia.org/wiki/Timeline_of_the_far_future) now, but:

* In latest 2e9 years, all life will have vanished from Earth, the oceans have evaporated, the surface temperature will reach around 150 ° C.
    * You better build your client and API servers very temperature robust 🏜 ...
* In 1e14 years, all stars will have exhausted their fuel.
* Assuming the Earth has not been completely engulfed by the Sun during its red giant phase,
    * and assuming the Earth was not already ejected from its orbit into outer space (not another galaxy),
    * then the Earth would surely collide with the then black dwarf Sun in 10e20 years.

So yes, with a bit of preparation (temperature hardening, robust solar panels, radiation shielding) your client server would probably finish *just in time* before the Earth itself becomes mere history 😉.
