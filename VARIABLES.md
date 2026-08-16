# Table of Content

- [The docker_compose variable](#the-docker_compose-variable)
- [The default variables](#the-default-variables)
- [The docker_compose_builds variable](#the-docker_compose_builds-variable)
- [The docker_compose_build variable](#the-docker_compose_build-variable)
- [The docker_compose_services variable](#the-docker_compose_services-variable)
- [The docker_compose_directories variable](#the-docker_compose_directories-variable)
- [The docker_compose_extdirs variable](#the-docker_compose_extdirs-variable)
- [The docker_compose_templates variable](#the-docker_compose_templates-variable)
- [The docker_compose_copies variable](#the-docker_compose_copies-variable)
- [The docker_compose_volumes variable](#the-docker_compose_volumes-variable)
- [The docker_compose_networks variable](#the-docker_compose_networks-variable)
- [The docker_compose_configs variable](#the-docker_compose_configs-variable)
- [The docker_compose_secrets variable](#the-docker_compose_secrets-variable)
- [The docker_compose_role_vars variable](#the-docker_compose_role_vars-variable)

# The `docker_compose` variable

The `docker_compose` variable contains the most basic information. You have to create one:

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`docker_compose.name`|String|NULL|**true**|The name of the compose/build project.|
|`docker_compose.image`|String|NULL|**true**|The name of the Docker image as `[<registry>/][<project>/]<image>`|
|`docker_compose.version`|String|NULL|**true**|The version tag of the Docker image as `<tag>[@<digest>]`|
|`docker_compose.arch`|List|`["linux/amd64"]`|Platforms in the format `os[/arch[/variant]]`|
|`docker_compose.basepath`|String|`{{ docker_compose_default_base_path }}`|false|By default projects will be build in `/opt/{{ docker_compose.name }}`|
|`docker_compose.build`|Boolean|true|false|Shall the container be built?|
|`docker_compose.build_args`|Dict|`{}`|false|Provide a dictionary of key:value build arguments that map to Dockerfile ARG directive|
|`docker_compose.build_labels`|Dict|`{}`|false|Dictionary of key value pairs|
|`docker_compose.build_nocache`|Boolean|true|false|Do not use cache when building an image. Have not observed this working at all|
|`docker_compose.build_pull`|Boolean|true|false|When building an image downloads any updates to the FROM image in Dockerfile|
|`docker_compose.build_rebuild`|String|`"never"`|false|Would accept `"always"` to build the image every time|
|`docker_compose.clean`|Boolean|false|false|Shall the Container be shut down and the image removed?|
|`docker_compose.compose`|Boolean|true|false|Shall the container be executed? Only works when at least one service is defined.|
|`docker_compose.composer_file`|String|`""`|false|Path to your own docker-compose.yml.|
|`docker_compose.composer_template`|String|`""`|false|Path to your own docker-compose.yml.j2 template.|
|`docker_compose.debug`|Boolean|false|false|Output additional information during the execution of the role.|
|`docker_compose.dockerfile_file`|String|`""`|false|Path to your own Dockerfile.|
|`docker_compose.dockerfile_template`|String|`""`|false|Path to your own Dockerfile.j2 template.|
|`docker_compose.execute_scripts`|**List**|NULL|false|Execute these shell scripts after starting the service. Relative to project directory. Container must be [healthy](https://docs.docker.com/compose/compose-file/05-services/#healthcheck).|
|`docker_compose.force_restart`|Boolean|false|false|Shall the container be restarted in any case?|
|`docker_compose.health_timeout`|Integer|10|false|How many times you want to wait 5 seconds until the container must be healthy for the `execute_scripts`.|
|`docker_compose.metadata`|Boolean|true|false|Creates a `metadata.json` file together with the compose.|
|`docker_compose.not_hosts`|**List**|`[]`|false|Does not deploy the container to hosts in this list. Based on `inventory_hostname`|
|`docker_compose.only_hosts`|**List**|`[]`|false|Only deploys the container to hosts in this list. Based on `inventory_hostname`|
|`docker_compose.outputs`|**List**|`[type: "docker"]`|false|You can provide a list of exporters to export the built image in various places|
|`docker_compose.purge`|Boolean|false|false|DANGER! Shall the container and `{{ docker_compose.basepath }}/{{ docker_compose.name }}` be removed? DANGER! **DATA LOSS!**|
|`docker_compose.push`|Boolean|false|false|Shall the container be pushed to a registry?|
|`docker_compose.rebuild`|Boolean|false|false|Shall all previous build images be deleted first? Will shut down the service too.|
|`docker_compose.restart`|Boolean|true|false|Shall the container be restarted if there was a change in any template?|
|`docker_compose.stack_version`|String|`"1.0.0"`|false|Allows differentiation between multiple versions.|

# The default variables

These variables are set by default:

|Variable|Type|Value|Description|
|:--|:--|:--|:--|
|`docker_compose_default_base_path`|String|"/opt"|The default base path. Container will be defined in `{{ docker_compose_default_base_path }}/{{ docker_compose.name }}/`|
|`docker_compose_default_build_shell`|List|'["/bin/sh", "-c"]'|The default container shell|
|`docker_compose_default_build_stop_signal`|String|"SIGTERM"|The default termination signal for containers|
|`docker_compose_default_build_user`|String|"root"|The default user inside the container. Risky. Aim to make it run with an unprivileged user|
|`docker_compose_default_build_workdir`|String|"/"|The default workdir inside the container|
|`docker_compose_default_mem_limit`|String|"50m"|The default amount of memory every container gets|
|`docker_compose_default_network`|String|"bridge"|The default network the container is attached to|
|`docker_compose_default_stop_grace_period`|String|"1s"|The default amount of time any containers get for graceful termination|
|`docker_compose_default_buildx_cache_prune`|Boolean|true|For pruning the docker buildx cache before and after building|
|`docker_compose_default_buildx_cache_prune_all`|Boolean|false|For including internal/frontend images in the pruning|

# The `docker_compose_builds` variable

The other mandatory variable is a **List** named `docker_compose_builds` where you define the topmost parts of the Dockerfile.

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`[].from`|String|NULL|**true**|[docs](https://docs.docker.com/reference/dockerfile/#from)|The image the Dockerfile is based on. Can be **scratch** (empty) too.|
|`[].args_before`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#arg)|Adds ARG's in front of the FROM directive.|
|`[].args_after`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#arg)||Adds ARG's after the FROM directive.|
|`[].adds`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#add)|Copys new files, directories or remote file URLs into the image.|
|`[].copies`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#copy)|Copies new files or directories into the image.|
|`[].envs`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#env)|Sets the environment variables `<key>` to the value `<value>`.|
|`[].runs`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#run)|List of commands to be executed during build. All will be squashed into one image layer.|

These blocks will be put after one another in the Dockerfile.
There are lists in lists in this.
Here is an example Structure:

```yaml
docker_compose_builds:
  - from: "golang:latest AS build"
    copies:
      - "src/main.go"
    runs:
      - "go build -o /bin/hello ./main.go"
  - from: "scratch"
    copies:
      - "--from=build /bin/hello /bin/hello"
docker_compose_build:
  cmds:
    - "/bin/hello"
```

# The `docker_compose_build` variable

The static lower part of the Dockerfile is defined in the **Dict** `docker_compose_build`, not mandatory:

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`[].volumes`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#volume)|List of volumes to mount.|
|`[].entrypoints`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#entrypoint)|List of **command and arguments** for the first command in the image.|
|`[].cmds`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#cmd)|Sets the **command and arguments** to be executed when running a container from an image.|
|`[].exposes`|**List**|`[]`|false|[docs](https://docs.docker.com/reference/dockerfile/#expose)|List of ports the container should expose.|
|`[].healthcheck`|**Dict**|`~`|false|[docs](https://docs.docker.com/reference/dockerfile/#healthcheck)|Tells Docker how to test a container to check that it is working.|
|`[].user`|String|`"root"`|false|[docs](https://docs.docker.com/reference/dockerfile/#user)|Sets the user name (or UID), group (or GID) to use for the image.|
|`[].workdir`|String|`"/"`|false|[docs](https://docs.docker.com/reference/dockerfile/#workdir)|Sets the working directory of the image.|
|`[].shell`|String|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#shell)|Sets the shell for the images user.|
|`[].stopsignal`|String|`SIGTERM`|false|[docs](https://docs.docker.com/reference/dockerfile/#stopsignal)|Sets the system call signal that will be sent to the container to exit.|
|`[].labels`|**List**|NULL|false|[docs](https://docs.docker.com/reference/dockerfile/#label)|List of key-value pairs of labels. Will be squashed into one line.|

A Healthcheck works like this:

```yaml
docker_compose_build:
  healthcheck:
    test: ["CMD", "curl", "-fs", "localhost:8080/api/health"]
    interval: "20s"
    timeout: "10s"
    retries: 3
```

# The `docker_compose_services` variable

This **list** variable defines, how your docker image(s) will be executed with docker-compose.
The names correspond to the the docker-compose [Specification](https://docs.docker.com/reference/compose-file/)

These elements refers to [Services top-level elements](https://docs.docker.com/compose/compose-file/05-services/).
Some elements are only usable in a Docker Swarm, which is not covered by this role, you should abstain from using them.
The list is in alphabetical order.

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`[].annotations`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#annotations)|Annotations as list.|
|`[].attach`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#attach)|Collect service logs?|
|`[].blkio_config`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#blkio_config)|Block IO limits for the service.|
|`[].cpu_count`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_count)|Number of CPUs for service container.|
|`[].cpu_percent`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_percent)|Usable percent of the available CPU.|
|`[].cpu_shares`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_shares)|Relative CPU weight versus other containers.|
|`[].cpu_period`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_period)|Configures CPU CFS (Completely Fair Scheduler) period on Linux.|
|`[].cpu_quota`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_quota)|Configures CPU CFS (Completely Fair Scheduler) quota on Linux.|
|`[].cpu_rt_runtime`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_rt_runtime)|CPU allocation parameters in milliseconds.|
|`[].cpu_rt_period`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpu_rt_period)|CPU allocation parameters in milliseconds.|
|`[].cpuset`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cpuset)|Explicit CPUs the container should run on. Range or list.|
|`[].cap_add`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cap_add)|Add [capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) to a container.|
|`[].cap_drop`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cap_drop)|Drop [capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) to a container.|
|`[].cgroup`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cgroup)|One of `host` or `private`.|
|`[].cgroup_parent`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#cgroup_parent)|Parent [cgroup](https://man7.org/linux/man-pages/man7/cgroups.7.html) for the container.|
|`[].command`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#command)|Overwrite default command from Dockerfile.|
|`[].configs`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#configs)|List of configs from the configs level.|
|`[].container_name`|String|`{{ docker_compose.name }}`|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#container_name)|Incompatible with `scale` must follow `[a-zA-Z0-9][a-zA-Z0-9_.-]+`|
|`[].depends_on`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#depends_on)|Control the order of service startup and shutdown. Long Syntax only.|
|`[].device_cgroup_rules`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#device_cgroup_rules)|Defines a list of device cgroup rules for this container.|
|`[].devices`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#devices)|Defines a list of device mappings for created containers.|
|`[].dns`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#dns)|Up to two DNS servers for the container in a list.|
|`[].dns_opt`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#dns_opt)|DNS options to be passed to the container’s DNS resolver.|
|`[].dns_search`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#dns_search)|List if DNS search domains to set on container.|
|`[].domainname`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#domainname)|Custom domain name. Must be a valid RFC 1123 hostname.|
|`[].entrypoint`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#entrypoint)|Overrides the `ENTRYPOINT` instruction from the service's Dockerfile.|
|`[].env_file`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#env_file)|List of environment variable files to be passed to the container.|
|`[].environment`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#environment)|Array of environment variables to be passed to the container.|
|`[].expose`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#expose)|List of exposed ports `<portnum>/[<proto>]` or `<startport-endport>/[<proto>]`.|
|`[].external_links`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#external_links)|List of external links to other service containers.|
|`[].extra_hosts`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#extra_hosts)|List of extra hostname mappings to the containers `/etc/hosts` file.|
|`[].group_add`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#group_add)|List of group names to add ti the containers user.|
|`[].healthcheck`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#healthcheck)|Configure Heathchecks for the container.|
|`[].hostname`|String|`{{ docker_compose.name }}`|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#hostname)|Must be a valid RFC 1123 hostname.|
|`[].image`|String|`{{ docker_compose.image }}:{{ docker_compose.version }}`|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#image)|Addressable image format `[<registry>/][<project>/]<image>:<tag>@<digest>`.|
|`[].init`|Boolean|false|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#init)|Run an init process inside the container. Platform specific.|
|`[].ipc`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#ipc)|Configures the IPC isolation mode set by the service container.|
|`[].isolation`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#isolation)|Supported values are platform specific.|
|`[].labels`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#labels)|Add metadata to containers. Array notation.|
|`[].links`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#links)|Defines a network link to containers in another service.|
|`[].logging`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#logging)|Set logging parameters for the container.|
|`[].mem_limit`|String|`50m`|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#mem_limit)|Configures a limit on the amount of memory a container can allocate.|
|`[].mem_swappiness`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#mem_swappiness)|Define how much swap a container is using in percent.|
|`[].memswap_limit`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#memswap_limit)|Defines the amount of memory the container is allowed to swap to disk.|
|`[].name`|String|`{{ docker_compose.name }}`|false|[docs](https://docs.docker.com/compose/compose-file/04-version-and-name/#name-top-level-element)|Name of the [$COMPOSE_PROJECT_NAME](https://docs.docker.com/compose/environment-variables/envvars/).|
|`[].network_mode`|String|"bridge"|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#network_mode)|Incompatible with networks definition.|
|`[].networks`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#networks)|Define the container networks.|
|`[].pid`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#pid)|Sets the PID mode for container created by Compose. Values are platform specific.|
|`[].pids_limit`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#pids_limit)|Tunes a container’s PIDs limit. Set to -1 for unlimited PIDs.|
|`[].platform`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#platform)|Defines the target platform the containers for the service run on. `os[/arch[/variant]]`|
|`[].ports`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#ports)|[Short Syntax](https://docs.docker.com/compose/compose-file/05-services/#short-syntax-3) only.|
|`[].privileged`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#privileged)|Just do not do this. Ever. Except you must.|
|`[].pull_policy`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#pull_policy)|Defines the decisions Compose makes when it starts to pull images.|
|`[].read_only`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#read_only)|Configures the service container to be created with a read-only filesystem.|
|`[].restart`|String|"always"|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#restart)|Defines the policy that the platform applies on container termination.|
|`[].runtime`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#runtime)|Specifies which runtime to use for the service’s containers.|
|`[].scale`|Integer|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#scale)|Specifies the default number of containers to deploy for this service. Incompatible with `[].container_name`.|
|`[].secrets`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#secrets)|Only [Short Syntax](https://docs.docker.com/compose/compose-file/05-services/#short-syntax-4) is supported.|
|`[].security_opt`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#security_opt)|Overrides the default labeling scheme for each container.|
|`[].shm_size`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#shm_size)|Configures the size of the shared memory.|
|`[].stdin_open`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#stdin_open)|Run the container interactive?|
|`[].stop_grace_period`|String|`1s`|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#stop_grace_period)|Specifies how long Compose must wait when attempting to stop a container.|
|`[].stop_signal`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#stop_signal)|Defines the signal that Compose uses to stop the service containers.|
|`[].storage_opt`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#storage_opt)|Defines storage driver options for a service.|
|`[].sysctls`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#sysctls)|Defines kernel parameters to set in the container. Array only.|
|`[].tmpfs`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#tmpfs)|Mounts a temporary file system inside the container.|
|`[].tty`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#tty)|Configures a service's container to run with a TTY.|
|`[].ulimits`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#ulimits)|Overrides the default ulimits for a container.|
|`[].user`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#user)|Overrides the user used to run the container process.|
|`[].userns_mode`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#userns_mode)|Sets the user namespace for the service.|
|`[].volumes`|**List of Dicts**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#volumes)|[Long Syntax](https://docs.docker.com/compose/compose-file/05-services/#long-syntax-5) only.|
|`[].volumes_from`|**List of Dicts**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#volumes_from)|Mounts all of the volumes from another service or container.|
|`[].working_dir`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/05-services/#working_dir)|Overrides the container's working directory which is specified by the image.|

This is a security concern, any compose can use this to mount host directories like `/var/run` or `/` into the container.

# The `docker_compose_directories` variable

This **list** contains all additional directories you need below `{{ docker_compose.basepath }}/{{ docker_compose.name }}/`.
Parent directories must be higher in the list than any of its sub directories.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`[].path`|String|NULL|**true**|The directory that shall be created relative to `{{ docker_compose.basepath }}/{{ docker_compose.name }}/|
|`[].mode`|String|"0755"|false|The directory mode.|
|`[].owner`|String|"root"|false|The directory owner.|
|`[].group`|String|"root"|false|The directory group.|

If the path contains any `..` the role will break.

# The `docker_compose_extdirs` variable

This **list** contains all additional external directories you need **outside** `{{ docker_compose.basepath }}/{{ docker_compose.name }}/`.
A symlink `{{ docker_compose.basepath }}/{{ docker_compose.name }}/{{ docker_compose_extdirs[].path | split('/') | last }}` will be created to point at this directory.
So a path `/mnt/backups` for a compose named `test` will have a symlink `/opt/test/backups` pointing at `/mnt/backups`.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`[].path`|String|NULL|**true**|The **absolute path** to a directory that shall be created|
|`[].mode`|String|"0755"|false|The directory mode.|
|`[].owner`|String|"root"|false|The directory owner.|
|`[].group`|String|"root"|false|The directory group.|

This is a security concern, any compose can use this to symlink host directories into the base directory and manipulate them with `docker_compose_templates` or `docker_compose_copies`.

# The `docker_compose_templates` variable

The files defined in this **list** will be templated with [ansible.builtin.template](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html), so put them in a `templates` directory that Ansible finds.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`[].src`|String|NULL|**true**|The template file for Ansible to template.|
|`[].dest`|String|NULL|**true**|The destination file relative to `{{ docker_compose.basepath }}/{{ docker_compose.name }}/`.|
|`[].mode`|String|"0644"|false|The destination file mode.|
|`[].owner`|String|"root"|false|The destination file owner.|
|`[].group`|String|"root"|false|The destination file group.|

If the dest contains any `..` the role will break.

# The `docker_compose_copies` variable

The files defined in this **list** will be copied with [ansible.builtin.copy](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html), so put them in a `files` directory that Ansible finds.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`[].src`|String|NULL|**true**|The extra files that shall be copied.|
|`[].dest`|String|NULL|**true**|The target for the files relative to `{{ docker_compose.basepath }}/{{ docker_compose.name }}/`|
|`[].mode`|String|"0755"|false|The directory mode.|
|`[].owner`|String|"root"|false|The directory owner.|
|`[].group`|String|"root"|false|The directory group.|

If the dest contains any `..` the role will break.

# The `docker_compose_volumes` variable

The elements in this **list** refer to the [Volumes top-level element](https://docs.docker.com/compose/compose-file/07-volumes/).
The `[].name` variable is the `<volume-name>` in the container and `<project_name>_<name>` for other containers, not the last attribute that is named `name` as well.
This means that this role does not allow volumes that contain special characters in the name.

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`[].name`|String|NULL|**true**|-|Name of the docker volume. Any volume must have one. Do not confuse with the missing name attribute.|
|`[].driver`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/#driver)|Specifies which volume driver should be used.|
|`[].driver_opts`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/#driver_opts)|Specifies a list of options as key-value pairs to pass to the driver for this volume.|
|`[].external`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/#external)|Specifies that this volume already exists on the platform and its lifecycle is managed outside of that of the application.|
|`[].labels`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/07-volumes/#labels)|Add metadata to volumes. Arrays only.|

# The `docker_compose_networks` variable

The elements in this **list** refer to the [Networks top-level elements](https://docs.docker.com/compose/compose-file/06-networks/).
The `[].name` variable is the `<network-name>` in the container and `<project_name>_<name>` for other containers, not the last attribute that is named `name` as well.
This means that this role does not allow networks that contain special characters in the name.

|Variable|Type|Default|Mandatory|Docs|Description|
|:--|:--|:--|:--|:--|:--|
|`[].name`|String|NULL|**true**|-|Name of the compose network. Any network element must have one. Do not confuse with missing name attribute!|
|`[].driver`|String|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#driver)|Specifies which driver should be used for this network.|
|`[].driver_opts`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#driver_opts)|Specifies a list of options as key-value pairs to pass to the driver.|
|`[].attachable`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#attachable)|If set to true, then standalone containers should be able to attach to this network.|
|`[].enable_ipv6`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#enable_ipv6)|Enables IPv6 networking.|
|`[].external`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#external)|Specifies that this network’s lifecycle is maintained outside of that of the application.|
|`[].ipam`|**Dict**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#ipam)|Specifies a custom IPAM configuration.|
|`[].internal`|Boolean|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#internal)|Allows you to create an externally isolated network.|
|`[].labels`|**List**|NULL|false|[docs](https://docs.docker.com/compose/compose-file/06-networks/#labels)|Add metadata to containers. Arrays only.|

# The `docker_compose_configs` variable

The elements in this **list** refer to [Configs top-level elements](https://docs.docker.com/compose/compose-file/08-configs/).
The `[].name` variable is the `<config-name>` in the container and `<project_name>_<name>` for other containers, not the last attribute that is named `name` as well.
This means that this role does not allow configs that contain special characters in the name.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`[].name`|String|NULL|**true**|Name of the configuration. Any configuration must have one. Do not confuse with name attribute!|
|`[].file`|String|NULL|false|The config is created with the contents of the file at the specified path.|
|`[].environment`|String|NULL|false|The config content is created with the value of an environment variable.|
|`[].content`|**List**|NULL|false|The content is created with all the elements as a multiline value.|
|`[].external`|Boolean|NULL|false|Specifies that this config has already been created.|

# The `docker_compose_secrets` variable

The elements in this **list** refer to [Secrets top-level elements](https://docs.docker.com/compose/compose-file/09-secrets/).
The `[].name` variable is the `<secret-name>` in the container and `<project_name>_<name>` for other containers.
Do not put special characters into the name.

|Variable|Type|Default|Mandatory|Description|
|:--|:--|:--|:--|:--|
|`[].name`|String|NULL|**true**|Name of the secret. Any secret must have one. Do not confuse with the missing name attribute.|
|`[].file`|String|NULL|false|The secret is created with the contents of the file at the specified path.|
|`[].environment`|String|NULL|false|The secret is created with the value of an environment variable.|

# The `docker_compose_role_vars` variable

This is a simple **list** of files, that the role will include with [ansible.builtin.include_vars](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_vars_module.html) at the beginning of the execution in the order they are provided.

