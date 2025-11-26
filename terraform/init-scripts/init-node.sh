#
# Basic node initialization
#

# Setup hostname
HOST_IP_ADDR=`ip -f inet address show dev eth0 | grep inet | tr '/' ' ' | awk '{ print $2 }'`
HOST_DNS_NAME=`host ${HOST_IP_ADDR} | sed 's/\.$//' | awk '{ print $5 }'`
echo "${HOST_DNS_NAME}" > /etc/hostname

# Update the outdated stuff
export DEBIAN_FRONTEND=noninteractive
apt-get -y update && apt-get -y upgrade
apt-get -y install net-tools

echo "INIT Node done." >> ${INIT_LOG}

# EOF
