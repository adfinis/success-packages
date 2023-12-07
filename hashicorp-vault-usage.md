---
title: Vault usage

---

# Vault usage

---

This presentation guides you through the usage of Vault.

---

## Introduction

- Who am I?
- Who/what is Adfinis?
- Who are you?

---

## Topics

-

---

## Vault

A tool to manage *secrets*, typically for *systems*.

> Secrets: Anything sensitive; credentials, API keys, SSL keys, etc.

> Systems: An application like Tomcat, CI, k8s, etc.

---

## Ways to use Vault

- CLI.
- UI.
- API.

> In the end, it's all API.

---

## Vault CLI 1/5

Mostly used for administration and debugging.

----

## Vault CLI 2/5

```text
export VAULT_ADDR='http://127.0.0.1:8200'
```

----

## Vault CLI 3/5

```text
vault login
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.OVWwDAoEvtdYh8Qe0nvFuOPE
token_accessor       76oHT2vMS7CAQYPPxDXYyiUB
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

----

## Vault CLI 4/5

```text
vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_ce014447    per-token private secret storage
identity/     identity     identity_dab74cb7     identity store
secret/       kv           kv_cbcf9046           key/value secret storage
sys/          system       system_b6408332       system endpoints used for control, policy and debugging
```

----

## Vault CLI 5/5

```shell
vault kv get secret/my_secret
==== Secret Path ====
secret/data/my_secret

======= Metadata =======
Key                Value
---                -----
created_time       2023-12-07T09:03:27.87442Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
password    mypassword
username    myusername
```

---

## Vault UI 1/3

Nice, but not all features are available.

----

## Vault UI 2/3

![The Vault UI dashboard](https://raw.githubusercontent.com/adfinis/success-packages/master/images/vault-ui-dashboard.png)

----

## Vault UI 3/3

![The Vault UI exposing a KV](https://raw.githubusercontent.com/adfinis/success-packages/master/images/vault-ui-kv.png)

---

## Vault API

Well [documented](https://developer.hashicorp.com/vault/api-docs), and feature complete.

----

## Vault API

---

## Questions

---

## Thanks
