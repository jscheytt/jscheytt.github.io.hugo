---
title: You can create TOTP tokens via CLI without a smartphone
date: 2021-08-27T08:20:41+02:00
categories:
    - today-i-learned
tags:
    - security
---

All you need is the secret of your TOTP.

The QR code is just a representation of a `oath://` URL
That URL contains the secret as a query parameter.

```sh
# Install oathtool
brew install oathtool
# Use your secret, e.g. as a base32-encoded string
oathtool --totp --base32 "MFRGCZDTMVRXEZLUBI======"
```
