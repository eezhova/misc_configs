#!/bin/bash

# Add default key for admin and demo
nova keypair-add --pub_key=/opt/stack/.ssh/id_rsa.pub stack-ssh

# Enable ping and ssh
for i in admin demo
do
    nova --os-project-name $i secgroup-add-rule default tcp 22 22 0.0.0.0/0
    nova --os-project-name $i secgroup-add-rule default icmp -1 -1 0.0.0.0/0
done

# Add host nameserver to provider_net
ns=`grep nameserver /etc/resolv.conf | head -n1 | awk '{print $2}'`
neutron --os-project-name demo subnet-update --dns-nameserver $ns provider_net

# Create 3 VF ports
for i in `seq 1 3`
do
    neutron --os-project-name demo port-create physnet1 \
            --vnic-type direct --name physnet1-vf$i
done

