# Generate configuration for Backupnjinja based on pillar
{% from "backupninja/map.jinja" import backupninja with context %}
{% set ninjaconf = salt['pillar.get']('backupninja:config', {} ) %}
{% set configdirectory = salt['pillar.get']('backupninja:config:configdirectory', '/etc/backup.d') %}

# Install BackupNinja main config
/etc/backupninja.conf:
  file.managed:
    - template: jinja
    - source: salt://backupninja/templates/backupninja.conf.jinja
    - context: {{ ninjaconf }}
    - mode: 0600

# Generate the job files
{% for backup_name, backup_options in salt['pillar.get']('backupninja:jobs', {}).items() %}
{% set backup_type = backup_options.get('action') %}
{% set backup_priority = backup_options.get('priority', 10) %}
{% set backup_settings = backup_options.get('config', []) %}

# Create a backupninja config file
backup_job_{{backup_type}}_{{ backup_name }}:
  file.managed:
    - name: {{configdirectory}}/{{backup_priority}}-{{backup_name}}.{{backup_type}}
    - template: jinja
    - source: salt://backupninja/templates/actions/{{backup_type}}.jinja
    - context: {{ backup_settings }}
    - mode: 0600

{% endfor %}
