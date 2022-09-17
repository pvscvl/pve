#!/usr/bin/env bash -ex
set -euo pipefail
shopt -s inherit_errexit nullglob
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
BGN=`echo "\033[4;92m"`
GN=`echo "\033[1;92m"`
DGN=`echo "\033[32m"`
CL=`echo "\033[m"`
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
clear
echo -e "${BL}This script will Perform Post Install Routines.${CL}"
while true; do
    read -p "Start the Script (y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
#if [ `cat /proc/cpuinfo | grep 'Common KVM processor'| uniq` -ne 1 ]; then
#        echo -e "\n${RD}⚠ This version of Proxmox Virtual Environment is not supported"
#        echo -e "Requires PVE Version: 7.XX${CL}"
#        echo -e "\nExiting..."
#        sleep 3
#        exit
#fi
if [[ "${UID}" -ne 0 ]]; then
    echo " You need to run this script as root"
    exit 1
fi


function header_info {
echo -e "${RD}
                      __     _            __        ____      __  _                               _       __ 
    ____  ____  _____/ /_   (_)___  _____/ /_____ _/ / /___ _/ /_(_)___  ____     _______________(_)___  / /_
   / __ \/ __ \/ ___/ __/  / / __ \/ ___/ __/ __ `/ / / __ `/ __/ / __ \/ __ \   / ___/ ___/ ___/ / __ \/ __/
  / /_/ / /_/ (__  ) /_   / / / / (__  ) /_/ /_/ / / / /_/ / /_/ / /_/ / / / /  (__  ) /__/ /  / / /_/ / /_  
 / .___/\____/____/\__/  /_/_/ /_/____/\__/\__,_/_/_/\__,_/\__/_/\____/_/ /_/  /____/\___/_/  /_/ .___/\__/  
/_/                                                                                            /_/           
${CL}"
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

clear
header_info

#if [ `cat /proc/cpuinfo | grep 'Common KVM processor'| uniq` -ne 0 ]; then
#        echo -e "\n${RD}⚠ This version of Proxmox Virtual Environment is not supported"
#        echo -e "Requires PVE Version: 7.XX${CL}"
#        echo -e "\nExiting..."
#        sleep 3
#        exit
#fi
echo Hostname is $HOSTNAME
read -r -p "Change hostname? <y/N>" prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
read -r -p "" hostnameprompt
hostname=$hostnameprompt
msg_ok "Hostname changed to $hostnameprompt"
fi

cd
[ ! -d "./dotfiles" ] && mkdir -p "./dotfiles"
cp .bashrc ./dotfiles/bashrc-$(date +\%Y-\%m-\%d_\%H\%M).txt
wget -q -O .bashrc https://raw.githubusercontent.com/pvscvl/dotfiles/main/.bashrc 
msg_ok ".bashrc loaded"
fi


read -r -p "Load .bashrc? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Moving existing .bashrc in ./dotfiles and load .bashrc from github"
sleep 1
cd
[ ! -d "./dotfiles" ] && mkdir -p "./dotfiles"
cp .bashrc ./dotfiles/bashrc-$(date +\%Y-\%m-\%d_\%H\%M).txt
wget -q -O .bashrc https://raw.githubusercontent.com/pvscvl/dotfiles/main/.bashrc 
msg_ok ".bashrc loaded"
fi

read -r -p "Install Neofetch <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Installing Neofetch..."
sleep 1
apt update
apt install neofetch &>/dev/null
echo "Neofetch" >> .bashrc
msg_ok "Neofetch installed"
fi



read -r -p "Install Qemu Agent and Linux-Virtual packages? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Installing Qemu Agent and Linux-Virtual packages"
sleep 1
msg_info "Updating package lists"
apt update &>/dev/null
msg_info "Installing Qemu Guest Agent."
apt install qemu-guest-agent -y &>/dev/null
msg_info "Installing Linux-Virtual packages"
apt install --install-recommends linux-virtual -y &>/dev/null
apt install linux-tools-virtual linux-cloud-tools-virtual -y &>/dev/null
msg_ok "Installed qemu-guest-agent, linux-virtual, linux-tools-virtual and linux-cloud-tools-virtual"
fi



read -r -p "Remove Ubuntu Booting Bug? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Removing Ubuntu Booting Bug"
sleep 1
sed -i "s/^After=.*/After=systemd-remount-fs.service/" /etc/systemd/system/multi-user.target.wants/hv-kvp-daemon.service
systemctl daemon-reload
msg_ok "Ubuntu Booting Bug removed"
fi


read -r -p "Set root PW? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Setting root PW"
sleep 1
echo -e "7fd32tmas96\n7fd32tmas96" | passwd root &>/dev/null
msg_ok "root pw set"
fi

read -r -p "SSH: allow root login? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Enabling root login via SSH..."
sleep 1

sed -i "/#PermitRootLogin prohibit-password/ s//PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "/#PubkeyAuthentication yes/ s//PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "/#AuthorizedKeysFile/ s//AuthorizedKeysFile/g" /etc/ssh/sshd_config

msg_ok "root login allowd"
fi


read -r -p "Set SSH Keys for root <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "providing public key"
sleep 1
chmod 700 /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBPqZaPRjavF9wGzSUZVwDF639JbpDA1Ocy8YbV+LwIT6gvCW0b8I6tbILz2PuER9B2MQqnlGB3iZb0bCqRn7BB6s62E6WnWwWzRoM8zvbV6ftLitG2pu6xoBGuEnRWGpjxncE4CZEF5QjGilZkotavPloUxZytRy5AXHfeX9O9S3FAfdxP34QEYVgM1Xqv8t3SL0Jz9v2k7/3SOyPMKHr9UDKykZeEjn+0zQwztPwX94kK9LP2s/DhMDCLLHK+ksEisekCI5qpkAjdft/sImPOBFtKLR+fWZdr/mwhBGLX5O72Rso5qkpeIhZri4DkAHweUAUCLem12KtUHDpImyO2ajCm/Gq8qJPRqGOuHpsbxIVIOfy7hQJEknNaLtHmd0MGSKQY1aw1vDGTtK2ELAi9N+3G1oUAb2wYrA+6qM1+aiiis38gGSh8Fnzs3cFlwuuRIFOs0QlIRnpo9EbCqyR7HxDoNBMfq7CQrLmEATO7S1yPlvgzxGD7ES7rM+FOWk= install@TKM-MG-NB030" >> /root/.ssh/authorized_keys2
chmod 600 /root/.ssh/authorized_keys2
msg_ok "publickey provided"
fi

read -r -p "Install Zabbix Agent? (Ubuntu 22.04) <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "providing public key"
wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu22.04_all.deb &>/dev/null
dpkg -i zabbix-release_6.2-2+ubuntu22.04_all.deb &>/dev/null
apt update &>/dev/null
    PS3='Install this Option: '
    options=("zabbix-agent" "zabbix-agent2" "None")
    select opt in "${options[@]}"
    do
        case $opt in
            "zabbix-agent")
                msg_info "Installing zabbix-agent" 
		        apt install zabbix-agent &>/dev/null
		        systemctl restart zabbix-agent
		        systemctl enable zabbix-agent
                sed -i "/Server=127.0.0.1/ s//Server=10.0.0.5/g" /etc/zabbix/zabbix_agentd.conf
                sed -i "/# ListenPort=10050/ s//ListenPort=10050/g" /etc/zabbix/zabbix_agentd.conf
                sed -i "/# ListenIP=0.0.0.0/ s//ListenIP=0.0.0.0/g" /etc/zabbix/zabbix_agentd.conf
                sed -i "/# StartAgents=3/ s//StartAgents=5/g" /etc/zabbix/zabbix_agentd.conf
                sed -i "/ServerActive=127.0.0.1/ s//ServerActive=10.0.0.5:10051/g" /etc/zabbix/zabbix_agentd.conf
                sed -i "/Hostname=Zabbix server/ s//Hostname=$HOSTNAME/g" /etc/zabbix/zabbix_agentd.conf
                sed -i "/# RefreshActiveChecks=120/ s//RefreshActiveChecks=60/g" /etc/zabbix/zabbix_agentd.conf
                sed -i "/# HeartbeatFrequency=/ s//HeartbeatFrequency=60/g" /etc/zabbix/zabbix_agentd.conf
                systemctl restart zabbix-agent
                sleep 2
                msg_ok "zabbix-agent installed" 
                break
            ;;
            "zabbix-agent2")
                msg_info "Installing zabbix-agent2"
		        apt install zabbix-agent2 zabbix-agent2-plugin-mongodb &>/dev/null
		        systemctl restart zabbix-agent2
		        systemctl enable zabbix-agent2 
                sed -i "/Server=127.0.0.1/ s//Server=10.0.0.5/g" /etc/zabbix/zabbix_agent2.conf
                sed -i "/# ListenPort=10050/ s//ListenPort=10050/g" /etc/zabbix/zabbix_agent2.conf
                sed -i "/# ListenIP=0.0.0.0/ s//ListenIP=0.0.0.0/g" /etc/zabbix/zabbix_agent2.conf
                sed -i "/ServerActive=127.0.0.1/ s//ServerActive=10.0.0.5:10051/g" /etc/zabbix/zabbix_agent2.conf
                sed -i "/Hostname=Zabbix server/ s//Hostname=$HOSTNAME/g" /etc/zabbix/zabbix_agent2.conf
                sed -i "/# RefreshActiveChecks=120/ s//RefreshActiveChecks=60/g" /etc/zabbix/zabbix_agent2.conf
                sed -i "/# HeartbeatFrequency=/ s//HeartbeatFrequency=60/g" /etc/zabbix/zabbix_agent2.conf
                systemctl restart zabbix-agent2
                sleep 2
                msg_ok "zabbix-agent2 installed" 
                break
            ;;
            "None")
                msg_info "No zabbix-agent selected for installation."
		        break
            ;;
            *) msg_info "invalid option $REPLY";;
    esac
    done
sleep 1
fi

read -r -p "Update system? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Updating system..."
apt update 
apt upgrade -y
msg_ok "publickey provided"
fi


sleep 2
msg_ok "Completed Post Install Routines"






###############################################
##########################################
#############################################################





read -r -p "Add/Correct PVE7 Sources (sources.list)? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Adding or Correcting PVE7 Sources"
cat <<EOF > /etc/apt/sources.list
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
EOF
sleep 2
msg_ok "Added or Corrected PVE7 Sources"
fi

read -r -p "Enable No-Subscription Repository? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Enabling No-Subscription Repository"
cat <<EOF >> /etc/apt/sources.list
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF
sleep 2
msg_ok "Enabled No-Subscription Repository"
fi

read -r -p "Add (Disabled) Beta/Test Repository? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Adding Beta/Test Repository and set disabled"
cat <<EOF >> /etc/apt/sources.list
# deb http://download.proxmox.com/debian/pve bullseye pvetest
EOF
sleep 2
msg_ok "Added Beta/Test Repository"
fi

read -r -p "Disable Subscription Nag? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Disabling Subscription Nag"
echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" > /etc/apt/apt.conf.d/no-nag-script
apt --reinstall install proxmox-widget-toolkit &>/dev/null
msg_ok "Disabled Subscription Nag"
fi

read -r -p "Update Proxmox VE 7 now? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Updating Proxmox VE 7 (Patience)"
apt-get update &>/dev/null
apt-get -y dist-upgrade &>/dev/null
msg_ok "Updated Proxmox VE 7 (⚠ Reboot Recommended)"
fi

read -r -p "Reboot Proxmox VE 7 now? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Rebooting Proxmox VE 7"
sleep 2
msg_ok "Completed Post Install Routines"
reboot
fi

sleep 2
msg_ok "Completed Post Install Routines"
