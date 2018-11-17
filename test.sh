#!/bin/bash

umask 022

REPODIR=repos
KEYSDIR=keys
KEYNAME=id_rsa
SSHPORT=2222
SSHHOST=127.0.0.1

for PROG in docker docker-compose git ssh-keygen ; do
   if ! hash ${PROG} 2>/dev/null ; then
      echo "ERROR: ${PROG} is not in PATH... exiting."
      exit 1
   fi
done

if [ ! -e "docker-compose.yml" ] ; then
   echo "ERROR: docker-compose.yml does not exist... exiting."
   exit 1
fi

for DIR in ${REPODIR} ${KEYSDIR} ; do
   mkdir ${DIR} 2>/dev/null
   if hash chcon 2>/dev/null ; then
      chcon -t container_file_t ${DIR}
      if [ $? -ne 0 ] ; then
         echo "ERROR: enable to change SELinux context... exiting."
         exit 1
      fi
   fi
done

echo -e "\x1b[1;32mGenerate ssh keys\x1b[0m"
ssh-keygen -q -t rsa -N "" -f ${KEYSDIR}/id_rsa
if [ $? -ne 0 ] ; then
   echo "ERROR: enable to generate ssh keys... exiting."
   exit 1
fi
echo

echo -e "\x1b[1;32mStart git server docker container\x1b[0m"
docker-compose up -d
if [ $? -ne 0 ] ; then
   echo "ERROR: enable to start container... exiting."
   exit 1
fi
sleep 2
echo

echo -e "\x1b[1;32mCheck ssh connectivity to git server\x1b[0m"
echo ssh -x -p ${SSHPORT} -i ${KEYSDIR}/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no git@${SSHHOST}
ssh -q -x -p ${SSHPORT} -i ${KEYSDIR}/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no git@${SSHHOST}
if [ $? -ne 128 ] ; then
   echo "ERROR: expected return code of [128], but got [$?]... exiting."
   exit 1
fi
echo

echo -e "\x1b[1;32mCreate repo within git server repository directory\x1b[0m"
mkdir ${REPODIR}/mytest
pushd ${REPODIR}/mytest 1>/dev/null
git init --bare
popd 1>/dev/null
echo

echo -e "\x1b[1;32mCreate working clone of repo\x1b[0m"
git clone -v git@mygitserver:mytest
echo

echo -e "\x1b[1;32mMake a commit\x1b[0m"
pushd mytest 1>/dev/null
echo "This is a test file" > testfile1
git add testfile1
git commit -m "Added testfile1"
git push origin HEAD
popd 1>/dev/null
echo

echo -e "\x1b[1;32mCheck log of repo within git server repository directory\x1b[0m"
pushd ${REPODIR}/mytest 1>/dev/null
git log
popd 1>/dev/null
echo

echo -e "\x1b[1;32mCheck log within working clone of repo\x1b[0m"
pushd mytest 1>/dev/null
git log
popd 1>/dev/null
echo

echo -e "\x1b[1;32mDestroy the git server\x1b[0m"
docker-compose down

exit 0
