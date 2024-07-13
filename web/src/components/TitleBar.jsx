'use client'
import React from 'react';
import { ethers } from 'ethers';
import { Flex, HStack, Button, Text } from '@chakra-ui/react'

function TitleBar({setSigner, address, setAddress, setSymbol}) {
    const [isConnected, setIsConnected] = React.useState(false);
    const [chainId, setChainId] = React.useState(null);

    React.useEffect(() => {
        // Check if MetaMask is installed
        if (typeof window.ethereum !== 'undefined') {
          // Listen for connect/disconnect events
          window.ethereum.on('accountsChanged', handleAccountsChanged);
          window.ethereum.on('disconnect', handleDisconnect);
          window.ethereum.on('chainChanged', handleChainChanged);

          // Check if already connected
          if (window.ethereum.selectedAddress) {
            setAddress(window.ethereum.selectedAddress);
            setIsConnected(true);
          }
        }
    }, []);

    const getNativeCurrencySymbol = (chainId) => {
        switch (chainId) {
            case 1n:
                return 'ETH';  // Ethereum Mainnet
            case 42161n:
                return 'aETH'; // Arbitrum One Mainnet
            case 8453n:
                return 'bETH'; // Base Mainnet
            case 10n:
                return 'oETH'; // Optimism Mainnet
            case 5000n:
                return 'mETH'; // Mantle Mainnet
            // Add more cases as needed for other networks
            default:
                return 'Native';
        }
    }

    const handleChainChanged = async _chainId => {
        // Handle chain change
        // setChainId(_chainId);
        await handleConnect();
    };

    const handleConnect = async () => {
        try {
            // Request account access
            await window.ethereum.request({ method: 'eth_requestAccounts' });

            // Get the connected address
            const provider = new ethers.BrowserProvider(window.ethereum);
            const signer = await provider.getSigner();
            setSigner(signer);
            const connectedAddress = await signer.getAddress();
            setAddress(connectedAddress);
            const chainId = (await provider.getNetwork()).chainId;
            setChainId(chainId);
            setSymbol(getNativeCurrencySymbol(chainId));
            setIsConnected(true);
        } catch (error) {
            console.error(error);
        }
    };

    const handleDisconnect = () => {
        setAddress(null);
        setIsConnected(false);
        setSigner(null);
        setChainId(null);
    };

    React.useEffect(() => { // When page is started or refreshed
        handleDisconnect(); // Flush prior connection
    }, []);

    const handleAccountsChanged = async accounts => {
        if (accounts.length === 0) {
            handleDisconnect();
        } else {
            //setAddress(accounts[0]);
            //setIsConnected(true);
            await handleConnect();
        }
    };

    return (
        <Flex bg='black' width='100%' justify='space-between' borderRadius='md' shadow='lg' align='center' p={2}>
            <Text fontWeight='bold'>Underwriterless Launchpad</Text>
            <HStack>
                <Text>{address && <span>Address: {address}</span>} { chainId && "Chain Id: " + chainId.toString() }</Text>
                {isConnected ? (
                    <Button colorScheme='purple' size='sm' onClick={handleDisconnect}>Disconnect</Button>
                ) : (
                    <Button  colorScheme='pink' size='sm' onClick={handleConnect}>Connect</Button>
                )}
            </HStack>
        </Flex>
      );
}

export default TitleBar;
