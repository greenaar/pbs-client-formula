# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "pbs-client/map.jinja" import config with context %}

{% if config.installed %}
pbs-client-repo-key:
  cmd.run:
    - name: curl -fsSL https://enterprise.proxmox.com/debian/proxmox-release-{{ config.repo }}.gpg -o /etc/apt/trusted.gpg.d/pbs-client-keyring.gpg
    - unless: test -s /etc/apt/trusted.gpg.d/pbs-client-keyring.gpg

pbs-client-repo:
  pkgrepo.managed:
    - name: 'deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/pbs-client-keyring.gpg] http://download.proxmox.com/debian/pbs-client {{ config.repo }} main'
    - file: /etc/apt/sources.list.d/pbs-client-binary.list
    - clean_file: True
    - refresh: True
    - require:
      - cmd: pbs-client-repo-key
{% else %}
pbs-client-repo-remove:
  file.absent:
    - names:
      - /etc/apt/trusted.gpg.d/pbs-client-keyring.gpg
      - /etc/apt/sources.list.d/pbs-client-binary.list
{% endif %}
