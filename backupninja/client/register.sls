# Note: This requires the "event" state which is to be added by hand (to _states in your fileserver) until its included in the stable version.
register_backup_client:
  event.fire_master:
    - name: {{ salt['pillar.get']('backupninja:register_event', 'backupninja/client/register') }}
    - data:
        ssh_pubkey: {{ salt['cmd.run']('test -f /root/.ssh/id_rsa.pub || ssh-keygen -q -N "" -f /root/.ssh/id_rsa && cat /root/.ssh/id_rsa.pub && touch /var/cache/salt/minion/backupninja_client.registered') }}
        server_id: {{ salt['grains.get']('server_id') }}
        backup_server: {{ salt['pillar.get']('backupninja:server', 'backup*') }}
    - unless: test -f /var/cache/salt/minion/backupninja_client.registered
