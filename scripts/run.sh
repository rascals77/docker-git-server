#!/bin/sh

BASE=/tmp/sshd

if [ "$(ls /git-keys/*.pub 2>/dev/null)" ] ; then
   cat /git-keys/*.pub > /git/keys/authorized_keys
   sed -i 's{^{command="/usr/bin/git-ssh-remote-command" {g' /git/keys/authorized_keys
   chmod 700 /git/keys
   chmod 644 /git/keys/authorized_keys
   chown -R git:git /git
fi

if [ ! -e "/tmp/.done" ] ; then
   touch /tmp/.done
   mkdir ${BASE}

   echo "ssh-keygen: generating new host keys: RSA"
   ssh-keygen -t rsa -N "" -f ${BASE}/ssh_host_rsa_key

   echo "ssh-keygen: generating new host keys: DSA"
   ssh-keygen -t dsa -N "" -f ${BASE}/ssh_host_dsa_key

   echo "ssh-keygen: generating new host keys: ECDSA"
   ssh-keygen -t ecdsa -N "" -f ${BASE}/ssh_host_ecdsa_key

   echo "ssh-keygen: generating new host keys: ED25519"
   ssh-keygen -t ed25519 -N "" -f ${BASE}/ssh_host_ed25519_key
fi

/usr/sbin/sshd -D
