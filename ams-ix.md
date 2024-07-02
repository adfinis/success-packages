---
title: Ansible @ AMS-IX

---

# Ansible @ AMS-IX

---

## Overview

- Automate everything
- Ansible for OS variations
- GitLab CI
- Event Drive Ansible
- API for AMS-IX

---

## Automate everything

Besides "normal" use-cases (playbooks, roles & collections):

- [Document generation](https://github.com/robertdebock/ansible-generator)
- [Retry CI](https://github.com/robertdebock/ci-retry)
- [Set a secret on GitHub](file:///Users/robertdb/Documents/github.com/robertdebock/github-set-secret)
- Scripting
- Orchestration

---

## Ansible for OS variations

Ansible is great at writing simple code to solve OS variations.

For example: `httpd` is different on each OS:

- Package name
- Service name
- User & Group
- Configuration & data directory
- Modules path
- Binary name

----

## The HTTPD package name

`httpd/vars/main.yml`:

```yaml
_httpd_packages:
  default:
    - httpd
  Debian:
    - apache2

httpd_package: "{{ _httpd_packages[ansible_os_family] | default(_httpd_packages['default'] }}"

----

## Install HTTPD

`httpd/tasks/main.yml`:

```yaml
- name: Install HTTPD
  ansible.builtin.package:
    name: "{{ httpd_package }}"
```

----

## Full role

- [httpd](https://github.com/robertdebock/ansible-role-httpd)

---

## GitLab CI.

Testing, releasing and deploying can be done using GitLab (or GitHub).

----

## GitLab Testing

```yaml
---
image: "robertdebock/github-action-molecule:6.0.1"

molecule:
  script:
    - molecule test
  rules:
    - if: $CI_COMMIT_REF_NAME == "master"
  parallel:
    matrix:
      - image: "enterpriselinux"
        tag: "latest"
      - image: "debian"
        tag: "latest"
```

----

## GitLab releasing

```yaml
---
image: "robertdebock/github-action-molecule:6.0.1"

galaxy:
  script:
    - ansible-galaxy role import --api-key ${GALAXY_API_KEY} robertdebock ${CI_PROJECT_NAME}
  rules:
    - if: $CI_COMMIT_TAG != null
```

----

## GitLab deploying

Likely better using Ansible Automation Platform because:

- RBAC
- More readable output
- Execution environment
- Scheduling

> Possible with GitLab, but: build yourself.

---

## Event Driven Ansible

Event Driven Ansible (EDA) reacts to events, and calls Ansible Automation Controller to run a playbook.

```text
+--- source ---+      +--- EDA ---+      +--- AAC ---+
| - monitoring | <--- | runbooks  | ---> |           |
| - event bus  |      +-----------+      +-----------+
+--------------+                               |
                                               V
                                       +--- targets ---+
                                       |               |
                                       +---------------+
```

---

## API for AMS-IX

---

## Conclusion

---

## THANKS!