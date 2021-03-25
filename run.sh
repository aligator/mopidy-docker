#!/bin/bash

USERNAME=mopidy
OWNER=${OWNER:-65534}
GROUP=${GROUP:-65534}

# create users matching ids passed if necessary
if [[ ${GROUP} -gt 65534 || ${GROUP} -lt 1000 ]]; then
  echo "invalid gid"
  exit 1
fi

if [[ ${OWNER} -gt 65534 || ${OWNER} -lt 1000 && ${OWNER} -ne 666 ]]; then
  echo "invalid uid"
  exit 1
fi


if getent passwd ${OWNER} ; then deluser $(getent passwd ${OWNER} | cut -d: -f1); fi
if getent group ${GROUP} ; then delgroup $(getent group ${GROUP} | cut -d: -f1); fi

addgroup --gid $GROUP $USERNAME
useradd -g $GROUP -u $OWNER -m -s /bin/nologin $USERNAME

mkdir -p /home/${USERNAME}/.cache
chown $OWNER:$GROUP /home/${USERNAME}/.cache
ls -la /home/${USERNAME}


# create the directory if necessary
if [ ! -d /mopidy/music ]; then
  mkdir -p /mopidy/music
  chown $OWNER:$GROUP /mopidy/music
fi


mkdir -p /home/${USERNAME}/.config/mopidy /home/${USERNAME}/.local/share/mopidy /home/${USERNAME}/mopidy
chown $OWNER:$GROUP /home/${USERNAME}/.config/mopidy /home/${USERNAME}/.local/share/mopidy /home/${USERNAME}/mopidy

if [ $UPDATE = "true" ]; then
    echo "-- UPDATING ALL PACKAGES --"
    sudo apt-get update
    sudo apt-get upgrade -y
    pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U # Upgrade all pip packages
fi

if [ ${APT_PACKAGES:+x} ]; then
    echo "-- INSTALLING APT PACKAGES $APT_PACKAGES --"
    sudo apt-get update
    sudo apt-get install -y $APT_PACKAGES
fi
if  [ ${PIP_PACKAGES:+x} ]; then
    echo "-- INSTALLING PIP PACKAGES $PIP_PACKAGES --"
    pip3 install $PIP_PACKAGES
fi

mkdir -p /tmp/snapcast
touch /tmp/snapcast/snapfifo
chown ${OWNER}:${GROUP} /tmp/snapcast/snapfifo

echo setup finished
exec /bin/su $USERNAME -s /bin/sh -c /usr/local/bin/mopidy "$@"