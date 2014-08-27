# This script tis triggered locally on the backup master(s)
{% from "backupninja/map.jinja" import backupninja with context %}

{% set new_minion   = salt['pillar.get']('new_minion') | lower %}
{% set new_pubkey   = salt['pillar.get']('new_pubkey') %}
{% set new_serverid = salt['pillar.get']('new_serverid') %}

# Generate an SSH username
{% set ssh_username = 'bu_' + new_serverid|string() %}

# Cleanup minion name to turn it into a username
{% set bu_pathname_a   = new_minion | truncate(1, True, '') %}
{% set bu_pathname_b   = new_minion | truncate(2, True, '') %}
{% set backup_basepath = '/srv/backups/' + bu_pathname_a + '/' + bu_pathname_b %}
{% set backup_path = backup_basepath + '/' + new_minion %}

# Basedir should exist
{{ backup_basepath }}:
  file.directory:
    - makedirs: True

# Create backup structure for user
backup_user_{{ new_minion }}:
  user.present:
    - name: {{ ssh_username }}
    - shell: /usr/bin/rssh
    - home: {{ backup_path }}
    - createhome: True
  file.directory:
    - name: {{ backup_path }}
    - makedirs: True
    - user: {{ ssh_username }}
    - require:
      - file: {{ backup_basepath }}
      - user: {{ ssh_username }}
  ssh_auth.present:
    - name: {{ new_pubkey }}
    - user: {{ ssh_username }}
    - enc: ssh-rsa
    - require:
      - user: {{ ssh_username }}
