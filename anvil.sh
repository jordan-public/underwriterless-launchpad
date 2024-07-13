#!/bin/zsh
. ./.env

anvil --fork-url $BASE_RPC --mnemonic $MNEMONIC
 