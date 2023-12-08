# Ansible

A short demo how Ansible can consume HashiCorp Vault Secrets.

## Setup

Download Ansible dependencies.

```shell
pip install -r requirements.yml
```

Download Python dependencies.

```shell
ansible-galaxy install -r requirements.yml
```

Start Vault.

```shell
vault server -dev
```

Paste the Vault root token into `playbook.yml`

## Running

```shell
./playbook.yml
```
