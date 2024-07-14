'use client'
import React from 'react';
import { Heading, FormControl, FormLabel, Select, Textarea, Text, VStack, HStack, Input, Button, Box, Checkbox } from '@chakra-ui/react';
import { ethers } from 'ethers';
import aLaunchpad from '../artifacts/Launchpad.json';
import OnChainContext from './OnChainContext';
import {bigIntToDecimal, decimalToBigInt} from '../utils/decimal';

function multiplyFloatByBigInt(floatNumber, bigIntMultiplier) {
    const [integerPart, fractionalPart] = floatNumber.toString().split('.');
  
    // Convert integer part to BigInt
    const integerPartBigInt = BigInt(integerPart);
  
    // Calculate the fractional part as BigInt
    const fractionalMultiplier = BigInt(10 ** fractionalPart.length);
    const fractionalPartBigInt = BigInt(fractionalPart) * bigIntMultiplier / fractionalMultiplier;
  
    // Multiply integer part by bigIntMultiplier
    const integerResult = integerPartBigInt * bigIntMultiplier;
  
    // Sum the integer and fractional results
    const result = integerResult + fractionalPartBigInt;
  
    return result;
}

  function BodyCampaign({ signer, address, nativeSymbol }) {
    const [onChainInfo, setOnChainInfo] = React.useState({})
    const [priceLow, setPriceLow] = React.useState(1.0)
    const [priceHigh, setPriceHigh] = React.useState(1.1)
    const [oneWay, setOneWay] = React.useState(false)
    const [symbol, setSymbol] = React.useState('')
    const [name, setName] = React.useState('')
    const [launchAmount, setLaunchAmount] = React.useState(0n)
    const [duration, setDuration] = React.useState(30)
    const [token, setToken] = React.useState('')
    const [tokenAddressToFinish, setTokenAddressToFinish] = React.useState('')

    React.useEffect(() => {
        if (!signer) return;
        (async () => {
            const cLaunchpad = new ethers.Contract(aLaunchpad.contractAddress, aLaunchpad.abi, signer);
            setOnChainInfo({signer: signer, address: address, cLaunchpad: cLaunchpad });
        }) ();
    }, [signer, address]);

    const onLaunch = async () => {
        try{
            const pLow = multiplyFloatByBigInt(Math.sqrt(parseFloat(priceLow)), 2n**96n);
            const pHigh = multiplyFloatByBigInt(Math.sqrt(parseFloat(priceHigh)), 2n**96n);
            const tx = await onChainInfo.cLaunchpad.launchToken(symbol, name, pLow, pHigh, oneWay, launchAmount, BigInt(duration) * 24n * 60n * 60n, { gasLimit: ethers.parseUnits('10000000', 'wei') });
            const r = await tx.wait()
            window.alert('Completed. Block hash: ' + r.blockHash);
            const tokenAddress = await onChainInfo.cLaunchpad.lastToken();
            setToken(tokenAddress); // !!! Not safe - others may create tokens in the meantime
        } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""))
        }
    }

    const onFinish = async () => {
        try{
            const pLow = multiplyFloatByBigInt(Math.sqrt(parseFloat(priceLow)), 2n**96n);
            const pHigh = multiplyFloatByBigInt(Math.sqrt(parseFloat(priceHigh)), 2n**96n);
            const tx = await onChainInfo.cLaunchpad.launchToken(symbol, name, pLow, pHigh, oneWay, launchAmount, BigInt(duration) * 24n * 60n * 60n, { gasLimit: ethers.parseUnits('10000000', 'wei') });
            const r = await tx.wait()
            window.alert('Completed. Block hash: ' + r.blockHash);
            const tokenAddress = await onChainInfo.cLaunchpad.lastToken();
            setToken(tokenAddress); // !!! Not safe - others may create tokens in the meantime
        } catch(e) {
            window.alert(e.message + "\n" + (e.data?e.data.message:""))
        }
    }

    if (!signer) return(<><br/>Please connect!</>)
    if (!onChainInfo.cLaunchpad) return("Please wait...")
    return (<OnChainContext.Provider value={onChainInfo} >
        <VStack width='70%' p={4} align='center' borderRadius='md' shadow='lg' bg='black'>
            <Heading as="h3" size="md">Price Range for Launched Token</Heading>
            <FormControl>
                <FormLabel>Token Symbol</FormLabel>
                <Input value={symbol} onChange={e => setSymbol(e.target.value)} />
            </FormControl>
            <FormControl>
                <FormLabel>Token Name</FormLabel>
                <Input value={name} onChange={e => setName(e.target.value)} />
            </FormControl>
            <FormControl>
                <FormLabel>Launch Amount</FormLabel>
                <Input value={bigIntToDecimal(launchAmount).toString()} onChange={e => setLaunchAmount(decimalToBigInt(e.target.value))} type='number' />
            </FormControl>
            <FormControl>
                <FormLabel>Token Price Range ({nativeSymbol})</FormLabel>
                <Input value={priceLow} onChange={e => setPriceLow(e.target.value)} type='number' />
                <br/> <br/>
                <Input value={priceHigh} onChange={e => setPriceHigh(e.target.value)} type='number' />
                <br/> <br/>
                <Checkbox isChecked={oneWay} onChange={(e) => setOneWay(e.target.checked)}>One Way</Checkbox>  
            </FormControl>
            <FormControl>
                <FormLabel>Campaign Duration (days)</FormLabel>
                <Input value={duration} onChange={e => setDuration(e.target.value)} type='number'/>
            </FormControl>
            <Button color='black' bg='red' size='lg' onClick={onLaunch}>Launch</Button>
        </VStack>
        <Text>Last Token Address: {token}</Text>
        <VStack width='70%' p={4} align='center' borderRadius='md' shadow='lg' bg='black'>
            <FormControl>
                <FormLabel>Token Address</FormLabel>
                <Input value={tokenAddressToFinish} onChange={e => setTokenAddressToFinish(e.target.value)} />
            </FormControl>
            <Button color='black' bg='red' size='lg' onClick={onFinish}>Finish Campaign</Button>
        </VStack>
    </OnChainContext.Provider>);
}

export default BodyCampaign;