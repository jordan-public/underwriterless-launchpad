'use client'
import React from 'react';
import { Heading, FormControl, FormLabel, Select, Textarea, Text, VStack, HStack, Input, Button, Box } from '@chakra-ui/react';
import { ethers } from 'ethers';
//import aLaunchpad from '../artifacts/Launchpad.json';
import OnChainContext from './OnChainContext';
import {bigIntToDecimal, decimalToBigInt} from '../utils/decimal';

function BodyTrade({ signer, address, nativeSymbol }) {
    const [onChainInfo, setOnChainInfo] = React.useState({})
    const [amount, setAmount] = React.useState(0n)

    React.useEffect(() => {
        if (!signer) return;
        (async () => {
            let contractAddress = 0;
            switch ((await signer.provider.getNetwork()).chainId) {
                case 1n: contractAddress = "0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB"; // Ethereum
                break;
                case 42161n: contractAddress = "0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB"; // Arbitrum One
                break;
                case 8453n: contractAddress = "0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB"; // Base
                break;
                case 5000n: contractAddress = "0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB"; // Mantle
                break;
                case 10n: contractAddress = "0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB"; // Optimism
                break;
            }
            // const cLaunchpad = new ethers.Contract(contractAddress, aLaunchpad.abi, signer);
            // setOnChainInfo({signer: signer, address: address, cLaunchpad: cLaunchpad });
        }) ();
    }, [signer, address]);

    const onLaunch = async () => {
        try{
            const tx = await onChainInfo.cLaunchpad.launchToken(priceLow, priceHigh, { gasLimit: ethers.parseUnits('10000000', 'wei') });
            const r = await tx.wait()
            window.alert('Completed. Block hash: ' + r.blockHash);
        } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""))
        }
    }

    if (!signer) return(<><br/>Please connect!</>)
    //if (!onChainInfo.cLaunchpad) return("Please wait...")
    return (<OnChainContext.Provider value={onChainInfo} >
        <VStack width='50%' p={4} align='center' borderRadius='md' shadow='lg' bg='black'>
            <Heading as="h3" size="md">Trade Launched Token</Heading>
            <FormControl>
                <FormLabel>Token Price Range ({nativeSymbol})</FormLabel>
                <Input value={bigIntToDecimal(amount).toString()} onChange={e => setAmount(decimalToBigInt(e.target.value))} type='number' />
            </FormControl>
            <Button color='black' bg='green' size='lg' onClick={onLaunch}>Buy</Button>
            <Button color='black' bg='red' size='lg' onClick={onLaunch}>Sell</Button>
        </VStack>
    </OnChainContext.Provider>);
}

export default BodyTrade;