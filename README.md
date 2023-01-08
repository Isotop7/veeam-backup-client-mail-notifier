# veeam-backup-client-mail-notifier

## How does it work?

This small scripts gets the status of the last backup and sends the information via mail to the recipient.

In order to function properly, you need to have elevated permissions, the `veeam` client and `mailx`

On Ubuntu 20.04. you can install mailx via `apt`

```bash
sudo apt install mailutils
```

You need to configure a local mta to relay the mail. For `mailcow-dockerized` deployment with local postfix you can use this guide:
[mailcow-dockerized Local MTA](https://docs.mailcow.email/post_installation/firststeps-local_mta/)

The IP address for the `postfix` container in `mailcow-dockerized` can be different than in these docs. You can get it with the following command:

```bash
networkId=$(sudo docker network ls | grep mailcowdockerized | cut -f1 -d' ')
sudo docker network inspect $networkId --format '{{ .IPAM.Config }}'
```

The second command will output the v4 and v6 addresses of the network:
```bash
[{172.25.1.0/24   map[]} {fd4d:6169:6c63:6f77::/64   map[]}]
```

Use the IPv4 entry, replace the last zero with a one and use this address in the `postconf` command:

```bash
# 172.25.1.0/24 -> 172.25.1.1
sudo  postconf -e 'relayhost = 172.25.1.1'
```

Before using the script, please adjust the variables `sender` and `recipient` to your needs.

## Why does it use an initial delay?

In order to wait for other post-backup tasks to settle, we just wait a few seconds to not return RUNNING states.

## What does it need?

- `mailx` (from mailutils)
- Veeam Backup Client
- Local MTA for sending mail