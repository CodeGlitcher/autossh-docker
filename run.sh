#!/bin/bash
set -e
echo "starting"
CONFIG_PATH=/data/config.json

if [ ! -f "$CONFIG_PATH" ]; then
    echo "missing config data"
    echo "creating empty config.json"
    cp /example/config-example.json /data/config.json
    exit 1
fi

HOSTNAME=$(jq --raw-output ".hostname" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)


REMOTE_FORWARDING=$(jq --raw-output ".remote_forwarding[]" $CONFIG_PATH)
LOCAL_FORWARDING=$(jq --raw-output ".local_forwarding[]" $CONFIG_PATH)

OTHER_SSH_OPTIONS=$(jq --raw-output ".other_ssh_options" $CONFIG_PATH)
MONITOR_PORT=$(jq --raw-output ".monitor_port" $CONFIG_PATH)
PRIVATE_KEY=$(jq --raw-output ".private_key" $CONFIG_PATH)

if [ ! -f "$PRIVATE_KEY" ]; then
    echo "missing private key"
    exit 1
fi

echo "[INFO] public key is:"
cat "${PRIVATE_KEY}"

command_args="-M ${MONITOR_PORT} -N -q -o ServerAliveInterval=25 -o ServerAliveCountMax=3 ${USERNAME}@${HOSTNAME} -p ${SSH_PORT} -i ${PRIVATE_KEY}"

if [ ! -z "$REMOTE_FORWARDING" ]; then
  while read -r line; do
    command_args="${command_args} -R $line"
  done <<< "$REMOTE_FORWARDING"
fi


if [ ! -z "$LOCAL_FORWARDING" ]; then
  while read -r line; do
    command_args="${command_args} -L $line"
  done <<< "$LOCAL_FORWARDING"
fi

echo "[INFO] testing ssh connection"
ssh -o StrictHostKeyChecking=no -p $SSH_PORT $HOSTNAME 2>/dev/null || true

echo "[INFO] listing host keys"
ssh-keyscan -p $SSH_PORT $HOSTNAME || true

command_args="${command_args} ${OTHER_SSH_OPTIONS}"

echo "[INFO] command args: ${command_args}"
# start autossh
/usr/bin/autossh ${command_args}