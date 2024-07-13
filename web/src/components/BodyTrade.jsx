'use client'
import React from 'react';
import { Heading, FormControl, FormLabel, Select, Textarea, Text, VStack, HStack, Input, Button, Box } from '@chakra-ui/react';
import { ethers } from 'ethers';
import aLaunchpad from '../artifacts/Launchpad.json';
import OnChainContext from './OnChainContext';
import {bigIntToDecimal, decimalToBigInt} from '../utils/decimal';

function BodyTrade({ signer, address, nativeSymbol }) {
    const [onChainInfo, setOnChainInfo] = React.useState({})
    const [token, setToken] = React.useState('')
    const [amount, setAmount] = React.useState(0n)

    React.useEffect(() => {
        if (!signer) return;
        (async () => {
            const cLaunchpad = new ethers.Contract(aLaunchpad.contractAddress, aLaunchpad.abi, signer);
            setOnChainInfo({signer: signer, address: address, cLaunchpad: cLaunchpad });
        }) ();
    }, [signer, address]);

    const onBuy = async () => {
        try{
            const tx = await onChainInfo.cLaunchpad.buy(token, amount, { gasLimit: ethers.parseUnits('10000000', 'wei') });
            const r = await tx.wait()
            window.alert('Completed. Block hash: ' + r.blockHash);
        } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""))
        }
    }

    const onSell = async () => {
        try{
            const tx = await onChainInfo.cLaunchpad.sell(token, amount, { gasLimit: ethers.parseUnits('10000000', 'wei') });
            const r = await tx.wait()
            window.alert('Completed. Block hash: ' + r.blockHash);
        } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""))
        }
    }

    if (!signer) return(<><br/>Please connect!</>)
    if (!onChainInfo.cLaunchpad) return("Please wait...")
    return (<OnChainContext.Provider value={onChainInfo} >
        <VStack width='50%' p={4} align='center' borderRadius='md' shadow='lg' bg='black'>
            <Heading as="h3" size="md">Trade Launched Token</Heading>
            <FormControl>
                <FormLabel>Token Address</FormLabel>
                <Input value={token} onChange={e => setToken(e.target.value)} />
            </FormControl>
            <FormControl>
                <FormLabel>Amount</FormLabel>
                <Input value={bigIntToDecimal(amount).toString()} onChange={e => setAmount(decimalToBigInt(e.target.value))} type='number' />
            </FormControl>
            <HStack>
                <Button color='black' bg='green' size='lg' onClick={onBuy}>Buy</Button>
                <Button color='black' bg='red' size='lg' onClick={onSell}>Sell</Button>
            </HStack>
        </VStack>
    </OnChainContext.Provider>);
}

export default BodyTrade;