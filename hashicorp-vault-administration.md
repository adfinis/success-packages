---
title: Vault administration
theme: night
css: reveal-md/css/custom-night.css
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
  - UI
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

#### 1/4 Token types - service and batch tokens

Two main types of Vault tokens: 

| Token type | Example     |
|:----------:|:-----------:|
| Service    | hv**s**.xxx |
| Batch      | hv**b**.xxx |

----

#### 2/4 Token types - recovery token

- Then there's also a special **recovery** token
- It's only used in case a recovery scenario if needed
- Look into this [tutorial](https://developer.hashicorp.com/vault/docs/concepts/recovery-mode) if you want to learn more

----

#### 3/4 Token types - token comparison

- **Service token**:
  - heavyweight; multiple storage writes per token creation
  - persisted; can be **renewed**, **revoked**, and create **children**

- **Batch tokens**:
  - lightweight; no storage cost for token creation
  - binary large objects (blobs); **NOT** persisted (ephemeral)

----

#### 4/4 Token types - Vault CLI

Run `vault token --help` to display:

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

  Please see the individual subcommand help for detailed usage information.

Subcommands:
    capabilities    Print capabilities of a token on a path
    create          Create a new token
    lookup          Display information about a token
    renew           Renew a token lease
    revoke          Revoke a token and its children
```

---

## Vault lab with docker-compose

Let's start a lab that we will use throughout the training!

(make sure docker(-compose) is installed and the daemon is started)

First terminal tab:
```sh
cd assets/vault-docker-compose
docker-compose up
```

Second terminal tab:
```sh
export VAULT_ADDR=http://127.0.0.1:8200

vault status # to confirm it worked

Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.16.2
Build Date      2024-04-22T16:25:54Z
Storage Type    inmem
Cluster Name    vault-cluster-9508bdb6
Cluster ID      54f061c0-58c5-b5dc-6b56-e03c0e4f8771
HA Enabled      false
```

---

## Vault lab with docker-compose

There are 4 different compose files available, depending on your preference!

Decide whether to keep or throw away the Vault state

| File name                            | Goal                                    |
|--------------------------------------|-----------------------------------------|
| docker-compose.yml                   | Community Vault running in dev mode     |
| docker-compose-server.yml            | Community Vault running in server mode  |
| docker-compose-enterprise.yml        | Enterprise Vault running in dev mode    |
| docker-compose-enterprise-server.yml | Enterprise Vault running in server mode |

Run the alternative docker-compose files by using the `-f` flag, for example:

`docker compose -f docker-compose-server.yml up`

---

## Token leases

Vault token leases and expiration

Dive deeper ↓

----

### 1/7 Token leases - service token lifecycle

> Every **non-root** token has a *time-to-live* (TTL)

- Leases created by **service tokens** are *tracked*, and *revoked* when the token expires
- When creating a new token, the logged in token becomes the **parent token**
- Once the **parent token** expires, all **child tokens** also expire (regardless of their own TTLs)

```shell
hvs.b519c6aa... (1h)
|___ hvs.6a2cf3e7... (4h)
|___ hvs.1d3fd4b2... (2h)
      |___ hvs.794b6f2f... (3h)
```

----

#### 2/7 Token leases - inspect leases in the UI

Terminal tab:
```sh
vault login
<fill 'manual-root-token'>
vault token create
```

Web tab:
- Go to Access -> Leases -> Auth -> Token -> Create
- Or visit this [link](http://127.0.0.1:8200/ui/vault/access/leases/list/auth/token/create/)

----

#### 3/7 Token leases - renewing service tokens

Service tokens can be renewed:
```sh
vault token create -policy="default" # service tokens are created by default

Key                  Value
---                  -----
token                hvs.CAESIJR3kLvorH_RGRwaQt-Axb59BqBfXgw1KNHvppliY6d1Gh4KHGh2cy5wRTdyUDl2a3l
CZlVtZGtCNzNLU3h3WUg < service token starts with 'hvs.'
token_accessor       C0wOfKMTBseE9KOPuSwyEafW
token_duration       768h
token_renewable      true             < service token is renewable
token_policies       ["default"]
identity_policies    []
policies             ["default"]
```
----

#### 4/7 Token leases - batch token limitations

While batch tokens cannot be renewed:
```sh
vault token create -policy="default" -type="batch" # we are creating a batch token this time

Key                  Value
---                  -----
token                hvb.AAAAAQLv7-osWSc4eJ46P0wykdTKfj3lW8IBeBhX2vnKAHwQ7IhFWRayIIRRXZcnHXHNPZsdbNn91XdghJhidb
S0NgLVT3fXeqnx3hPL1ByWWhlvRBXixuxwVFyDDyKqyBfjaFHV50jo2CntQbipKvgxkyWUVh2YqYLv < batch token starts with 'hvb.'
token_accessor       n/a
token_duration       768h
token_renewable      false            < batch token is NOT renewable
token_policies       ["default"]
identity_policies    []
policies             ["default"]
```

----

#### 5/7 Token leases - batch token limitations

Renewing batch tokens is not possible!
```sh
$ vault token renew <batch-token>

Error renewing token: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/auth/token/renew
Code: 400. Errors:

* batch tokens cannot be renewed
```

Revoking batch tokens is not possible!
```sh
$ vault token revoke <batch-token>

Error revoking token: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/auth/token/revoke
Code: 400. Errors:

* batch tokens cannot be revoked
```

----

#### 6/7 Token leases - orphan tokens

- Create orphan tokens if the token hierarchy is not desirable
- Orphan tokens are not children of their parent (thus do not expire if parent expires) 
- But still expire when their own max TTL is reached
- Root or sudo users have the ability to generate orphan tokens

```json
path "auth/token/create-orphan" {
  capabilities = [ "create", "read", "update", "delete", "sudo" ]
}
```

----

#### 7/7 Token leases - orphan tokens

```sh
vault token create -policy="default" -orphan # create the token
vault token lookup hvs.CAESIPinkhdj8YEESf... # lookup the token values

Key                 Value
---                 -----
accessor            K7ztauQNHP9Xi5ruuz8f5z8R
creation_time       1716546740
creation_ttl        768h
display_name        token
entity_id           n/a
expire_time         2024-06-25T10:32:20.005349467Z
explicit_max_ttl    0s
id                  hvs.CAESIPinkhdj8YEESf...
issue_time          2024-05-24T10:32:20.005356217Z
meta                <nil>
num_uses            0
orphan              true                    < orphan = true
path                auth/token/create
policies            [default]
renewable           true
ttl                 767h59m21s
type                service
```

---

## Policies

- Next topic covers **policies**
- **Tokens** are mapped to **policies**
- Policies describe **permissions** attached to a Vault token

```sh
vault token create -policy="default" < attached default policy to token
```

---

### Writing policies

Vault policies and how to write them

Dive deeper ↓

----

#### 1/8 Writing policies - policy syntax

> Policies are deny by default (no policy = no authorization)

- Everything in Vault is **path** based (**path** corresponds to Vault **API endpoints**)
- Policies in Vault are written in HCL or JSON [syntax](https://developer.hashicorp.com/vault/docs/concepts/policies#policy-syntax)

```hcl
path "<PATH>" { # unique path
  capabilities = ["<PERMISSIONS>"] # list of permissions
}
```

----

#### 2/8 Writing policies - policy syntax

- Policies **grant** or **forbid** access to certain paths and operations
- Policies may include all or some of the following ([capabilities](https://developer.hashicorp.com/vault/docs/concepts/policies#capabilities)):

```hcl
path "<PATH>" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo", "deny"]
}
```

----

#### 3/8 Writing policies - capabilities

These are the policy [capabilities](https://developer.hashicorp.com/vault/docs/concepts/policies#capabilities):

| Capability | Description                                                        |
|------------|--------------------------------------------------------------------|
| create     | Allows **creating** data at the given path                         |
| read       | Allows **reading** the data at the given path                      |
| update     | Allows **changing** the data at the given path                     |
| delete     | Allows **deleting** the data at the given path                     |
| list       | Allows **listing** values at the given path                        |
| patch      | Allows partial **updates** to the data at a given path (versioned) |
| sudo       | Allows access to paths that are **root-protected**                 |
| deny       | **Disallows** access (takes precedence over everything else)       |

List of root protected [endpoints](https://developer.hashicorp.com/vault/docs/concepts/policies#root-protected-api-endpoints)

----

#### 4/8 Writing policies - HTTP verbs

These are the equivalent HTTP verbs to use when creating API requests:

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

```sh
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{"data":{"foo":"bar"}}' \
     http://127.0.0.1:8200/v1/secret/data/my-secret
```

----

#### 5/8 Writing policies - root policy

- Root policy is always included – superuser with all permissions
- Root policy is not visible in the Vault backend (open [policies](http://127.0.0.1:8200/ui/vault/policies/acl))
- Root policy can be thought of as:

```hcl
path "*" { # allow all paths (not valid HCL)
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"] # allow all capabilities
}
```

----

#### 6/8 Writing policies - root token

- Authenticating with root token should be limited
- Only use the root token to:
  - Setup initial policies and configurations
  - Handle emergencies where root privilege is needed

----

#### 7/8 Writing policies - default policy

- The default policy is always included after installation
- Contains common permissions around token and backend features
- Take a moment to study the contents of the default [policy](http://127.0.0.1:8200/ui/vault/policy/acl/default)

----

#### 8/8 Writing policies - reading policy and token capabilities

> vault token capabilities [flags] [token] [path]

```sh
vault token capabilities hvs.CAESIPinkhdj8YEEzmOP4kxfSfJBZjl1--bbfvPVjB98SU6CGh4KHGh2cy5jcVZ6T01zQmx
root
```

> vault policy read [policy]

```
(command output)
path "auth/token/lookup-self" {
    capabilities = ["read"]
}
(etc)
```

---

### Templating policies

Vault policy templating techniques

Dive deeper ↓

----

#### 1/3 Templating policies - techniques

- Policies can be templated using:
  - Wildcard (`*`)
  - Single directory (`+`)

----

#### 2/3 Templating policies - wildcard

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

#### 3/3 Templating policies - single directory

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

#### 1/5 Auth engines

- Auth engines (or called [auth methods](https://developer.hashicorp.com/vault/docs/auth) nowadays) authenticate users and applications
- Many different auth engines exist
- We will cover the most common auth engines

----

#### 2/5 Auth engines - token

- The [token](https://developer.hashicorp.com/vault/docs/auth/token) auth method is the most basic engine
- Built-in, automatically available by default at `/auth/token`
- Allows users to:
  - authenticate using a token
  - create new tokens
  - revoke secrets by token
  - and more

----

#### 3/5 Auth engines - userpass

- Next up, the [userpass](https://developer.hashicorp.com/vault/docs/auth/userpass) auth engine
- Simply allows you to use standard username/password combinations in Vault
- Usually used as an emergency backup auth method (in case dynamic auth engine fails)

----

#### 4/5 Auth engines - cloud auth methods

- Use your pre-existing users in cloud platforms to authenticate:
  - [AWS IAM](https://developer.hashicorp.com/vault/docs/auth/aws)
  - [Azure AD](https://developer.hashicorp.com/vault/docs/auth/azure)
  - [Gcloud IAM](https://developer.hashicorp.com/vault/docs/auth/gcp)
  - [OCI Identity](https://developer.hashicorp.com/vault/docs/auth/oci)

----

#### 5/5 Auth engines - common protocols

- Or use common protocols:
  - [LDAP](https://developer.hashicorp.com/vault/docs/auth/ldap)
  - [JWT/OIDC](https://developer.hashicorp.com/vault/docs/auth/jwt)
  - [SAML (enterprise feature)](https://developer.hashicorp.com/vault/docs/auth/saml)

---

### Secret engines

Vault secret engines

Dive deeper ↓

----

#### 1/4 What are secret engines

- Components responsible for managing *secrets*
- Distinguish between **static** and **dynamic** secrets engines
  - **Static** secrets engines simply *store* and *read* data
  - **Dynamic** secrets engines allows rotating credentials over time (through other services)
- Specific features
  - TOTP generation
  - Encryption as a service (EaaS)
  - Certificate generation

----

#### 2/4 Secret engines - KV Engine (static)

- Stores static data by using a key-value store
- Think about username password combinations or API keys
- Access control configured through policies
- Access is fully audited through the audit log
- Two versions: key/value v2 (`kv-v2`) secrets engine is versioned, whereas v1 (`kv`) is not

----

#### 3/4 Secret engines - Database (dynamic)

- [Database](https://developer.hashicorp.com/vault/docs/secrets/databases) secrets engines generate database credentials dynamically (over time)
- More automated rotation of credentials in the case of large environments

----

#### 4/4 Secret engines - Cloud credentials (dynamic)

- Dynamically create access credentials based on policies
- Think about [AWS](https://developer.hashicorp.com/vault/docs/secrets/aws), [Azure](https://developer.hashicorp.com/vault/docs/secrets/azure) or [Google Cloud](https://developer.hashicorp.com/vault/docs/secrets/gcp)

---

## Configuration

- You can configure Vault using different approaches
- [UI](https://developer.hashicorp.com/vault/tutorials/getting-started-ui) / [API](https://developer.hashicorp.com/vault/api-docs) / [CLI](https://developer.hashicorp.com/vault/docs/commands) / [Terraform](https://registry.terraform.io/providers/hashicorp/vault) / [Python](https://hvac.readthedocs.io/)
- We will cover the CLI and Terraform approach

---

### UI

How to configure Vault using the UI

Dive deeper ↓

----

#### UI 1/4 - configure KV secrets engine

![Vault enable KV engine](https://raw.githubusercontent.com/adfinis/success-packages/improvements/assets/images/Vault-enable-kv-engine.png)

----

#### UI 2/4 - create kv engine secret

![Vault enable KV engine](https://raw.githubusercontent.com/adfinis/success-packages/improvements/assets/images/Vault-create-secret.png)

----

#### UI 3/4 - kv engine version history

![Vault enable KV engine](https://raw.githubusercontent.com/adfinis/success-packages/improvements/assets/images/Vault-kv-version-history.png)

----

#### UI 4/4 - Vault UI workshop

- Start the Vault environment using `docker-compose` again
- Login to Vault using `manual-root-token`
- Enable the kv v2 secrets engine from within the UI
- Tune the configuration values

---

### CLI

How to configure Vault using the CLI

Dive deeper ↓

----

#### 1/5 CLI - secrets engine

- Secrets engines must be enabled at a **path** so that the request can be routed
  - Each secrets engine defines its own **paths** and **properties**

----

#### 2/5 CLI - secrets engine subcommands

> vault secrets -h

```yaml
Usage: vault secrets <subcommand> [options] [args]

  This command groups subcommands for interacting with Vault's secrets engines.
  Each secret engine behaves differently. Please see the documentation for
  more information.

  List all enabled secrets engines:

      $ vault secrets list

  Enable a new secrets engine:

      $ vault secrets enable database

  Please see the individual subcommand help for detailed usage information.

Subcommands:
    disable    Disable a secret engine
    enable     Enable a secrets engine
    list       List enabled secrets engines
    move       Move a secrets engine to a new path
    tune       Tune a secrets engine configuration
```

----

#### 3/5 CLI - secrets engine tuning

> vault secrets tune -h

```yaml
Usage: vault secrets tune [options] PATH

  Tunes the configuration options for the secrets engine at the given PATH.
  The argument corresponds to the PATH where the secrets engine is enabled,
  not the TYPE!

  Tune the default lease for the PKI secrets engine:

      $ vault secrets tune -default-lease-ttl=72h pki/
```

----

#### 4/5 CLI - secrets engine workshop question

- Enable the kv secrets engine (v2) with the `random` path
- Tune (configure) the secrets engine with a `random description`

----

#### 5/5 CLI - secrets engine workshop answer

- `vault secrets enable -path=random -version=2 kv`
- `vault secrets tune -description='random description' random`

---

### Terraform

How to configure Vault using Terraform

Dive deeper ↓

----

#### 1/10 Terraform - benefits

- The usual IaC benefits are also applicable here
- Ensure consistency and repeatability in configuration changes
- Version control for transparency and accountability (enabling tracking and auditing)
- Keep all environments consistent (dev and prod)
- Ability to undo all changes (`terraform destroy`)

----

#### 2/10 Terraform - how to

- In most cases, configure Vault using the Terraform [provider](https://registry.terraform.io/providers/hashicorp/vault/latest)
- You can use Terraform [resources](https://developer.hashicorp.com/terraform/language/resources) as shown in the Vault provider [docs](https://registry.terraform.io/providers/hashicorp/vault/latest/docs) to apply configuration

----

#### 3/10 Terraform - practical tips

- Configure the environment, not the actual static or dynamic secrets within Vault
- In most cases you don't populate any actual secrets using Terraform

----

#### 4/10 Terraform - workshop - run server Vault

First tab:
- `cd assets/vault-docker-compose`
- `docker-compose -f docker-compose-server.yml up`

Second tab:
- `export VAULT_ADDR="http://127.0.0.1:8200"`
- `vault operator init -key-shares=1 -key-threshold=1`
- `vault operator unseal`

----

#### 5/10 Terraform - workshop - terraform

Second tab:
- `cd ../vault-terraform`
- `tree`
- `export VAULT_TOKEN=<fill-root-token-from-vault-operator-init>`
- `export VAULT_ADDR="http://127.0.0.1:8200"`
- `terraform init`
- `terraform apply`

----

#### 6/10 Terraform - workshop

- Inspect all code and comments in the `assets/vault-terraform` directory
- Navigate and inspect the following inside of the Vault UI: 
  - the `admins` policy
  - the `userpass` auth method
  - the `student` user within the `userpass` auth method
  - the `kv-v2` secrets engine

----

#### 7/10 Terraform - workshop

- Identify the terraform resource `vault_audit` in the Vault [provider](https://registry.terraform.io/providers/hashicorp/vault/latest)
- Configure the audit log by using the `vault_audit` resource and path `/vault/logs/audit.log` (place the Terraform code in `assets/vault-terraform/audit.tf`)
- Enable your changes:
  - `terraform plan`
  - `terraform apply`

----

#### 8/10 Terraform - workshop

File code:
```
resource "vault_audit" "file" {
  type = "file"
  options = {
    file_path = "/vault/logs/audit.log"
  }
}
```

----

#### 9/10 Terraform - workshop - inspect audit log

- Open: `assets/vault-docker-compose/docker/vault/logs/audit.log`
- Refer to this [guide](https://support.hashicorp.com/hc/en-us/articles/360000995548-Audit-and-Operational-Log-Details) for an explanation on all the fields reported within the audit logs

----

#### 9/10 Terraform - workshop - cleanup

- To destroy the Terraform configuration:
  - `terraform destroy`
- To remove the Vault server data:
  - `cd success-packages/asssets/vault-docker-compose`
  - `rm -R docker/vault/data/*`
- To unset the environment variables from your terminal:
  - `unset VAULT_TOKEN VAULT_ADDR`

---

## Questions

Feel free to ask questions!

---

## Thanks

Thank you for your participation
