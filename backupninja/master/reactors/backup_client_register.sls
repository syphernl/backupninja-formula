# This is the "bridge" between the event (trigged by a minion) and the reaction (on the backupmaster(s))
# Executed on the master, which triggers the tgt
add_minion_to_backup_server:
  cmd.state.sls:
    - tgt: {{ data['data']['backup_server'] }}
    - arg:
      - backupninja.master.add_client
    - kwarg:
        pillar:
          new_minion: {{ data['id'] }}
          new_pubkey: {{ data['data']['ssh_pubkey'] }}
          new_serverid: {{ data['data']['server_id'] }}
