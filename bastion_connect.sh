#!/bin/bash

info_file=test/bastion_info.txt

eks_name=$1
bastion_dns=$(grep -e "bastion_dns" $info_file|awk -F "=" '{print $2}')
bastion_cidr=$(grep -e "bastion_cidr" $info_file|awk -F "=" '{print $2}')
bastion_region=$(grep -e "bastion_region" $info_file|awk -F "=" '{print $2}')
bastion_pass=$(grep -e "bastion_pass" $info_file|awk -F "=" '{print $2}')

sshuttle --dns -vr ec2-user@$bastion_dns $bastion_cidr --ssh-cmd 'ssh -p "${bastion_pass}"'