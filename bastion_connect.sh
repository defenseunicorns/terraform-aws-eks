#!/bin/bash
# Script to run from a test setup to connect to the bastion and allow Terraform and helm to setup the cluster

info_file=test/bastion_info.txt

eks_name=$1
bastion_id=$(grep -e "bastion_id" $info_file|awk -F "=" '{print $2}')
bastion_dns=$(grep -e "bastion_dns" $info_file|awk -F "=" '{print $2}')
bastion_cidr=$(grep -e "bastion_cidr" $info_file|awk -F "=" '{print $2}')
bastion_region=$(grep -e "bastion_region" $info_file|awk -F "=" '{print $2}')
bastion_pass=$(grep -e "bastion_pass" $info_file|awk -F "=" '{print $2}')

# sshuttle --dns -vr ec2-user@$bastion_dns $bastion_cidr --ssh-cmd 'ssh -p "${bastion_pass}"'

sshuttle -D -e '"'"'sshpass -p "${bastion_pass}" ssh -q -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="aws ssm --region ${bastion_region} start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"'"'"' --dns --disable-ipv6 -vr ec2-user@${bastion_id} ${bastion_cidr} &

sleep 5

aws eks update-kubeconfig --name $eks_name --region $bastion_region