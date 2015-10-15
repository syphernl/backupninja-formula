# Note: This requires the "event" state which is to be added by hand (to _states in your fileserver) until its included in the stable version.
{%- if salt['grains.get']('backupninja_client_registered', False) == False %}
register_backup_client:
  event.fire_master:
    - name: {{ salt['pillar.get']('backupninja:register_event', 'backupninja/client/register') }}
    - data:
        ssh_pubkey: {{ salt['cmd.run']('test -f /root/.ssh/id_rsa.pub || ssh-keygen -q -N "" -f /root/.ssh/id_rsa && cat /root/.ssh/id_rsa.pub') }}
        server_id: {{ salt['grains.get']('server_id') }}
        backup_server: {{ salt['pillar.get']('backupninja:server', 'backup*') }}

backupninja_client_registered:
  grains.present:
    - value: True
    - watch:
      - event: register_backup_client
{%- endif %}
