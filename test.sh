#!/bin/zsh
# Run anvil.sh in another shell before running this
set -e

# To load the variables in the .env file
. ./.env

forge test --rpc-url $BASE_RPC -vv
