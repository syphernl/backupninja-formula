{% from "backupninja/map.jinja" import backupninja with context %}

# Stuff for a backup-client
openssh-client:
  pkg.installed

backupninja:
  pkg.installed

##############################
# Needed for backup actions
##############################
include:
  - backupninja.client.action_packages
