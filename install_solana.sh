#!/bin/bash

# Update and install necessary packages
sudo apt-get update && sudo apt-get install -y curl libssl-dev libudev-dev pkg-config jq

# Download and install 'STABLE' solana
echo "Installing Stable Solana"
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

# Ensure solana command is available
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# Configure Solana CLI to use Testnet
solana config set --url testnet

# Create a new keypair for your validator (if you don't already have one)
if [ ! -f ~/validator-keypair.json ]; then
    echo "Generating a new validator keypair..."
    solana-keygen new --outfile ~/validator-keypair.json
    # Set the keypair as the default
    solana config set --keypair ~/validator-keypair.json
fi

# Create a vote account for your validator
if [ ! -f ~/validator-vote-account-keypair.json ]; then
    echo "Creating a vote account for the validator..."
    solana-keygen new --outfile ~/validator-vote-account-keypair.json
    solana create-vote-account ~/validator-vote-account-keypair.json ~/validator-keypair.json --commission 100
fi

# Download the Solana Testnet genesis
echo "Downloading the Solana Testnet genesis..."
solana-genesis fetch --output-dir ~/solana-testnet

# Start the validator
echo "Starting the Solana validator..."
solana-validator \
    --identity ~/validator-keypair.json \
    --vote-account ~/validator-vote-account-keypair.json \
    --ledger ~/solana-testnet \
    --entrypoint testnet.solana.com:8001 \
    --limit-ledger-size \
    --log -

echo "Solana validator is now running."
