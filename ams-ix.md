---
title: Ansible @ AMS-IX

---

# Ansible @ AMS-IX

---

## Adfinis

- .ch: RedHat Premium partner
- .nl: HashiCorp EMEA Focus partner of the year 2023
- .nl: GitLab Services Partner of the year 2023 for EMEA

Open Source knowledge center.

---

## Who are you/we?

---

## Overview

- Automate everything
- Ansible for OS variations
- GitLab CI
- Event Drive Ansible
- API for AMS-IX

---

## Automate everything

Besides "normal" use-cases (playbooks & roles):

- [Document generation](https://github.com/robertdebock/ansible-generator)
- [Retry CI](https://github.com/robertdebock/ci-retry)
- [Set a secret on GitHub](file:///Users/robertdb/Documents/github.com/robertdebock/github-set-secret)
- Scripting
- Orchestration

---

## Ansible for OS variations

Ansible is great at writing to solve OS variations.

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

httpd_package: "{{ _httpd_packages[ansible_os_family] | \
  default(_httpd_packages['default'] }}"

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

## GitLab CI

Testing, releasing and deploying can be done using GitLab (or GitHub).

----

## GitLab Testing

```yaml
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
image: "robertdebock/github-action-molecule:6.0.1"

galaxy:
  script:
    - ansible-galaxy role import --api-key ${GALAXY_API_KEY} robertdebock ${CI_PROJECT_NAME}
  rules:
    - if: $CI_COMMIT_TAG != null
```

----

## GitLab deploying

Better using Ansible Automation Platform because:

- RBAC
- More readable output
- Execution environment
- Scheduling
- Queueing

> GitLab, build yourself.

---

## Event Driven Ansible

Event Driven Ansible (EDA) reacts to events, and calls Ansible Automation Controller to run a playbook.

```text
+--- source ---+      +--- EDA ---+      +--- AAC ---+
| - monitoring | <--- | runbooks  | ---> |           |
| - event bus  |      +-----------+      +-----------+
| - ...        |                               |
+--------------+                               V
                                       +--- targets ---+
                                       |               |
                                       +---------------+
```

---

## API for AMS-IX

AAP does offer an [API](https://docs.ansible.com/automation-controller/latest/html/controllerapi/api_ref.html#) to integrate AAP in an orchestrator or workflow.

----

## Assumptions

My feeling is that AMS-IX want to expose network related API details, such as:

- Network lists
- Network details
- IP ranges
- Traffic details

Ansible Automation Platform would be hard to fit this requirement.

---

## Conclusion

1. Ansile: Automate everyting
2. AAP/EDA: Easily run Ansible
3. GitLab: Develop and test

---

## THANKS!
