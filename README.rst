backupninja-formula
==================

This state allows you to easily backup your minions using Backupninja.
As an added bonus, it allows you to setup a backup server which receives those backups.

By default Backupninja has support for several backup approaches including rdiff, rsync and mysqldumps but can also execute custom jobs.

Configuration
----------------

The configuration of this state is done via pillar.
There are two sections to configure:

Backupninja
-----
The configuration for backupninja itself is fully customizable via Pillar. All settings that are available in ``/etc/backupninja.conf` can be set via Pillar.
By default it follows the default settings provided by this configuration and no changes are needed for it to work, unless specific situations require you to do so.

Configuration is done in the `backupninja:config` section of the pillars and is used to modify `/etc/backupninja.conf`.

See the `templates/backupninja.conf.jinja` file for all available options.

Backup jobs
-----
The jobs themselves are configured in the `backupninja:jobs` section of the pillar file.
Like the main configuration all settings for the configuration can be set via pillars and is using the default value if none is provided.

Each job has two sections, the global one with the priority and which action to execute and the action-configuration.
Actions are templates used by Backupninja and can be extended and provided with info via the `config` subsection.

For instance, if you want to backup MySQL databases this is a job configuration you can use:
```
backup_mysql_db:                    #<-- The name of the job. Must be unique troughout the pillar(s)
  action: mysql                     #<-- Which action to use, based on template availability in `templates/actions`
  priority: 10                      #<-- The priority of the backup. You'd want to place the "transfer backup"-job at a low prio to execute last
  config:                           #<-- Subsection with the configuration of the action
    hotcopy: no
    sqldump: yes
    compress: yes
    backupdir: /var/backups/mysql   #<-- Where to back up the database files?
    databases:                      #<-- Want all databases? Simply provide `all` as a value.
      - mysql
      - projectx
      - projecty
```

Each action has its own parameters, the exact one's are described in the individual templates for each action, available in `templates/actions`.

Available states
================

.. contents::
    :local:


``backupninja.server``
---------------------

This state will turn this machine into a "backup master" allowing clients to connect and drop of their backupfiles.
Files will be stored to `/srv/backups/` in nested folders.
E.g. if your node is called 'node01.example.com' it will be stored in: `/srv/backups/n/no/node01.example.com`.

Firewall
~~~~~~~~

The backup server requires the following ports to be open incoming from the clients:

* 22 (TCP)

``backupninja.client``
---------------------

This state will install Backupninja, its dependencies and the configuration.
Depending on the pillar configuration it will automatically install additional packages (e.g. rsync if you use the 'rsync' backup action)

This package has no hard tie-ins to the `backupninja.server` and can be used to transfer files to any server that is supported by Backupninja itself (e.g. ssh/rsync).

``backupninja.client.register``
---------------------
This is a state with a little bit of added (optional) magic.

It will trigger an event via Salt Reactor to inform the backup server(s) about its existance and sends its public key.
The backup master (configured in the `backupninja:server` pillar) will be triggered by this to create a user and its storage location.
You can set this to a FQDN or a partial (e.g. `backup*`)

The use of this state is optional. If you prefer not to use it, you have to make sure a backup user exists on the destination by other means.

By default a user with the "server id" (based on the FQDN) will be generated, which is also available in the grains (`salt['grans.get']('server_id')`).
This state requires the `event` state which is available in Salt `2014.7` or can be added manually to the fileserver (confirmed working at `2014.1.7` and up).

The `salt-master` needs to know which event to trigger. This is configured in the master configuration.

Assuming you do not have any reactors yet you should add the following to `/etc/salt/master.d/reactor.conf`:
```
reactor:
  - 'backupninja/client/added':
    - /srv/salt/formulas/backupninja/backupninja/master/reactors/backup_client_register.sls
```

The name of the event tag can be modified in the pillar (`backupninja:register_event`)

You should change the path to match your environment.
The reactor should point towards the file included in this formula (`reactors/backup_client_register.sls`)
The eventname can be customized via pillars `backupjinja:event` and defaults to `backupninja/client/added`
