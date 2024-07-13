#!/bin/sh
# Usage: ./push_artifacts.sh <chain_id>
set -e

rm -f web/src/artifacts/*.json

# Ignore errors
for dirname in out/*.sol; do
    cat $dirname/$(basename "$dirname" .sol).json | jq '{abi: .abi}' > web/src/artifacts/$(basename "$dirname" .sol).json
done

cat broadcast/$1/run-latest.json out/Launchpad.sol/Launchpad.json | \
jq -s \
    'add | 
    { chain: .chain} * (.transactions[] |
    { transactionType, contractName, contractAddress } |
    select(.transactionType == "CREATE" and .contractName == "Launchpad") |
    {contractName, contractAddress}) * {abi: .abi}' > web/src/artifacts/Launchpad.json
