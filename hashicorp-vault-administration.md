---
title: Vault administration
theme: night
css: assets/reveal-md/css/night.css
---

# Vault Administration

---

A guide that goes deeper into

HashiCorp Vault Administration

---

## Topics 1/2

- Tokens
  - Token types
  - Token leases
- Policies
  - Writing policies
  - Templating policies

---

## Topics 2/2

- Engines
  - Auth engines
  - Secrets engines
- Configuration
  - CLI
  - Terraform

---

## Tokens 

Tokens are the core method for **authentication** of clients within Vault

> Nearly all requests to Vault must be accompanied by a token

Tokens are authenticated by an **auth method**

---

### Token types

Vault token types

Dive deeper ↓

----

#### 1/5 Token types - service and batch tokens

Two main types of Vault tokens: 

| Token type | Example     |
|:----------:|:-----------:|
| Service    | hv**s**.xxx |
| Batch      | hv**b**.xxx |

----

#### 2/5 Token types - recovery token

- Then there's also a special **recovery** token
- It's only used in case a recovery scenario it needed
- Look into [tutorial](https://developer.hashicorp.com/vault/docs/concepts/recovery-mode) if you want to learn more

----

#### 3/5 Token types - service tokens

- **Service token**: persisted, can be renewed, revoked, and create children
- **Batch tokens**: binary large objects (blobs), **NOT** persisted (ephemeral)

----

#### 4/5 Token types - performance cost

- **Service tokens**: heavyweight; multiple storage writes per token creation
- **Batch tokens**: lightweight; no storage cost for token creation

----

#### 5/5 Token types - Vault CLI

Experiment:
- `cd assets/

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

## Token leases

Vault token leases and expiration

Dive deeper ↓

----

### 1/5 Token leases - service tokens

- Leases created by service tokens are tracked 
- And revoked when the token expires

----

#### 2/5 Token leases - service token lifecycle

- Every non-root token has a time-to-live (TTL).
- When a token expires, Vault automatically revokes it.

----

#### 3/5 Token leases - service token lifecycle

- If you create a new token, the token you used to create the token becomes the parent token. 
- Once the parent token expires, so do all its children regardless of their own TTLs.

----

#### 4/5 Token leases - service token lifecycle

```shell
    hvs.b519c6aa... (1h)
    |___ hvs.6a2cf3e7... (4h)
    |___ hvs.1d3fd4b2... (2h)
          |___ hvs.794b6f2f... (3h)
```

- All tokens have a time-to-live (TTL)
- When the top level token expires, all child tokens are revoked

----

#### 5/5 Token leases - batch token lifecycle


---

## Policies

- Next topic covers **policies**
- **Tokens** are mapped to **policies**
- Policies describe **permissions** attached to a Vault token

---

### Writing policies

Vault policies and how to write them

Dive deeper ↓

----

#### 1/ Writing policies

- Everything in Vault is path based (path corresponds to Vault API endpoints)
- Policies **grant** or **forbid** access to certain paths and operations

```hcl
path "<PATH>" {
  capabilities = [ "<LIST_OF_PERMISSIONS>" ]
}
```

----

#### 2/ Writing policies

- Policies include the following permissions:

```hcl
path "<PATH>" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```

----

#### 3/ Writing policies

These are the policy [capabilities](https://developer.hashicorp.com/vault/docs/concepts/policies#capabilities):

| Capability | Description                                                  |
|------------|--------------------------------------------------------------|
| create     | Allows **creating** data at the given path                   |
| read       | Allows **reading** the data at the given path                |
| update     | Allows **changing** the data at the given path               |
| delete     | Allows **deleting** the data at the given path               |
| list       | Allows **listing** values at the given path                  |
| patch      | Allows partial **updates** to the data at a given path       |
| sudo       | Allows access to paths that are **root-protected**           |
| deny       | **Disallows** access (takes precedence over everything else) |

----

#### 4/ Writing policies

These are the equivalent HTTP verbs to use when creating API requests

| Capability | HTTP equivalent |
|:----------:|:---------------:|
| create     | POST/PUT        |
| read       | GET             |
| update     | POST/PUT        |
| delete     | DELETE          |
| list       | LIST            |
| patch      | PATCH           |
| sudo       | -               |
| deny       | -               |

----

#### 5/ Writing policies - root policy

- Root policy is always included – superuser with all permissions
- The root policy is not visible in the Vault backend
- It can be thought of as (not valid HCL):

```hcl
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```

----

#### 6/ Writing policies - root policy

- Only use the root token to:
  - Setup initial policies and configurations
  - Handle emergencies where root privilege is needed

----

#### 7/ Writing policies - default policy

- The default policy is always included
- Contains common permissions around token and backend features
- Take a moment to study the contents of the default [policy](http://127.0.0.1:8200/ui/vault/policy/acl/default)

---

### Templating policies

Vault policy templating techniques

Dive deeper ↓

----

#### 1/ Templating policies - techniques

- Policies can be templated using:
  - Wildcard (`*`)
  - Single directory (`+`)

----

#### 2/ Templating policies - wildcard

ACL policy path supports wildcard (`*`) at the end of the path

```hcl
path "secret/team-*" { 
  capabilities = ["read", "list"]
}
```

Matches any path starting with `"secret/team-"`:
- `secret/team-security`
- `secret/team-a/project`

----

#### 3/ Templating policies - single directory

Supports wildcard matching for a single directory in path

```hcl
path "secret/app/+/dev" { ... } < matches 'secret/app/v1/dev'
```

You can also combine both plus symbol `+` and wildcard `*`

```hcl
path "secret/app/+/team-*" { ... } < matches 'secret/app/v1/team-a'
```

---

## Vault engines

- You can configure Vault using:
  - Auth engines
  - Secrets engines

---

### Auth engines

Vault auth engines

Dive deeper ↓

----

#### 1/ Auth engines

- Auth engines authenticate users and applications
- Many different auth engines exist
- We will cover the most common auth engines

----

#### 2/ Auth engines - token

- The [token](https://developer.hashicorp.com/vault/docs/auth/token) auth method is the most basic engine
- Automatically available by default at `/auth/token`
- Allows users to:
  - authenticate using a token
  - create new tokens
  - revoke secrets by token
  - and more

----

#### 3/ Auth engines - userpass

- Next up, the [userpass](https://developer.hashicorp.com/vault/docs/auth/userpass) auth engine
- Simply allows you to use standard users (with passwords) in Vault
- Usually used as an emergency backup auth method (in case dynamic auth engine fails)

----

#### 4/ Auth engines - cloud auth methods

- Use your pre-existing users in cloud platforms to authenticate:
  - [AWS IAM](https://developer.hashicorp.com/vault/docs/auth/aws)
  - [Azure AD](https://developer.hashicorp.com/vault/docs/auth/azure)
  - [Gcloud IAM](https://developer.hashicorp.com/vault/docs/auth/gcp)
  - [OCI Identity](https://developer.hashicorp.com/vault/docs/auth/oci)

----

#### 5/ Auth engines - common protocols

- Or use common protocols:
  - [LDAP](https://developer.hashicorp.com/vault/docs/auth/ldap)
  - [JWT/OIDC](https://developer.hashicorp.com/vault/docs/auth/jwt)
  - [SAML (enterprise feature)](https://developer.hashicorp.com/vault/docs/auth/saml)

---

### Secret engines

Vault secret engines

Dive deeper ↓

----

#### 1/ Secret engines (static)

- Stores static data by using a key-value store
- Think about username password combinations or API keys
- Access control through policies

----

#### 2/ Secret engines (dynamic)

- Dynamic secret engines in Vault allow rotating of credentials over time
- Database credentials and cloud provider access keys

---

## Configuration

- You can configure Vault using different approaches
- [UI](https://developer.hashicorp.com/vault/tutorials/getting-started-ui) / [API](https://developer.hashicorp.com/vault/api-docs) / [CLI](https://developer.hashicorp.com/vault/docs/commands) / [Terraform](https://registry.terraform.io/providers/hashicorp/vault) / [Python](https://hvac.readthedocs.io/)
- We will cover the CLI and Terraform approach

---

### CLI configuration

How to configure Vault using the CLI

Dive deeper ↓

----

#### 1/ CLI configuration

----

#### 2/ CLI configuration

---

### Terraform configuration

How to configure Vault using Terraform

Dive deeper ↓

----

#### 1/ Terraform configuration

----

#### 2/ Terraform configuration

---

## Questions

---

## Thanks
