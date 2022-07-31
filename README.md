# db-base-freeswitch
FreeSwitch based on postgres db.


1- create virtual machin (copy template to vm in vmware vcenter)

ansible-playbook playbook_iac.yml --ask-vault-pass 

2- create sysops user in remote machine for ansible

ansible-playbook playbook_adduser.yml -u remoteuser --ask-become-pass -k

3- Installation and configuration of postgres 

ansible-playbook ansi_playbook.yml -t pre-task
ansible-playbook ansi_playbook.yml --ask-vault-pass -t psql

4- Installation and configuration of FreeSwitch

ansible-playbook ansi_playbook.yml -t fs-pre
ansible-playbook ansi_playbook.yml -t fs-config

4-1- configuration of FreeSwitch to read user information from database (a LUA script has been written to do it)

4-2- configuration of FreeSwitch to write calls information(calls, channels, CDRs, Registrations, ...) and users status to database

4-3- configuration of conditional call forwarding (a python app hass been written to do it)

5- schedule a database daily backup

6- configuration of daily rotate log with one week retention for psql and freeswitch

ansible-playbook ansi_playbook.yml -t fs-logset

7- configuration of ubuntu firewall to block out access to unused ports on the VM and have limitation on ssh port

ansible-playbook ansi_playbook.yml -t ufw
