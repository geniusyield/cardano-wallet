#! /usr/bin/env -S nix shell '.#cardano-wallet' '.#cardano-node' --command bash
# shellcheck shell=bash

set -euo pipefail

usage() {
    echo "Usage: $0 [sync]"
    echo "  sync: Sync the service and wait for it to be ready"
}
# Check if no arguments are provided and display usage if true
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# shellcheck disable=SC1091
source .env

# Generate a random port for the wallet service and export it
RANDOM_PORT=$(shuf -i 2000-65000 -n 1)
WALLET_PORT=${WALLET_PORT:=$RANDOM_PORT}

# Define a local db if WALLET_DB is not set
if [[ -z "${WALLET_DB-}" ]]; then
    LOCAL_WALLET_DB=./databases/wallet-db
    mkdir -p $LOCAL_WALLET_DB
    WALLET_DB=$LOCAL_WALLET_DB
    export WALLET_DB
fi

# Define a local db if NODE_DB is not set
if [[ -z "${NODE_DB-}" ]]; then
    LOCAL_NODE_DB=./databases/node-db
    mkdir -p $LOCAL_NODE_DB
    NODE_DB=$LOCAL_NODE_DB
    export NODE_DB
fi

# Define and export the node socket name
NODE_SOCKET_NAME=node.socket

# Define and export the local and actual directory for the node socket
LOCAL_NODE_SOCKET_DIR=./.
NODE_SOCKET_DIR=${NODE_SOCKET_DIR:=$LOCAL_NODE_SOCKET_DIR}

NODE_SOCKET_PATH=${NODE_SOCKET_DIR}/${NODE_SOCKET_NAME}

# Define and export the local and actual configs directory for the node
LOCAL_NODE_CONFIGS=./configs
NODE_CONFIGS=${NODE_CONFIGS:=$LOCAL_NODE_CONFIGS}


# Define the node logs file
LOCAL_NODE_LOGS_FILE=./node.log
NODE_LOGS_FILE="${NODE_LOGS_FILE:=$LOCAL_NODE_LOGS_FILE}"

# Start the node with logs redirected to a file if NODE_LOGS_FILE is set
# shellcheck disable=SC2086
cardano-node run \
    --topology "${NODE_CONFIGS}"/topology.json \
    --database-path "${NODE_DB}"\
    --socket-path "${NODE_SOCKET_PATH}" \
    --config "${NODE_CONFIGS}"/config.json \
    +RTS -N -A16m -qg -qb -RTS 1>$NODE_LOGS_FILE 2>$NODE_LOGS_FILE &
NODE_ID=$!

# Define the wallet logs file
LOCAL_WALLET_LOGS_FILE=./wallet.log
WALLET_LOGS_FILE="${WALLET_LOGS_FILE:=$LOCAL_WALLET_LOGS_FILE}"

# Start the wallet with logs redirected to a file if WALLET_LOGS_FILE is set
# shellcheck disable=SC2086
cardano-wallet serve \
    --port "${WALLET_PORT}" \
    --database "${WALLET_DB}" \
    --node-socket "${NODE_SOCKET_PATH}" \
    --testnet "${NODE_CONFIGS}"/byron-genesis.json \
    --listen-address 0.0.0.0  1>$WALLET_LOGS_FILE 2>$WALLET_LOGS_FILE &
WALLET_ID=$!


cleanup() {
    echo "Cleaning up..."
    kill "${NODE_ID}" || echo "Failed to kill node"
    kill "${WALLET_ID}" || echo "Failed to kill wallet"
}

# Trap the cleanup function on exit
trap cleanup ERR INT EXIT

# Case statement to handle different command-line arguments
case "$1" in
    sync)
        echo "Wallet service port: $WALLET_PORT"
        echo "Syncing the service..."
        sleep 10

        # Initialize timeout and start time for the sync operation
        timeout=10000
        start_time=$(date +%s)

        # Commands to query service status and node tip time
        command="curl -s localhost:$WALLET_PORT/v2/network/information | jq -r"
        query_status="$command .sync_progress.status"
        query_time="$command .node_tip.time"
        query_progress="$command .sync_progress.progress.quantity"

        SUCCESS_STATUS=${SUCCESS_STATUS:="ready"}
        while true; do
            # Check the sync status
            status=$(cat <(bash -c "$query_status")) || echo "failed"
            if [[ $(date +%s) -ge $((start_time + timeout)) ]]; then
                result="timeout"
                break
            elif [[ "$status" == "$SUCCESS_STATUS" ]]; then
                result="success"
                printf "\n"
                break
            else
                # Display the node tip time as progress
                time=$(cat <(bash -c "$query_time"))
                progress=$(cat <(bash -c "$query_progress"))
                printf "%s%% %s\r" "$progress" "$time"
                sleep 1
            fi
        done

        # Stop the service after syncing
        echo "Result: $result"
        # Exit with 0 on success, 1 on failure or timeout
        if [[ "$result" == "success" ]]; then
            exit 0
        else
            exit 1
        fi
        ;;
    *)
        echo "Error: Invalid option $1"
        usage
        exit 1
        ;;
esac
