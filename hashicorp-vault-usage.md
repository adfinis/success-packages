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

----

## Quick instruction

```shell
> vault server -dev
> export VAULT_ADDR="http://127.0.0.1:8200"
```

----

## Login to Vault

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

---

## Ways to use Vault

- UI.
- CLI.
- API.

> In the end, it's all API.

----

## What we're doing

For each method (UI, CLI, API) we will:

1. Create a secret.
2. Read the secret.

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

## Vault CLI 1/3

Mostly used for administration, experimenting and debugging.

----

## Vault CLI 2/3

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

## Vault CLI 3/3

```shell
> vault kv get secret/my_secret
====== Data ======
Key         Value
---         -----
password    mypassword
username    myusername
```

- YAML: `vault kv get --field=data --format=yaml secret/my_secret`

---

## Vault API 1/4

Well [documented](https://developer.hashicorp.com/vault/api-docs), and feature complete.

----

## Vault API 2/4

```shell
curl \
    -H "X-Vault-Token: hvs.OVWwDAoEvtdYh8Qe0nvFuOPE" \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"data":{"username":"myusername", "password":"mypassword"}}' \
    http://127.0.0.1:8200/v1/secret/data/my_secret
```

----

## Vault API 3/4

```shell
curl \
    -H "X-Vault-Token: hvs.OVWwDAoEvtdYh8Qe0nvFuOPE" \
    -X GET \
    http://127.0.0.1:8200/v1/secret/data/my_secret 
```

----

## Vault API 4/4

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

The agent can be used to:

1. Authenticate to Vault.
2. Retrieve secrets from Vault.
3. Write secrets to disk.

> Updates to a secret will be automatically written to disk.

---

## Vault SDK

There are [libraries](https://developer.hashicorp.com/vault/api-docs/libraries) for many languages.

----

## Vault SDK - Ansible

```yaml
    - name: Show username
      ansible.builtin.debug:
        msg: "username: {{ lookup('community.hashi_vault.hashi_vault', 'secret=secret/data/my_secret:username') }}"
      environment:
        ANSIBLE_HASHI_VAULT_ADDR: "{{ vault_addr }}"
        ANSIBLE_HASHI_VAULT_TOKEN: "{{ vault_token }}"
```

> See [demo](ansible)

---

## Questions

---

## Thanks
