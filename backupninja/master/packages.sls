{% from "backupninja/map.jinja" import backupninja with context %}

# Stuff for a backup-master
rsync:
  pkg.installed

rdiff-backup:
  pkg.installed

openssh-client:
  pkg.installed

openssh-server:
  pkg.installed

rssh:
  pkg.installed
