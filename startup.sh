#!/bin/bash

nohup broadwayd :5 &

kettleVersion=5

if [ "${ROOTINGRESSURL}" == "" ]; then
  echo "NO ROOTINGRESSURL provided."
  exit 1
fi

if [ "${SPRING_PROFILE}" == "" ]; then
  echo "NO SPRING_PROFILE provided."
  exit 1
fi

##
# Fetching latest kettle configs
echo "Downloading latest kettle configuration for job ${jobId}"
for f in $(curl -s ${ROOTINGRESSURL}/configsvc/configsvc/api/config/listProfileFolder/kettle/${SPRING_PROFILE} | jq -r '.[]'); do
    echo "Downloading kettle configuration file ${f}"
    mkdir -p /dv1/bps_r3/utils/
    curl -s ${ROOTINGRESSURL}/configsvc/configsvc/api/config/profileFolderFile/kettle/${SPRING_PROFILE}/${f} > /dv1/bps_r3/utils/${f} 
    if [[ ${f} == *.sh ]]
    then
       chmod a+x /dv1/bps_r3/utils/${f}
    fi
done

##
# Fetching latest kettle configs
echo "Downloading latest kettle configuration specific to version ${kettleVersion} for job ${jobId}"
for f in $(curl -s ${ROOTINGRESSURL}/configsvc/configsvc/api/config/listProfileSubFolder/kettle/${SPRING_PROFILE}/${kettleVersion} | jq -r '.[]'); do
    echo "Downloading kettle configuration specific to version ${kettleVersion} file ${f}"
    mkdir -p /dv1/bps_r3/utils/
    curl -s ${ROOTINGRESSURL}/configsvc/configsvc/api/config/profileFolderSubFile/kettle/${SPRING_PROFILE}/${kettleVersion}/${f} > /dv1/bps_r3/utils/${f} 
    if [[ ${f} == *.sh ]]
    then
       chmod a+x /dv1/bps_r3/utils/${f}
    fi
done


#!/bin/bash

mkdir -p /var/run/sshd

# create an ubuntu user
# PASS=`pwgen -c -n -1 10`
PASS=ubuntu
# echo "Username: ubuntu Password: $PASS"
id -u ubuntu &>/dev/null || useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu
echo "ubuntu:$PASS" | chpasswd
sudo -u ubuntu -i bash -c "mkdir -p /home/ubuntu/.config/pcmanfm/LXDE/ \
    && cp /usr/share/doro-lxde-wallpapers/desktop-items-0.conf /home/ubuntu/.config/pcmanfm/LXDE/"

cd /web && ./run.py > /var/log/web.log 2>&1 &
nginx -c /etc/nginx/nginx.conf
exec /bin/tini -- /usr/bin/supervisord -n
