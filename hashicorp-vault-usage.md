---
title: Vault usage

---

# Vault usage

---

A guide on how to use HashiCorp Vault.

---

## Introduction

- Who am I?
- Who/what is Adfinis?
- Who are you?

---

## Topics

- Vault
- UI
- CLI
- API
- Vault Agent
- Vault SDK

---

## Vault

A tool to manage *secrets*, typically for *systems*.

> Secrets: Anything sensitive; credentials, API keys, SSL keys, etc.

> Systems: An application like Tomcat, CI, k8s, etc.

----

## Join the experiment!

- [Install Vault](https://developer.hashicorp.com/vault/docs/install).
- [Start Vault](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-dev-server).

---

## Ways to use Vault

- UI.
- CLI.
- API.

> In the end, it's all API.

---

## Vault UI 1/3

Userfriendly, not all features are available.

----

## Vault UI 2/3

![The Vault UI dashboard](https://raw.githubusercontent.com/adfinis/success-packages/master/images/vault-ui-dashboard.png)

----

## Vault UI 3/3

![The Vault UI exposing a KV](https://raw.githubusercontent.com/adfinis/success-packages/master/images/vault-ui-kv.png)

---

## Vault CLI 1/6

Mostly used for administration, experimenting and debugging.

----

## Vault CLI 2/6

```shell
> vault server -dev
> export VAULT_ADDR="http://127.0.0.1:8200"
```

----

## Vault CLI 3/6

```shell
> vault login
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

## Vault CLI 4/6

```shell
> vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_ce014447    per-token private secret storage
identity/     identity     identity_dab74cb7     identity store
secret/       kv           kv_cbcf9046           key/value secret storage
sys/          system       system_b6408332       system endpoints used for control, policy and debugging
```

----

## Vault CLI 5/6

```shell
> vault kv put -mount=secret my_secret \
  username=myusername \
  password=mypassword
==== Secret Path ====
secret/data/my_secret

======= Metadata =======
Key                Value
---                -----
created_time       2023-12-07T10:06:40.850236Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1
```

----

## Vault CLI 6/6

```shell
> vault kv get secret/my_secret
====== Data ======
Key         Value
---         -----
password    mypassword
username    myusername
```

-YAML: `vault kv get --field=data --format=yaml secret/my_secret`

---

## Vault API 1/3

Well [documented](https://developer.hashicorp.com/vault/api-docs), and feature complete.

----

## Vault API 2/3

```shell
curl \
    -H "X-Vault-Token: hvs.OVWwDAoEvtdYh8Qe0nvFuOPE" \
    -X GET \
    http://127.0.0.1:8200/v1/secret/data/my_secret 
```

---

## Vaukt API 3/3

```json
{
  "request_id": "4b15ae49-1c45-1052-c106-b7d005dc2858",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": {
    "data": {
      "password": "mypassword",
      "username": "myusername"
    },
    "metadata": {
      "created_time": "2023-12-07T09:03:27.87442Z",
      "custom_metadata": null,
      "deletion_time": "",
      "destroyed": false,
      "version": 1
    }
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
```

---

## Vault agent

---

## Vault SDK

---

## Questions

---

## Thanks
