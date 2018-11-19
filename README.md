This was developed using git v1.8.3.1. From git v2.3.0, the use of the ```GIT_SSH_COMMAND``` environment variable instead of leveraging ```~/.ssh/config```.

Make your ```~/.ssh/config``` file look like this:

```
UserKnownHostsFile /dev/null
StrictHostKeyChecking no

Host mygitserver
    Hostname localhost
    Port 2222
    IdentityFile ~/docker-git-server/keys/id_rsa
    IdentitiesOnly yes
```

