#!py
def run():
    '''
    Install packages based on which jobs are configured
    '''
    config = {}

    packages = []
    for key,value in __salt__['pillar.get']('backupninja:jobs', {}).items():
      action = value.get('action')

      if 'rsync' in action:
        packages.append('rsync')
      elif 'rdiff' in action:
        packages.append('rdiff-backup')
      elif 'svn' in action:
        packages.append('subversion-tools')
      elif 'dup' in action or 's3' in action:
        packages.append('duplicity')

    for package in packages:
       config[package] = {
           'pkg': [
               'installed',
               {'name': package},
           ],
       }

    return config
