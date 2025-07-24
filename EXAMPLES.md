# Table of content

- [Minimal example](#minimal-example)
- [A small example with CoreDNS](#a-small-example-with-coredns)
- [A bigger example with CoreDNS and a self build image](#a-bigger-example-with-coredns-and-a-self-build-image)
- [Loading the variables from a vars file](#loading-the-variables-from-a-vars-file)
- [Example var files](#example-var-files)
- [Full compose examples](#full-compose-examples)

# Minimal Example

```yaml
---
- name: Simple local debian_slim container.
  hosts: localhost
  gather_facts: false
  become: true
  roles:
    - role: martin-micimo.docker-compose
      vars:
        docker_compose:
          name: debian
          image: debian_slim
          version: latest
          compose: false
...
```

This would just pull `debian_slim:latest` (if not present already) and create a Dockerfile in `/opt/debian` with only the `FROM` definition.

## A small example with CoreDNS

```yaml
---
- name: Small example with CoreDNS.
  hosts: examplehost
  gather_facts: false
  become: true
  roles:
    - role: martin-micimo.docker-compose
      vars:
        docker_compose:
          name: coredns
          image: "coredns/coredns"
          version: "latest"
          build: false
        docker_compose_services:
          - entrypoint:
              - coredns
              - "-conf"
              - conf/Corefile
            ports:
              - "53"
              - "53/udp"
            volumes:
              - type: bind
                source: ./conf
                target: /opt/coredns/conf
            workdir: /opt/coredns
        docker_compose_templates:
          - src: "coredns_corefile.j2"
            dest: "conf/Corefile"
          - src: "coredns_zone_file.j2"
            dest: "conf/zone.example.com"
        docker_compose_directories:
          - path: conf
...
```

You will also need a `coredns_corefile.j2` and `coredns_zone_file.j2` files in one of the `templates` directories of your project.

This will playbook will do this (in this order) on examplehost:

- Create `/opt/coredns`
- Create `/opt/coredns/conf`
- Create a `/opt/coredns/docker-compose.yml`
- Create a `/opt/coredns/conf/Corefile` with the template `coredns_corefile.j2`
- Create a `/opt/coredns/conf/zone.example.com` with the template `coredns_zone_file.j2`
- Bring the compose to the state "up"

## A bigger example with coredns and a self build image

```yaml
---     
- name: CoreDNS Example.
  hosts: examplehost
  gather_facts: false
  become: true
  roles:
    - role: martin-micimo.docker-compose
      vars: 
        docker_compose:
          name: coredns
          image: "coredns"
          version: "1.11.1"
        docker_compose_builds:
          - from: "debian_bookworm:12.2024.12.23"
            runs:
              - "apt-get update"
              - "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections"
              - "apt-get install -y --no-install-recommends curl ca-certificates"
              - "apt-get autoremove && apt-get clean autoclean"
              - "mkdir -p /opt/coredns"
              - "cd /opt/coredns"
              - "curl -L -o /opt/coredns/coredns.tgz https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_amd64.tgz"
              - "tar xf coredns.tgz"
              - "rm -f coredns.tgz"
        docker_compose_build:
          entrypoint: '["/opt/coredns/coredns", "-conf", "conf/Corefile"]'
          exposes:
            - "53"
            - "53/udp"
          user: nobody
          workdir: /opt/coredns
        docker_compose_services:
          - container_name: coredns
            mem_limit: 200m
            ports:
              - 53
              - 53/udp
            volumes:
              - type: bind
                source: ./conf
                target: /opt/coredns/conf
        docker_compose_templates:
          - src: coredns_corefile.j2
            dest: conf/Corefile
          - src: coredns_zone_file.j2
            dest: conf/zone.example.com
        docker_compose_directories:
            - path: conf
...
```

This will create a `/opt/coredns/Dockerfile` with this content:

```
FROM debian_bookworm:12.2024.12.23
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

For a bigger setup you might consider this directory and files layout:

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

I hope you will find different example vars files in the [examples](examples) folder:

|File|Description|
|:--|:--|
|[prometheus_grafana.yml](examples/prometheus_grafana.yml)|A simple observation stack including the Node-Exporter|

## Full Compose examples

You find an example of a heavily overconfigured `docker_compose` service in [test/docker_compose.yml](test/docker_compose.yml)

