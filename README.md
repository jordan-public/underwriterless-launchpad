# underwriterless-launchpad
Fund your startup without an underwriter

## Abstract
Startups have to approach Launchpad organizations which provide Underwriters for their initial liquidity of Tokens. No more - Underwriterless Launchped allows anyone to start a funcing campaign without an underwriter.

## Problem
The investors are suspicious of Initial Coin Offerings (ICOs) where the supply controls do not exist. They don't want to be "rug pulled" after investing by a rogue or fake "founder". Thus, Launchpads have emerged. The Launchpad controls the distribution and supply of the tokens. In addition, they underwrite the initial liquidity, and deploy it in an AMM usually as an TOKEN/ETH or  TOKEN/USDC pair, that can be traded. This liquidity requires sizable asset commitment on the side of the underwriter. With our Underwriterless Launchpad, there is no need for this, and yet every participant can be kept honest.

## Solution

Shortly: we use Uniswap V4 or Pancakeswap V4 one-sided liquidity to avoid underwriter's commitment of hard assets. 

The supply of TOKENS that embody the stock of the startup is divided between Team, Treasury and Offering parts. The team tokens are Vested for a period of time, which assures that a "rogue" founder cannot "rug pull" the tokens from the AMM. The Treasury tokens can be transferred to a DAO, to be controlled by the Trustees. Finally, the Offering tokens are deployed as one-sided liquidity in V4 AMM. This means the a Concentrated Liquidity position is created with a range specified by the offering documents. Liquidity is provided at the lower edge of the Token price range, so only Token asset is supplied and no base asset. In addition the campaign timing is controlled by a "Before Swap" Hook, so when it ends, no swapping can continue. In addition, the liquidity can optionally be limited  to buying-only.

So how does this protocol make money? From the trading fees collected by the Liquidity Pool. Each time the pool collects the dfee, an "After Swap" Hook calculates how much liquidity can be withdrawn and converted to base currency. This profit is distributed to the protocol as profit.