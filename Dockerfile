FROM alpine:3.8

MAINTAINER Shawn Johnson <sjohnso@gmail.com>

RUN apk add --no-cache \
    openssh \
    git && \
    cp /dev/null /etc/motd && \
    sed -i "s/^#Port.*/Port 2022/g" /etc/ssh/sshd_config && \
    sed -i "s/^#UseDNS.*/UseDNS no/g" /etc/ssh/sshd_config && \
    sed -i "s/^#PidFile.*/PidFile \/tmp\/sshd\/sshd.pid/g" /etc/ssh/sshd_config && \
    sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    sed -i "s/^AuthorizedKeysFile.*/AuthorizedKeysFile \/git\/keys\/authorized_keys/g" /etc/ssh/sshd_config && \
    sed -i "s/#*HostKey \/etc\/ssh\/\(ssh_host_.*\)/HostKey \/tmp\/sshd\/\1/g" /etc/ssh/sshd_config && \
    sed -i "/sftp/s/^/#/g" /etc/ssh/sshd_config && \
    echo -e "\nAllowGroups sshusers" >> /etc/ssh/sshd_config && \
    adduser -h /home/git -s /bin/sh -D -H git && \
    sed -i '/^git:/d' /etc/shadow && \
    echo "git:::0:::::" >> /etc/shadow && \
    mkdir -p /home/git && \
    chmod 0700 /home/git && \
    chown -R git:git /home/git && \
    addgroup sshusers && \
    sed -i "/^sshusers:/s/$/git/" /etc/group && \
    mkdir /git-keys && \
    mkdir -p /git/keys && \
    chown git:git /git/keys

ADD scripts/run.sh /usr/sbin/run.sh
ADD scripts/git-ssh-remote-command /usr/bin/git-ssh-remote-command

RUN chmod 755 /usr/sbin/run.sh /usr/bin/git-ssh-remote-command

VOLUME ["/git-keys", "/home/git"]

EXPOSE 2022

CMD ["/usr/sbin/run.sh"]
