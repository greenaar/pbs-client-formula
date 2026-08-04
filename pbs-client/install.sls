# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "pbs-client/map.jinja" import config with context %}

{% if config.installed %}
include:
  - .repo

pbs-client-pkg:
  pkg.installed:
    - name: proxmox-backup-client
    - require:
      - sls: pbs-client.repo

pbs-client-env:
  file.managed:
    - name: /etc/pbs-client/pbs-client.env
    - mode: '0600'
    - user: 'root'
    - group: 'root'
    - makedirs: True
    - template: jinja
    - source: salt://pbs-client/files/pbs-client.env.j2
    - show_changes: False

pbs-client-backup-script:
  file.managed:
    - name: /usr/local/bin/backup-to-pbs
    - mode: '0755'
    - user: 'root'
    - group: 'root'
    - template: jinja
    - source: salt://pbs-client/files/pbs.sh.j2
    - require:
      - file: pbs-client-env
{% else %}
pbs-client-remove-pkg:
  pkg.purged:
    - name: proxmox-backup-client

pbs-client-remove-files:
  file.absent:
    - names:
      - /usr/local/bin/backup-to-pbs
      - /etc/pbs-client/pbs-client.env
      - /etc/cron.d/pbs-client-backup
{% endif %}
