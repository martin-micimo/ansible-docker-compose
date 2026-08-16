[![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![YAML](https://img.shields.io/badge/yaml-%23CB171E.svg?style=for-the-badge&logo=yaml&logoColor=white)](https://yaml.org/)
[![Jinja](https://img.shields.io/badge/jinja-%23B41717.svg?style=for-the-badge&logo=jinja&logoColor=white)](https://palletsprojects.com/p/jinja/)

[![Issues](https://img.shields.io/github/issues/martin-micimo/ansible-docker-compose.svg)](https://github.com/martin-micimo/ansible-docker-compose/issues/)
[![PullRequests](https://img.shields.io/github/issues-pr-closed-raw/martin-micimo/ansible-docker-compose.svg)](https://github.com/martin-micimo/ansible-docker-compose/pulls/)

[![Ansible Role Downloads](https://img.shields.io/ansible/role/d/martin-micimo/docker_compose)](https://galaxy.ansible.com/ui/standalone/roles/martin-micimo/docker_compose/)
[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
[![Latest Release](https://img.shields.io/github/v/release/martin-micimo/ansible-docker-compose)](https://github.com/martin-micimo/ansible-docker-compose/releases)
[![EffVer Versioning](https://img.shields.io/badge/version_scheme-EffVer-0097a7)](https://jacobtomlinson.dev/effver)

# Docker Compose role

This role lets you set up [Docker](https://www.docker.com/) containers and services in a declarative way with [Ansible](https://www.ansible.com/).

# Table of Content

- [How to use the role](#how-to-use-the-role)
- [What is it good for](#what-is-it-good-for)
- [What is it not good for](#what-is-it-not-good-for)
- [Features](#features)
  - [Not working with the provided templates](#not-working-with-the-provided-templates)
- [Supported systems](#supported-systems)
- [Declarative data structure](#declarative-data-structure)
  - [VARIABLES.md](VARIABLES.md)
- [Examples](#examples)
  - [EXAMPLES.md](EXAMPLES.md)
- [Dependencies](#dependencies)
- [Tips and Tricks](#tipps-and-tricks)
- [License](#license)
- [Authors](#authors)

# Ho to use the role

Install the Role like this

    ansible-galaxy role install martin-micimo.docker_compose

Or include it in your `requirements.yml`

```yaml
roles:
  - name: martin-micimo.docker_compose
```
Then use it like this in a task list:

```yaml
- name: "Load variables for docker_compose role."
  ansible.builtin.include_vars: "my_docker_service.yml"
- name: "Run docker_compose role."
  ansible.builtin.include_role:
    name: "martin-micimo.docker_compose"
```

Or like this in a playbook:

```yaml
- name: "Playbook."
  pre_tasks:
    - name: "Load variables for docker_compose role."
      ansible.builtin.include_vars: "my_docker_service.yml"
  roles:
    - role: "martin-micimo.docker_compose"
```

# What is it good for

- You want to create and maintain a bunch of container services in a bigger setup.
- Migrating your bare metal services into containers.
- Learning more complicated ansible playbook setups.

# What is it not good for

- Installing the Docker Engine or the Compose plugin.
- Docker Swarm setups.
- This role looks too complicated for very simple docker compose setups.
- As this role is still maturing, it is IMHO not yet ready for a productive environment.

# Features

- [x] Most settings in the [Compose V2 specification](https://docs.docker.com/compose/compose-file/) work.
- [x] Most settings in the [Dockerfile specification](https://docs.docker.com/reference/dockerfile/) work.
- [x] Build, push and compose individual images.
- [x] Serve individual or stacked docker-compose.yml files.

## Not working with the provided templates

These directives and functions in the `docker-compose.yml` and `Dockerfile` specification are currently not supported:

- Most anything related to Docker Swarm or the deployment section of the compose specification.
- Have RUN commands in the Dockerfile that start with options.
- Changing the USER, SHELL or WORKDIR during the build process of the image.
- Specifying volumes or networks outside of the Dockerfile or docker-compose.yml files.

All of these limitations are circumventable by defining custom `docker_compose.composer_*` or `docker_compose.dockerfile_*` files.

# Supported systems

Only supports [POSIX](https://posix.opengroup.org/) compatible systems (Linux) with [Docker](https://www.docker.com/) and the [Compose Plugin](https://docs.docker.com/compose/) installed.

# Declarative data structure

Because Ansible is not handling big variable structures efficiently, this role aims to have a flat structure while giving you flexibility.

If you are looking for all the specific variables, you find them in the separate [VARIABLES.md](VARIABLES.md) file.

This is the List of Variables supported:

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`docker_compose`|**Dict**|NULL|**true**|-|General Information|
|`docker_compose_builds`|**List of Dicts**|NULL|**true**|-|The repeatable part of the Dockerfile|
|`docker_compose_build`|**Dict**|NULL|false|-|The static part of the Dockerfile|
|`docker_compose_services`|**List of Dicts**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/)|The most important part of the `docker-compose.yml`|
|`docker_compose_directories`|**List of Dicts**|NULL|false|-|Directories to create|
|`docker_compose_extdirs`|**List of Dicts**|NULL|false|-|Directories to create outside the compose project|
|`docker_compose_templates`|**List of Dicts**|NULL|false|-|Templates to template|
|`docker_compose_copies`|**List of Dicts**|NULL|false|-|Files to copy|
|`docker_compose_volumes`|**List of Dicts**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/)|Volumes to manage in the `docker-compose.yml`|
|`docker_compose_networks`|**List of Dicts**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/)|Networks to manage in the `docker-compose.yml`|
|`docker_compose_configs`|**List of Dicts**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/08-configs/)|Configs to manage in the `docker-compose.yml`|
|`docker_compose_secrets`|**List of Dicts**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/09-secrets/)|Secrets to manage in the `docker-compose.yml`|
|`docker_compose_role_vars`|**List**|NULL|false|-|Load variables from these files at the beginning|

# Examples

You can find some examples in the [EXAMPLES.md](EXAMPLES.md)

# Dependencies

Ansible >= 2.12

|Collections|Executables|Plugins|
|:--|:--|:--|
|community.docker|docker|docker compose|

# Tips and Tricks

Here are some suggestions:

- When you use variables like `{{ mycompose_port }}` in your `docker_compose` structure and include them from a vars file, make sure you have that variable defined somewhere.
- Never use variables from a dictionary or list in that same dictionary or list.
- If you want no important layers stuck in your buildx cache and be potentially pruned by `docker buildx prune --all` you have to push the image to a registry during or after build. Or you build the image to a file, clean everything up and the load the image file and tag it properly. This is especially true for multiarch upstream images that you retaged, they will completely stay in the buildx cache.

# License

This Work is licensed under the [GPLv3 License](https://www.gnu.org/licenses/gpl-3.0.de.html)

# Authors

Created in 2024 by [Martin Meier](https://micimo.de/)

