#!/bin/bash

# User variables
sender="Veeam-Backup"                       # Display name of sender
recipient=""                                # Mail address of the recipient

# Check for root privileges
if [[ "$EUID" -ne 0 ]]
then
    echo "[ERROR] Script has to be run as root user in order to call veeam client"
    exit 1
fi

# Check for veeamconfig
if ! [[ -x "$(command -v veeamconfig)" ]]
then
    echo "[ERROR] Command 'veeamconfig' was not found. Please check if veeam client is correctly installed"
    exit 2
fi

# Check for mailx
if ! [[ -x "$(command -v mailx)" ]]
then
    echo "[ERROR] Command 'mailx' was not found. Please check if mailx is correctly installed"
    exit 2
fi

lastBackup=$(veeamconfig session list | sed -n 'x;$p')
lastBackupID=$(echo $lastBackup | cut -d' ' -f3)
lastBackupState=$(echo $lastBackup | cut -d' ' -f4)
lastBackupStart=$(echo $lastBackup | cut -d' ' -f5,6)
lastBackupEnd=$(echo $lastBackup | cut -d' ' -f7,8)
lastBackupLog=$(veeamconfig session log --id $lastBackupID)

subject="Backup with id '${lastBackupID}' ended with state ${lastBackupState^^}"

message=$(cat << EOL
Status: ${lastBackupState^^}
Start:  ${lastBackupStart}
End:    ${lastBackupEnd}

Log:
=====
${lastBackupLog}
EOL
)

echo "$message" | mailx -r $sender -a "From: ${sender}" -s "$subject" $recipient