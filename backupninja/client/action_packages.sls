#!py
def run():
    '''
    Install packages based on which jobs are configured
    '''
    config = {}

    packages = []
    for key,value in __salt__['pillar.get']('backupninja:jobs', {}).iteritems():
      action = value.get('action')

      if 'rdiff' in action or 'rsync' in action:
        packages.append( action )
      elif 'svn' in action:
        packages.append('subversion-tools')
      elif 'dup' in action:
        packages.append('duplicity')

    for package in packages:
       config[package] = {
           'pkg': [
               'installed',
               {'name': package},
           ],
       }

    return config
