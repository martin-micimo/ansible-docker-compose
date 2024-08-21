[![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![YAML](https://img.shields.io/badge/yaml-%23CB171E.svg?style=for-the-badge&logo=yaml&logoColor=white)](https://yaml.org/)
[![Jinja](https://img.shields.io/badge/jinja-%23B41717.svg?style=for-the-badge&logo=jinja&logoColor=white)](https://palletsprojects.com/p/jinja/)

[![Issues](https://img.shields.io/github/issues/martin-micimo/ansible-docker-compose.svg)](https://github.com/martin-micimo/ansible-docker-compose/issues/)
[![PullRequests](https://img.shields.io/github/issues-pr-closed-raw/martin-micimo/ansible-docker-compose.svg)](https://github.com/martin-micimo/ansible-docker-compose/pulls/)

[![Ansible Role Downloads](https://img.shields.io/ansible/role/d/martin-micimo/docker-compose)](https://galaxy.ansible.com/ui/standalone/roles/martin-micimo/docker-compose/)
[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
[![Latest Release](https://img.shields.io/github/v/release/martin-micimo/ansible-docker-compose)](https://github.com/martin-micimo/ansible-docker-compose/releases)
[![EffVer Versioning](https://img.shields.io/badge/version_scheme-EffVer-0097a7)](https://jacobtomlinson.dev/effver)

# Docker Compose role

This role lets you set up [Docker](https://www.docker.com/) containers and services in a declarative way with [Ansible](https://www.ansible.com/).

## What is it good for

- You want to create and maintain a bunch of container services in a bigger setup.
- Migrating your bare metal services into containers.
- Learning more complicated ansible playbook setups.

## What is it not for

- Installing the Docker Engine or the Compose plugin.
- Docker Swarm setups.
- This role looks too complicated for very simple docker compose setups.

# Table of Content

- [Features](#features)
  - [Not working with the provided templates](#not-working-with-the-provided-templates)
- [Supported systems](#supported-systems)
- [Declarative data structure](#declarative-data-structure)
  - [Top level variables of the data structure](#top-level-variables-of-the-data-structure)
  - [Build elements](#build-elements)
  - [Configs elements](#configs-elements)
  - [Copies elements](#copies-elements)
  - [Directories elements](#directories-elements)
  - [Networks elements](#networks-elements)
  - [Secrets elements](#secrets-elements)
  - [Service elements](#services-elements)
  - [Template elements](#templates-elements)
  - [Volumes elements](#volumes-elements)
- [Examples](#examples)
  - [Minimal example](#minimal-example)
  - [A small example with CoreDNS](#a-small-example-with-coredns)
  - [A bigger example with CoreDNS and a self build image](#a-bigger-example-with-coredns-and-a-self-build-image)
  - [Loading the variables from a vars file](#loading-the-variables-from-a-vars-file)
  - [Example var files](#example-var-files)
  - [Full compose examples](#full-compose-examples)
- [Dependencies](#dependencies)
- [Tips and Tricks](#tipps-and-tricks)
- [License](#license)
- [Authors](#authors)

# Features

- [x] Most settings in the [Compose V2 specification](https://docs.docker.com/compose/compose-file/) work.
- [x] Most settings in the [Dockerfile specification](https://docs.docker.com/reference/dockerfile/) work.
- [x] Build, push and compose individual images.
- [x] Serve individual or stacked docker-compose.yml files.

## Not working with the provided templates

These directives and functions in the `docker-compose.yml` and `Dockerfile` specification are currently not supported:

- Most anything related to Docker Swarm or the deployment section of the compose specification.
- Multistaged images.
- Having multiple RUN commands in the Dockerfile. Or have them start with options.
- Changing the USER, SHELL or WORKDIR during the build process of the image.
- Specifying volumes or networks outside of the Dockerfile or docker-compose.yml files.

All of these limitations are circumventable by defining custom `docker_compose_composer_*` or `docker_compose_dockerfile_*` files.

# Supported systems

Only supports [POSIX](https://posix.opengroup.org/) compatible systems (Linux) with [Docker](https://www.docker.com/) and the [Compose Plugin](https://docs.docker.com/compose/) installed.

# Declarative data structure

This role expects two variables to be set externaly, or it will not work:

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`docker_compose_name`|String|NULL|true|-|The name of the compose/build project.|
|`docker_compose`|Dictionary|NULL|true|[Declarative data structure](#declarative-data-structure)|The definition of the container.|
|`docker_compose_role_vars`|String|NULL|false|-|Allows you to load a vars file with [ansible.builtin.include_vars](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_vars_module.html)|

These default variables can be overwritten safely:

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`docker_compose_basepath`|String|`/opt`|false|Path where the project will be get its home directory.|
|`docker_compose_build_it`|Boolian|true|false|Shall the container be built?|
|`docker_compose_clean_it`|Boolian|false|false|Shall all files be purged?|
|`docker_compose_compose_it`|Boolian|true|false|Shall the container be executed? Only works when at leas one service is defined.|
|`docker_compose_debug_it`|Boolian|false|false|Output additional information during the execution of the role.|
|`docker_compose_execute_after`|List|NULL|false|Execute these shell scripts after starting the service. Relative to project directory. Container must be [healthy](https://docs.docker.com/compose/compose-file/05-services/#healthcheck).|
|`docker_compose_not_hosts`|List|[]|false|Does not deploy the container to hosts in this list. Based on `inventory_hostname`|
|`docker_compose_only_hosts`|List|[]|false|Only deploys the container to hosts in this list. Based on `inventory_hostname`|
|`docker_compose_purge_it`|Boolian|false|false|DANGER! Shall the container (and all files and data) be removed? DANGER! DATA LOSS!|
|`docker_compose_push_it`|Boolian|false|false|Shall the image be pushed after building it. You have to provide a registry with the `docker_compose.image` value.|
|`docker_compose_rebuild_it`|Boolian|false|false|Shall all previous build images be deleted first? Will shut down the service too.|
|`docker_compose_restart_it`|Boolian|true|false|Shall the container be restarted if there was a change in any templates?|
|`docker_compose_composer_file`|String|NULL|false|Write your own docker-compose.yml and use that instead of the template.|
|`docker_compose_composer_template`|String|NULL|false|Write your own docker-compose.yml.j2 template and use that instead of the provided one.|
|`docker_compose_dockerfile_file`|String|NULL|false|Write your own Dockerfile and use that instead of the template.|
|`docker_compose_dockerfile_template`|String|NULL|false|Write your own Dockerfile.j2 template and use that instead of the provided one.|

## Top level Variables of the data structure

The data structure must be named `docker_compose` and is a dictionary, that includes some or all of the mentioned fields for all of the defined containers.

The first part are the variables that must be there:

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`image`|String|NULL|true|[docs](https://docs.docker.com/compose/compose-file/05-services/#image)|Adressable image format `[<registry>/][<project>/]<image>`.|
|`version`|String|NULL|true|-|Tag and Digest part of the adressable image format `<tag>@<digest>`.|
|`name`|String|`{{ docker_compose_name }}`|true|[docs](https://docs.docker.com/compose/compose-file/04-version-and-name/#name-top-level-element)|Name of the [$COMPOSE_PROJECT_NAME](https://docs.docker.com/compose/environment-variables/envvars/).|

We continue with data structures that are defined below, for more complicated stuff.

|Variable|Type|Default|Mandatory|Docs|README Chapter|
|:--|:--|:--|:--|:--|:--|
|`build`|Dictionary|NULL|false|-|[Build elements](#build-elements)|
|`configs`|List of dictionaries|NULL|false|[docs](https://docs.docker.com/compose/compose-file/08-configs/)|[Configs elements](#configs-elements)|
|`copies`|List of dictionaries|NULL|false|-|[Copies elements](#copies-elements)|
|`directories`|List|NULL|false|-|[Directories elements](#directories-elements)|
|`networks`|List of dictionaries|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/)|[Network elements](#network-elements)|
|`secrets`|List of dictionaries|NULL|false|[docs](https://docs.docker.com/compose/compose-file/09-secrets/)|[Secrets elements](#secrets-elements)|
|`services`|List of dictionaries|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/)|[Services elements](#service-elements)|
|`templates`|List|NULL|false|-|[Template elements](#template-elements)|
|`volumes`|List of dictionaries|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/)|[Volumes elements](#volumes-elements)|

## Build elements

If you want to build a new Docker image you should set this variable.
These fields define what will be written into the `Dockerfile` of the service.
You should be able to build a lot of single stage Docker images with this.
All the elements are put into the Dockerfile in the order of this list.

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`arg_before`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#arg)|Adds ARG's in front of the FROM directive.|
|`from`|String|NULL|true|[docs](https://docs.docker.com/reference/dockerfile/#from)|Only one build section allowed for now.|
|`arg_after`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#arg)|Adds ARG's after the FROM directive.|
|`adds`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#add)|Copys new files, directories or remote file URLs into the image.|
|`copys`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#copy)|Copies new files or directories into the image.|
|`envs`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#env)|Sets the environment variables `<key>` to the value `<value>`.|
|`runs`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#run)|List of commands to be executed during build. All will be squashed into one image layer.|
|`volumes`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#volume)|List of volumes to mount.|
|`entrypoints`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#entrypoint)|List of command and parameters for the first command in the image.|
|`cmds`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#cmd)|Sets the command to be executed when running a container from an image.|
|`exposes`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#expose)|List of ports the container should expose.|
|`healthcheck`|String|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#healthcheck)|Tells Docker how to test a container to check that it is working.|
|`user`|String|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#user)|Sets the user name (or UID), group (or GID) to use for the image.|
|`workdir`|String|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#workdir)|Sets the working directory of the image.|
|`shell`|String|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#shell)|Sets the shell for the images user.|
|`stopsignal`|String|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#stopsignal)|Sets the system call signal that will be sent to the container to exit.|
|`labels`|List|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#label)|List of key-value pairs of labels. Will be squashed into one line.|

## Configs elements

These elements refere to [Configs top-level elements](https://docs.docker.com/compose/compose-file/08-configs/).
The `name` variable is the `<config-name>` in the container and `<project_name>_<name>` for other containers, not the last attribute that is named `name` as well.
This means that this role does not allow configs that contain special characters in the name.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`name`|String|NULL|true|Name of the configuration. Any configuration must have one. Do not confuse with name attribute!|
|`file`|String|NULL|false|The config is created with the contents of the file at the specified path.|
|`environment`|String|NULL|false|The config content is created with the value of an environment variable.|
|`content`|List|NULL|false|The content is created with all the elements as a multiline value.|
|`external`|Boolian|NULL|false|Specifies that this config has already been created.|

## Copies elements

The files defined in this list will be copied with [ansible.builtin.copy](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html), so put them in a `files` directory that ansible finds.
Currently you can copy into the whole root filesystem on the target host by defining a `dest` that starts with `../../` ... so be carefull.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`src`|String|NULL|true|The extra files that shall be copied.|
|`dest`|String|NULL|true|The target for the files relative to `{{ docker_compose_basepath }}/{{ docker_compose_name }}/`|
|`mode`|String|"0755"|false|The directory mode.|
|`owner`|String|"root"|false|The directory owner.|
|`group`|String|"root"|false|The directory group.|

## Directories elements

This list should contain all additional directories you need below `{{ docker_compose_basepath }}/{{ docker_compose_name }}/`.
Parent directories must be higher in the list than any of its subdirectories.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`path`|String|NULL|true|The extra directory that shall be created.|
|`mode`|String|"0755"|false|The directory mode.|
|`owner`|String|"root"|false|The directory owner.|
|`group`|String|"root"|false|The directory group.|

## Networks elements

These elements refere to [Networks top-level elements](https://docs.docker.com/compose/compose-file/06-networks/).
The `name` variable is the `<network-name>` in the container and `<project_name>_<name>` for other containers, not the last attribute that is named `name` as well.
This means that this role does not allow networks that contain special characters in the name.

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`name`|String|NULL|true|-|Name of the compose network. Any network element must have one. Do not confuse with missing name attribute!|
|`driver`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#driver)|Specifies which driver should be used for this network.|
|`driver_opts`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#driver_opts)|Specifies a list of options as key-value pairs to pass to the driver.|
|`attachable`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#attachable)|If set to true, then standalone containers should be able to attach to this network.|
|`enable_ipv6`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#enable_ipv6)|Enables IPv6 networking.|
|`external`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#external)|Specifies that this network’s lifecycle is maintained outside of that of the application.|
|`ipam`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#ipam)|Specifies a custom IPAM configuration.|
|`internal`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#internal)|Allows you to create an externally isolated network.|
|`labels`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#labels)|Add metadata to containers. Arrays only.|

## Secrets elements

These elements refere to [Secrets top-level elements](https://docs.docker.com/compose/compose-file/09-secrets/).
The `name` variable is the `<secret-name>` in the container and `<project_name>_<name>` for other containers.
Do not put special caracters into the name.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`name`|String|NULL|true|Name of the secret. Any secret must have one. Do not confuse with the missing name attribute.|
|`file`|String|NULL|false|The secret is created with the contents of the file at the specified path.|
|`environment`|String|NULL|false|The secret is created with the value of an environment variable.|

## Services elements

These elements refere to [Services top-level elements](https://docs.docker.com/compose/compose-file/05-services/).
Some elements are only usable in a Docker Swarm, which is not covered by this role, you should abstain from using them.
The list starts with the elements that must be set and continues with the other elements in alphabetical order.

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`image`|String|`{{ docker_compose.image }}:{{ docker_compose.version }}`|true|[docs](https://docs.docker.com/compose/compose-file/05-services/#image)|Adressable image format `[<registry>/][<project>/]<image>:<tag>@<digest>`.|
|`name`|String|`{{ docker_compose_name }}`|true|-|The Name of the service. At least the second service in the list has to have this element.|
|`annotations`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#annotations)|Annotations as list.|
|`attach`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#attach)|Collect service logs?|
|`blkio_config`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#blkio_config)|Block IO limits for the service.|
|`cpu_count`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_count)|Number of CPUs for service container.|
|`cpu_percent`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_percent)|Usable percent of the available CPU.|
|`cpu_shares`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_shares)|Relative CPU weight versus other containers.|
|`cpu_period`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_period)|Configures CPU CFS (Completely Fair Scheduler) period on Linux.|
|`cpu_quota`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_quota)|Configures CPU CFS (Completely Fair Scheduler) quota on Linux.|
|`cpu_rt_runtime`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_rt_runtime)|CPU allocation parameters in milliseconds.|
|`cpu_rt_period`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_rt_period)|CPU allocation parameters in milliseconds.|
|`cpuset`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpuset)|Explicit CPUs the container should run on. Range or list.|
|`cap_add`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cap_add)|Add [capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) to a container.|
|`cap_drop`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cap_drop)|Drop [capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) to a container.|
|`cgroup`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cgroup)|One of `host` or `private`.|
|`cgroup_parent`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cgroup_parent)|Parent [cgroup](https://man7.org/linux/man-pages/man7/cgroups.7.html) for the container.|
|`command`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#command)|Overwrite default command from Dockerfile.|
|`configs`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#configs)|List of configs from the configs level.|
|`container_name`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#container_name)|Incompatible with `scale` must follow `[a-zA-Z0-9][a-zA-Z0-9_.-]+`|
|`depends_on`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#depends_on)|Control the order of service startup and shutdown. Long Syntax only.|
|`device_cgroup_rules`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#device_cgroup_rules)|Defines a list of device cgroup rules for this container.|
|`devices`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#devices)|Defines a list of device mappings for created containers.|
|`dns`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#dns)|Up to two DNS servers for the container in a list.|
|`dns_opt`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#dns_opt)|DNS options to be passed to the container’s DNS resolver.|
|`dns_search`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#dns_search)|List if DNS search domains to set on container.|
|`domainname`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#domainname)|Custom domain name. Must be a valid RFC 1123 hostname.|
|`entrypoint`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#entrypoint)|Overrides the `ENTRYPOINT` instruction from the service's Dockerfile.|
|`env_file`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#env_file)|List of environment variable files to be passed to the container.|
|`environment`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#environment)|Array of environment variables to be passed to the container.|
|`expose`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#expose)|List of exposed ports `<portnum>/[<proto>]` or `<startport-endport>/[<proto>]`.|
|`external_links`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#external_links)|List of external links to other service containers.|
|`extra_hosts`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#extra_hosts)|List of extra hostname mappings to the containers `/etc/hosts` file.|
|`group_add`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#group_add)|List of group names to add ti the containers user.|
|`healthcheck`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#healthcheck)|Configure Heathchecks for the container.|
|`hostname`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#hostname)|Must be a valid RFC 1123 hostname.|
|`init`|Boolian|false|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#init)|Run an init process inside the container. Platform specific.|
|`ipc`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#ipc)|Configures the IPC isolation mode set by the service container.|
|`isolation`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#isolation)|Supported values are platform specific.|
|`labels`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#labels)|Add metadata to containers. Array notation.|
|`links`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#links)|Defines a network link to containers in another service.|
|`logging`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#logging)|Set logging parameters for the container.|
|`mem_limit`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#mem_limit)|Configures a limit on the amount of memory a container can allocate.|
|`mem_swappiness`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#mem_swappiness)|Define how much swap a container is using in percent.|
|`memswap_limit`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#memswap_limit)|Defines the amount of memory the container is allowed to swap to disk.|
|`network_mode`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#network_mode)|Incompatible with networks definition.|
|`networks`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#networks)|Define the container networks.|
|`pid`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#pid)|Sets the PID mode for container created by Compose. Values are platform specific.|
|`pids_limit`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#pids_limit)|Tunes a container’s PIDs limit. Set to -1 for unlimited PIDs.|
|`platform`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#platform)|Defines the target platform the containers for the service run on. `os[/arch[/variant]]`|
|`ports`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#ports)|[Short Syntax](https://docs.docker.com/compose/compose-file/05-services/#short-syntax-3) only.|
|`privileged`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#privileged)|Just do not do this. Ever. Except you must.|
|`pull_policy`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#pull_policy)|Defines the decisions Compose makes when it starts to pull images.|
|`read_only`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#read_only)|Configures the service container to be created with a read-only filesystem.|
|`restart`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#restart)|Defines the policy that the platform applies on container termination.|
|`runtime`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#runtime)|Specifies which runtime to use for the service’s containers.|
|`scale`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#scale)|Specifies the default number of containers to deploy for this service. Incompatible with `container_name`.|
|`secrets`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#secrets)|Only [Short Syntax](https://docs.docker.com/compose/compose-file/05-services/#short-syntax-4) is supported.|
|`security_opt`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#security_opt)|Overrides the default labeling scheme for each container.|
|`shm_size`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#shm_size)|Configures the size of the shared memory.|
|`stdin_open`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#stdin_open)|Run the container interactive?|
|`stop_grace_period`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#stop_grace_period)|Specifies how long Compose must wait when attempting to stop a container.|
|`stop_signal`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#stop_signal)|Defines the signal that Compose uses to stop the service containers.|
|`storage_opt`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#storage_opt)|Defines storage driver options for a service.|
|`sysctls`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#sysctls)|Defines kernel parameters to set in the container. Array only.|
|`tmpfs`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#tmpfs)|Mounts a temporary file system inside the container.|
|`tty`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#tty)|Configures a service's container to run with a TTY.|
|`ulimits`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#ulimits)|Overrides the default ulimits for a container.|
|`user`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#user)|Overrides the user used to run the container process.|
|`userns_mode`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#userns_mode)|Sets the user namespace for the service.|
|`volumes`|List of Dictionaries|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#volumes)|[Long Syntax](https://docs.docker.com/compose/compose-file/05-services/#long-syntax-5) only.|
|`volumes_from`|List of Dictionaries|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#volumes_from)|Mounts all of the volumes from another service or container.|
|`working_dir`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#working_dir)|Overrides the container's working directory which is specified by the image.|

## Templates elements

The files defined in this list will be templated with [ansible.builtin.template](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html), so put them in a `templates` directory that ansible finds.
Currently you can template into the whole root filesystem on the target host by defining a `dest` that starts with `../../` ... so be carefull.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`src`|String|NULL|true|The template file for ansible to template.|
|`dest`|String|NULL|true|The destination file.|
|`mode`|String|"0644"|false|The destination file mode.|
|`owner`|String|"root"|false|The destination file owner.|
|`group`|String|"root"|false|The destination file group.|

## Volumes elements

These elements refere to [Volumes top-level element](https://docs.docker.com/compose/compose-file/07-volumes/).
The `name` variable is the `<volume-name>` in the container and `<project_name>_<name>` for other containers, not the last attribute that is named `name` as well.
This means that this role does not allow volumes that contain special characters in the name.

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`name`|String|NULL|true|-|Name of the docker volume. Any volume must have one. Do not confuse with the missing name attribute.|
|`driver`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/#driver)|Specifies which volume driver should be used.|
|`driver_opts`|Dictionary|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/#driver_opts)|Specifies a list of options as key-value pairs to pass to the driver for this volume.|
|`external`|Boolian|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/#external)|Specifies that this volume already exists on the platform and its lifecycle is managed outside of that of the application.|
|`labels`|List|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/#labels)|Add metadata to volumes. Arrays only.|

# Examples

## Minimal Example

```yaml
---
- name: Simple local debian_slim container.
  hosts: localhost
  gather_facts: false
  become: true
  roles:
    - role: martin-micimo.docker-compose
      vars:
        docker_compose_name: debian
        docker_compose_compose_it: false
        docker_compose:
          image: debian_slim
          version: latest
...
```

This would just pull `debian_slim:latest` (if not present already) and create a Dockerfile in `/opt/debian` with only the `FROM` definition.

## A small example with CoreDNS

```yaml
---
- name: Small example with CoreDNS.
  hosts: somehost
  gather_facts: false
  become: true
  roles:
    - role: martin-micimo.docker-compose
      vars:
        docker_compose_name: coredns
        docker_compose_build_it: false
        docker_compose:
          image: "coredns/coredns"
          version: "latest"
          services:
            - entrypoint:
                - coredns
                - "-conf"
                - conf/Corefile
              ports:
                - "53"
                - "53/udp"
              restart: always
              volumes:
                - type: bind
                  source: ./conf
                  target: /opt/coredns/conf
              workdir: /opt/coredns
          templates:
            - src: "coredns_corefile.j2"
              dest: "conf/Corefile"
            - src: "coredns_zone_file.j2"
              dest: "conf/zone.example.com"
          directories:
            - path: conf
...
```

You will also need templatable `coredns_corefile.j2` and `coredns_zone_file.j2` files in the `templates` directory of your playbook.

This will playbook will do this (in this order) on somehost:

- Create `/opt/coredns`
- Create `/opt/coredns/conf`
- Create a `/opt/coredns/docker-compose.yml`
- Create a `/opt/coredns/conf/Corefile` with the template `coredns_corefile.j2`
- Create a `/opt/coredns/conf/zone.example.com` with the template `coredns_zone_file.j2`
- Bring the compose to the state "up"

## A bigger example with coredns and a self build image

```yaml
---     
- name: Small example with CoreDNS.
  hosts: somehost
  gather_facts: false
  become: true
  roles:
    - role: martin-micimo.docker-compose
      vars: 
        docker_compose_name: coredns
        docker_compose:
          image: "coredns"
          version: "1.11.1"
          services:
            - container_name: coredns
              mem_limit: 200m
              ports:
                - 53
                - 53/udp
              restart: always
              stop_grace_period: 1s
              volumes:
                - type: bind
                  source: ./conf
                  target: /opt/coredns/conf
          templates:
            - src: coredns_corefile.j2
              dest: conf/Corefile
            - src: coredns_zone_file.j2
              dest: conf/zone.example.com
          directories:
            - path: conf
          build:
            from: "debian_bookworm:12.2024.05.13"
            run:
              - "apt-get update"
              - "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections"
              - "apt-get install -y --no-install-recommends curl ca-certificates"
              - "apt-get autoremove && apt-get clean autoclean"
              - "mkdir -p /opt/coredns"
              - "cd /opt/coredns"
              - "curl -L -o /opt/coredns/coredns.tgz https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_amd64.tgz"
              - "tar xf coredns.tgz"
              - "rm -f coredns.tgz"
            entrypoint: '["/opt/coredns/coredns", "-conf", "conf/Corefile"]'
            expose:
              - "53"
              - "53/udp"
            user: nobody
            workdir: /opt/coredns
...
```

This will create a `/opt/coredns/Dockerfile` with this content:

```
FROM debian_bookworm:12.2024.05.13
RUN echo "Building Image" && \
    apt-get update && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    apt-get autoremove && apt-get clean autoclean && \
    mkdir -p /opt/coredns && \
    cd /opt/coredns && \
    curl -L -o /opt/coredns/coredns.tgz https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_amd64.tgz && \
    tar xf coredns.tgz && \
    rm -f coredns.tgz

ENTRYPOINT ["/opt/coredns/coredns", "-conf", "conf/Corefile"]
EXPOSE 53 53/udp
USER nobody
WORKDIR /opt/coredns
```

This will create a `/opt/coredns/docker-compose.yml` with this content:

```yaml
services:
  coredns:
    container_name: coredns
    image: coredns:1.11.1
    restart: always
    stop_grace_period: 1s
    mem_limit: 200m
    ports:
      - 53:53
      - 53:53/udp
    volumes:
      - type: "bind"
        source: "/opt/coredns/conf"
        target: "/opt/coredns/conf"
```

The process runs in this order:

- The folders `/opt/coredns/` and `/opt/coredns/config` will be created if missing.
- The templates will be templated.
- The image will be build, if not already present.
- The compose stack will be brought to the `up` state if not already.
- If there was a change on any of the templates, the stack will be brought `down` and `up` again.

## Loading the variables from a vars file

To have a slim playbook, you can declare the variables in a YAML file in the `vars` directory (in the playbooks directory) and load them from there:

```yaml
---
- name: Ansible CoreDNS deployment.
  hosts: edge
  gather_facts: true
  tasks:
      ansible.builtin.include_role:
        name: "martin-micimo.docker_compose"
      vars:
        docker_compose_role_vars: "coredns.yml"
...
```

For a bigger setup you migth consider this directory and files layout:

```
.ansible-lint
.ansible-vault
.gitignore
.myawesomepipeline
deploy.sh
playbook.yml
config/inventory.yml
config/ansible.cfg
vars/mycompose.yml
vars/mysimplecompose.yml
vars/...
files/mycompose/file_1
files/mycompose/file_2
files/...
templates/mycompose_config.yml.j2
templates/mycompose_init.sh.j2
templates/...
group_vars/all/mycompose.yml
group_vars/all/secrets.yml
group_vars/web/mycompose_web.yml
group_vars/...
roles/requirements.yml
```

## Example var files

You will find different examplary vars files in the [examples](examples) folder:

|File|Description|
|:--|:--|
|[prometheus_grafana.yml](examples/prometheus_grafana.yml)|A simple observation stack including the Node-Exporter|

## Full Compose examples

You will find an example of a heavily overconfigured `docker_compose` service in [test/docker_compose.yml](test/docker_compose.yml)

# Dependencies

|Collections|Executables|Plugins|
|:--|:--|:--|
|community.docker|docker|docker compose|

# Tips and Tricks

Here are some suggestions:

- When you use variables like `{{ mycompose_port }}` in your `docker_compose` structure and include them from a vars file, make sure you have that variable defined somewhere.
- Never use variables from a dictionary or list in that same dictionary or list.

# License

This Work is licensed under the [GPLv3 License](https://www.gnu.org/licenses/gpl-3.0.de.html)

# Authors

Created in 2024 by [Martin Meier](https://micimo.de/)

