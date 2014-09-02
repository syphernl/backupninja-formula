{% from "backupninja/map.jinja" import backupninja with context %}

/srv/backups:
  file.directory

# Configure rssh to restrict access to particular prtocols
#/etc/rssh.conf:
#  file.managed:
#    - source: salt://security/rssh.conf
#    - require:
#      - pkg: rssh
