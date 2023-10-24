# db-base-freeswitch
## FreeSwitch based on postgres db.
It has been tested on ubuntu 20.04

1- create virtual machin (copy template to vm in vmware vcenter)

* ansible-playbook playbook_iac.yml --ask-vault-pass 

2- create sysops user in remote machine for ansible

* ansible-playbook playbook_adduser.yml -u remoteuser --ask-become-pass -k

3- Installation and configuration of postgres 

* ansible-playbook ansi_playbook.yml -t pre-task

* ansible-playbook ansi_playbook.yml --ask-vault-pass -t psql

4- Installation and configuration of FreeSwitch

4-1- configuration of FreeSwitch to read user information from database (a LUA script has been written to do it)

4-2- configuration of FreeSwitch to write calls information(calls, channels, CDRs, Registrations, ...) and users status to database

4-3- configuration of conditional call forwarding (a python app hass been written to do it)

* ansible-playbook ansi_playbook.yml -t fs-pre

* ansible-playbook ansi_playbook.yml -t fs-config

5- schedule a database daily backup

* ansible-playbook ansi_playbook.yml -t backup

6- configuration of daily rotate log with one week retention for psql and freeswitch

* ansible-playbook ansi_playbook.yml -t fs-logset

7- configuration of ubuntu firewall to block out access to unused ports on the VM and have limitation on ssh port

* ansible-playbook ansi_playbook.yml -t ufw


---

These numbers are created in database:
1020,1021,1022,1023

when 1022 or 1023 is not registered then call to that number will forward to 1021

---

built-in web page has been enabled and it is possible to monitor the calls from below link:

http://x.x.x.x:8080/portal/index.html#

user:freeswitch

pass:works
