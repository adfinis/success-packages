---
title: Vault operations

---

# Vault operations

---

This presentation guides you through the Vault operations you may need to do to properly setup Vault.

---

## Introduction

- Who am I?
- Who/what is Adfinis?
- Who are you?

---

## Topics 1/2

- Installing
- Updating
- Clustering (HA)
- Scaling
- Initializing
- Unsealing

----

## Topics 2/2

- Disaster Recovery
- Performance Replication
- Architecture
- Monitoring
- Logging
- Backup and restore
- Others

---

## Installing 1/4

Vault is a single binary in a couple of version.

- Open Source
- Enterprise
- Enterprise + HSM
- Enterprise FIPS
- Enterprise FIPS + HSM

----

## Installing 2/4

There are binaries available for many platforms:

- Darwin
- FreeBSD
- Linux
- NetBSD
- OpenBSD
- Solaris
- Windows

Supported architectures: `arm`, `arm64`, `386` and `amd64` .

----

## Installing 3/4

When using a binary, there are a few things that need to be created in a system:

- Create directories
- Create a configuration
- Create a group
- Create a user
- Create a startup method (SystemV or systemd)

----

## Installing 4/4

Rather than manually using the binary, a package can also be installed:

- Debian-like: https://apt.releases.hashicorp.com
- RedHat-like: https://rpm.releases.hashicorp.com

More [detail](https://www.hashicorp.com/blog/announcing-the-hashicorp-linux-repository).

---

## Updating 1/4

Every 2 weeks a new version is [released](https://releases.hashicorp.com/vault/).

Some updates contain security fixes and may require a quick installation.

----

## Updating 2/3

Simply replace the binary or package. To prevent unnecessary outages, use this order:

1. Followers of replication secondary/secondaries.
2. Leader of the replication secondary/secondaries.
3. Followers of the replication primary/primaries.
4. Leader of the replication primary/primaries.

NOTE: You can technically update in any order, but may experience minor outages when a new leader is elected.

----

## Updating 3/3

As updating is required somewhat frequently, is specific and critical; automating this using for example Ansible will prove valuable.

NOTE: Please have a non-production environment prepared to exercise the update.

---

## Clustering (HA) 1/6

You can create a cluster of Vault instances, which can offer redundancy.

NOTE: Vault write actions will always be handled by the leader, to performance is not typically improved by more than one machine.

----

## Clustering (HA) 2/6

You can manually create a cluster:

```shell
vault operator raft join http://127.0.0.2:8200
```

NOTE: Automatic joining is preferred to reduce administrative burden.

----

## Clustering (HA) 3/6

Interesting to know:

1. When a Vault instance joins a cluster, a "bootstrap" sequence is started. This happens on port `:tcp/8200` (by default)
2. Cluster communication will happen on port `:tcp:8201` (by default).

----

## Clustering (HA) 4/6

3. Both ports should be available to all members of a cluster.
4. Port `:tcp/8200` uses `HTTPS`. The nodes should trust each others certificates. This is typically done by having a single certificate for all nodes, having either a wildcard (`*.examples.com`) or a specific Subject Alternate Name ("SAN"). For "SAN", node names need to be known.

----

## Clustering (HA) 5/6

Automatic joining is preferred over manual joining. It allows instance replacements to occur without human intervention.

```hcl
  storage "raft" {
  path    = "/vault/vault"
  node_id = "vault_UNIQUE_ID"
  retry_join {
    auto_join = "provider=aws addr_type=public_v4 tag_key=auto_join tag_value=my_raft_instances region=us-east-1"
    auto_join_scheme = "https"
  }
}
```

----

## Clustering (HA) 6/6

Automatically joining uses [`go discovery`](https://github.com/hashicorp/go-discover), which has many "providers", including:

- AWS
- Azure
- vSphere

NOTE: "auto join" and "auto unseal" are often confused. They are different concepts.

---

## Scaling 1/2

Vault can be scaled. This is done for availability, not for performance.

A Vault cluster needs an odd number of instances, either `3` and `5`. (`5` is recommended, but `3` can be used when no more than `3` "zones" or "lanes" are available.)

You can scale both up and down, from `3` to `5` and back from `5` to `3`.

NOTE: Scaling down required auto-pilot to be configured to cleanup ["dead servers"](https://developer.hashicorp.com/vault/docs/concepts/integrated-storage/autopilot#dead-server-cleanup). If this configuration is skipped, quorum may be lost.

----

## Scaling 2/2

HashiCorp advices this [sizing](https://developer.hashicorp.com/vault/tutorials/day-one-raft/raft-reference-architecture#hardware-sizing-for-vault-servers) for individual Vault nodes:

| Size  | CPU | Memory (GB) | Disk (GB) Disk IO (IOPS) | Disk thoughput (MB/s) |
| ----- | --- | ----------- | ------------------------ | --------------------- |
| small | 2-4 | 8-16        | 100+                     | 75+                   |
| large | 4-8 | 32-64       | 200+                     | 250+                  |

What `small` and `large` are, is not very explicit.

NOTE: Smaller instances can certainly work, but if a Vault instance runs out of memory, the Vault cluster may become unstable. This situation can be difficult to fix.

---

## Initializing 1/2

Any Vault node or cluster needs to be initialized. Initializing created an encrypted storage backend and returns the "unseal keys" or "recovery keys" and root-token. (for automatically unsealed instances) **ONCE**.

Unseal/recovery keys can be PGP can be used to prevent plain-text (shared) keys to be displayed.

It's advised to carefully run this procedure.

----

## Initializing 2/2

The "root-token" or "root-key" is the initial key that allows all actions on Vault.

This token should be revoked as early as possible, after personal users have "high privileged" access to Vault.

NOTE: Most Vault installations have the root-token **NOT** revoked, which is a security issue.

---

## Unsealing 1/6

Every time Vault starts, it needs to be unseal. These are typical situations when unsealing is required:

- Reboot
- Restart
- Crash and start
- Stop, update, start

----

## Unsealing 2/6

Manual unsealing requires unsealing as many times as the amount of `key-threshold` set when initializing Vault. The default value for `key-threshold` is `3` out of the `5` `key-shares`.

This means at least 3 people need to enter an unseal key on **each Vault instance**. A typical installation of Vault has  10 to 20 nodes. That would mean 30 to 60 unseal commands.

Manual unsealing is not preferred.

---

## Unsealing 3/6

You can automatically unseal Vault in multiple ways.

- AWS KMS
- Azure Key Vault
- GCP Cloud KMS
- HSM
- Transit

----

## Unsealing 4/6

AWS KMS, Azure Key Vault and GCP Cloud KMS use a key on a cloud provider to unseal. Access to such a key becomes critical for availability and sensitive.

NOTE: You can unseal a non-cloud Vault instance using cloud keys.

----

## Unsealing 5/6

An HSM can be used to unseal Vault. This does introduce a dependency on an HSM, but greatly reduces the administrative work required for unsealing.

----

## Unsealing 6/6

`Transit` can also be used to unseal Vault. This mechanism unseals Vault using another Vault. This means there is a dependency on that other Vault and the initial Vault needs to be unsealed as well, likely manual.

---

## Disaster Recovery 1/3

Vault clusters (or instances) can be related in a "disaster recovery" replication setup.

----

## Disaster Recovery 2/3

- Synchronizes all data.
- Has a primary and secondary.
- Secondary can be promoted.
- Secondary does not provide service until promoted.
- Is an Enterprise feature.

----

## Disaster Recovery 3/3

The size of a "cluster" (`1`, `3` or `5`) has no impact on DR, you can mix any size.

Disaster Recovery can also be used to migrate from one cluster to another.

---

## Performance Replication 1/2

Vault clusters can synchronize (selected) data in a "performance replication" setup.

Performance Replication:

- Synchronizes selected data.
- Has a primary and secondary
- Secondary can be promoted.
- Secondary does provide service.
- Is an Enterprise feature.

----

## Performance Replication 2/2

Disaster Recovery and Performance Replication can be combined.

Disaster Recovery can (also) be used to migrate from one cluster to another.

---

## Architecture

Here are a few architecture examples.

----

## Architecture single node

```text
+--- Vault-1 ---+
|               |
+---------------+
```

----

## Architecture multiple nodes

```text
                +--- Load balancer ---+
                |                     |
                +---------------------+
                  /        |         \
                 /         |          \
+--- Vault-1 ---+  +--- Vault-2 ---+   +--- Vault-3 ---+
|               |  |               |   |               |
+---------------+  +---------------+   +---------------+
```

- Low latency connection.
- Different availability zones.

----

## Architecture multiple clusters DR

```text
                  +--- load balancer ---+
                  | (or dynamic DNS)    |
                  +---------------------+
                    /                   \
                   /                     \
+---- load balancer ----+          +---- load balancer ----+
|                       |          |                       |
+-----------------------+          +-----------------------+
            |                                  |
            V                                  V
+--- Vault-cluster-1 ---+          +--- Vault-cluster-2 ---+
|                       | -> DR -> |                       |
+-----------------------+          +-----------------------+
```

- Connection quite forgiving.
- Different regions.

----

## Architecture multiple clusters DR and PR

```text
+---- load balancer ----+          +---- load balancer ----+
|                       |          |                       |
+-----------------------+          +-----------------------+
            |                                  |
            V                                  V
+--- Vault-cluster-1 ---+          +--- Vault-cluster-2 ---+
|                       | -> PR -> |                       |
+-----------------------+          +-----------------------+
           |                                  |
           V                                  V
          DR                                  DR
           |                                  |
           V                                  V
+--- Vault-cluster-3 ---+          +--- Vault-cluster-4 ---+
|                       |          |                       |
+-----------------------+          +-----------------------+
           ^                                  ^
           |                                  |
+---- load balancer ----+          +---- load balancer ----+
|                       |          |                       |
+-----------------------+          +-----------------------+
```

----

## Architecture resolution

A dynamic DNS record can be served, based on:

- Originating IP address(es).
- Health checks.

Dynamic DNS is typically slower than a loadbalancer to fail over.

---

## Monitoring

1. Lack of memory breaks a Vault instance, rendering the cluster unstable.
2. Service checks (availability and response time) help determine the current and future health.
3. Vault telemetry can be used to scrap metrics.

---

## Logging 1/3

Operational logs (`journalctl`) help understand the past and current state of Vault.

Audit logs can be required and help determine usage of Vault and may be required for compliance.

----

## Logging 2/3

Audit logs can be stored or sent to one or more of:

- Disk
- Syslog
- Socket

NOTE: Audit logs need rotation.

----

## Logging 3/3

If no audit devices are available, Vault stops serving requests.

---

## Backup and restore 1/3

This is your last resort and can be for forensics.

- Backup is a snapshot of the data, not configuration.
- A restore, restores **ALL** data, not per namespace or secret engine.

----

## Backup and restore 2/3

You can store to:

- Disk (`local`).
- AWS (`aws-s3`).
- Azure (`azure-blob`).
- GCP (`google-gcs`).

----

## Backup and restore 3/3

Typically configured with `interval` and `retain`:

| interval | retain |
|----------|--------|
| 1h       | 24     |
| 1d       | 7      |
| 1w       | 4      |
| 1m       | 12     |

NOTE: Vault takes care of cleaning up old backups.

---

## Others 1/2

Writing Standard Operational Procedures helps, for example:

- Recovery of single node loss.
- Recovery of quorum loss.
- Recover of "region" failure.
- Updating Vault.
- Emergency sealing.
- ...

----

## Others 2/2

- Configuring Vault (`audit`, `autopilot` and `snapshot`) using Terraform works perfectly.
- Vault is a "cloud native" tool. You can (if desired) never login to the instance.
- When using namespaces, who managed the root-namespace?
- Client counting can be enabled.
- Vault typically requires a small team to run.

---

## Questions

---

## Thanks
