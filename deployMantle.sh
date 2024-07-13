#!/bin/sh
set -e

# To load the variables in the .env file
. ./.env

# To deploy and verify our contract
forge script script/DeployAnywhere.s.sol:Deploy --rpc-url $MANTLE_RPC --sender $SENDER --private-key $PRIVATE_KEY --broadcast -v

./push_artifacts.sh "DeployAnywhere.s.sol/5000"

# cd web
# pnpm build