---
title: Vault administration

---

# Vault Administration

---

A guide that goes deeper into configuring HashiCorp Vault.

---

## Introduction

- Who am I?
- Who/what is Adfinis?
- Who are you?

---

## Topics

- Tokens
  - Token types
  - Token leases
- Logs
  - Audit
  - Operational
- Policies
  - Templating
- Configuration
  - CLI
  - Terraform

---

## Vault

A tool to manage *secrets*, typically for *systems*.

> Secrets: Anything sensitive; credentials, API keys, SSL keys, etc.

> Systems: An application like Tomcat, CI, k8s, etc.

----

## Tokens

Tokens are the core method for **authentication** of clients within Vault.

> Nearly all requests to Vault must be accompanied by a token.

Tokens are authenticated by an **auth method**.

---

## Token types - Service and Batch

Two main types of Vault tokens: 

| Token type | Example     |  Description |
|:-----------|:-----------:|:------------:|
| Service    | hv**s**.xxx |              |
| Batch      | hv**b**.xxx |              |

---

## Token types - Recovery Token



---

## Token types - Service Tokens

Vault persists the service tokens in its storage backend.

You can renew a service token or revoke it as necessary.

---

## Token types - Vault CLI

```yaml
Usage: vault token <subcommand> [options] [args]

  This command groups subcommands for interacting with tokens. Users can
  create, lookup, renew, and revoke tokens.

  Create a new token:

      $ vault token create

  Revoke a token:

      $ vault token revoke 96ddf4bc-d217-f3ba-f9bd-017055595017

  Renew a token:

      $ vault token renew 96ddf4bc-d217-f3ba-f9bd-017055595017
```

---

## Token types - batch tokens

Vault does not persist the batch tokens.

They carry minimal information to perform Vault actions, making them lightweight and scalable.

But they lack flexibility and features of service tokens.

---

## Token leases - service token

Leases created by service tokens (including child tokens' leases) are tracked along with the service token and revoked when the token expires.

---

## Token leases - batch token

---

## Logs

- Audit logs
- Operational logs

----

## Policies

Tokens are mapped to *policies*.

Policies describe *permissions* of a Vault token.

----

## Policies templating


----

## Terraform configuration


----

## Auth engines


---

## Secret engines (static)


---

## Secret engines (dynamic)


---

## Questions

---

## Thanks
