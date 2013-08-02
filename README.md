omniauth-sharedcookie
=====================

[![Code Climate](https://codeclimate.com/github/cdman/omniauth-sharedcookie.png)](https://codeclimate.com/github/cdman/omniauth-sharedcookie)
[![Dependency Status](https://gemnasium.com/cdman/omniauth-sharedcookie.png)](https://gemnasium.com/cdman/omniauth-sharedcookie)

Ruby Omniauth strategy for authenticating using a cookie encrypted with a shared secret.

The secret should be in JSON format and encrypted with AES-256-CBC (with PKCS#7 padding) and authenticated with a SHA-256 HMAC.

See examples/generate-cookie.py for an example as to how such a cookie can be generated.

This code is available under the Apache 2.0 License.
