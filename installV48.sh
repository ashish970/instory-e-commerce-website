#!/bin/bash
# Bash Menu Script Example
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  echo "Run command => sudo su"
  exit
fi

if ! which wget > /dev/null; then
   echo -n "Command not found! Install? (y/n)"
   read
   if [[ $REPLY =~ ^[Yy]$ ]]
   then
      yum -y install wget 
   else 
      echo "install wget manually and proceed with installation."
	 exit
   fi
fi
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_MB=$(expr $RAM_KB / 1024)
if ((RAM_MB >= 1 && RAM_MB <= 1535)); then
echo "Ovipanel needed 1536 MB RAM minimum."
exit
fi
if free | awk '/^Swap:/ {exit !$2}'; then
    echo "Have swap"
else

                RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
                RAM_MB=$(expr $RAM_KB / 1024)
                #echo $RAM_MB
                swapsize=2048
                if ((RAM_MB >= 1 && RAM_MB <= 2048)); then
                 swapsize=$(expr $RAM_MB \* 2)
                elif ((RAM_MB >= 2049 && RAM_MB <= 8192)); then
                 swapsize=$RAM_MB
                elif ((RAM_MB >= 8193)); then
                 swapsize=8192
                fi

        echo "No swap memory in your server."
        echo "Are you really sure that you want to create $swapsize MB swap memory ?"
        read -e -p "(y):Accept and create, (n):Quit installer? " yn
        case $yn in
        [Yy]* )
                grep -q "swap" /etc/fstab
                # if not then create it
                if [ $? -ne 0 ]; then
                        echo 'swapfile not found. Adding swapfile.'
                        fallocate -l ${swapsize}M /swapfile
						dd if=/dev/zero of=/swapfile count=${swapsize} bs=1MiB
                        chmod 600 /swapfile
                        mkswap /swapfile
                        swapon /swapfile
                        echo '/swapfile none swap defaults 0 0' >> /etc/fstab
						echo "swap file updating. system will boot within a minutes"
                else
                        echo 'swapfile found. No changes made.'
                fi
                 break;;
                [Nn]* ) exit;;
                [Qq]* ) exit;;
                *) exit;;
                esac
# output results to terminal
cat /proc/swaps
cat /proc/meminfo | grep Swap

fi

# Ensure the OS is compatible with the launcher
if [ -f /etc/centos-release ]; then
    OSNAME="CentOs"
    OSVERSION_FULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)
    VERSION=${OSVERSION_FULL:0:1} # return 6 or 7
elif [ -f /etc/lsb-release ]; then
    OSNAME=$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')
    VERSION=$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')
else
    OSNAME=$(uname -s)
    VERSION=$(uname -r)
fi
INFR=$(uname -m)

echo "Get Server Datials : $OSNAME  $VERSION"

if [[ "$OSNAME" = "CentOs" && ("$VERSION" = "6" || "$VERSION" = "7"  || "$VERSION" = "8" || "$VERSION" = "9" ) ]] ; then
        echo "Ok."
else
    echo "Sorry, this OS is not supported by OVIPANEL." 
    exit 1
fi


PS3='Please choose the language: '
options=("English (en)" "Deutsch (de)" "Español (es)" "Français (fr)" "Italiano (it)" "Português (pt)" "عربى (ar)" "Türkçe (tr)")
select opt in "${options[@]}"
do
    case $opt in
	    "English (en)")
		    echo "you choose English (en)"
	    wget -O installV48_en.sh d.ovipanel.in/installV48_en.sh
	    sudo bash installV48_en.sh
	    break
            ;;
    "Deutsch (de)")
		 echo "you choose Deutsch (de)"
	    wget -O installV48_de.sh d.ovipanel.in/installV48_de.sh
            sudo bash installV48_de.sh
	    break
            ;;
    "Español (es)")
		 echo "you choose Español (es)"
	    wget -O installV48_es.sh d.ovipanel.in/installV48_es.sh
            sudo bash installV48_es.sh
	    break
            ;;
    "Français (fr)")
	    echo "you choose Français (fr)"
	    wget -O installV48_fr.sh d.ovipanel.in/installV48_fr.sh
            sudo bash installV48_fr.sh
	    break
            ;;
    "Italiano (it)")
	    echo "you choose Italiano (it)"
	    wget -O installV48_it.sh d.ovipanel.in/installV48_it.sh
            sudo bash installV48_it.sh
	    break
            ;;
    "Português (pt)")
		 echo "you choose Português (pt)"
	    wget -O installV48_pt.sh d.ovipanel.in/installV48_pt.sh
            sudo bash installV48_pt.sh
	    break
            ;;
    "عربى (ar)")
		 echo "you choose عربى (ar)"
	    wget -O installV48_ar.sh d.ovipanel.in/installV48_ar.sh
            sudo bash installV48_ar.sh
	    break
            ;;
    "Türkçe (tr)")
	    echo "you choose Türkçe (tr)"
	    wget -O installV48_tr.sh d.ovipanel.in/installV48_tr.sh
            sudo bash installV48_tr.sh
	    break
            ;;

        *) echo "invalid option $REPLY";;
    esac
done
