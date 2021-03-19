import os
c.ServerApp.ip = '*'
c.ServerApp.allow_remote_access = True
c.KernelManager.shutdown_wait_time = 10.0
c.FileContentsManager.delete_to_trash = False
c.ServerApp.quit_button = False
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}
c.ServerApp.notebook_dir = '/jupyter'

if 'PASSWORD' in os.environ:
    from notebook.auth import passwd
    c.ServerApp.password = passwd(os.environ['PASSWORD'])
    del os.environ['PASSWORD']
