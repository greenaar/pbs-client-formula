# -*- coding: utf-8 -*-
# vim: ft=sls
#
# Optional cron schedule for the backup script. Without this, `install.sls`
# only drops the script -- nothing runs it automatically.

{% from "pbs-client/map.jinja" import config with context %}

{% if config.installed and config.get('schedule') %}
pbs-client-cron:
  file.managed:
    - name: /etc/cron.d/pbs-client-backup
    - mode: '0644'
    - user: 'root'
    - group: 'root'
    - contents: |
        {{ config.schedule }} root /usr/local/bin/backup-to-pbs >> /var/log/pbs-client-backup.log 2>&1
    - require:
      - file: pbs-client-backup-script
{% else %}
pbs-client-cron-absent:
  file.absent:
    - name: /etc/cron.d/pbs-client-backup
{% endif %}
