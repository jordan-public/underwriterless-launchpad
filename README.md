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

## One Sided Liquidity Math

We are dealing with concentrated liquidity priced between $P_{low}$ and $P_{high}$. Let the asset $X$ be the launched Token and the asset $Y$ be the base currency in which the token is paid.

The main property of the AMM is fairness:
If two participants $A$ and $B$ have liquidities deployed in the same pool in non-zero amounts $L_A$ and $L_B$ then the amounts of both assets in the are proportional to their liquidity amounts: 
- $x_A / x_B = y_A / y_B = L_A / L_B$ when the price is in the range $(P_{low}, P_{high})$,
- if the price is $P_{low}$ than only the asset X is in the pool, so $y_A = y_B = 0$ and $x_A / x_B = L_A / L_B$,
- if the price is $P_{high}$ than only the asset Y is in the pool, so $x_A = x_B = 0$ and $y_A / y_B = L_A / L_B$.

When liquidity is deployed in our protocol, all of it consists of the asset $X$ (the launched token). The liquidity amount is for some factor $c$ (initially likely $1$, but we are not even going to try to go into the AMM implementation details):

$L_{lpad} = c \cdot \frac{x_{lpad} \cdot \sqrt{P_{low}}}{P_{high} - P_{low}}$

so $c = \frac{L_{lpad}}{x_{lpad}} \cdot \frac{P_{high} - P_{low}}{\sqrt{P_{low}}}$ (1)

We can discover the constant $c$ as soon as we deploy our liquidity.
If anyone buys the token $X$ the price will fall into the range, 
so the liquidity be:


$L_{lpad} = c \cdot \frac{x_{lpad} \cdot \sqrt{P_{current}} \cdot (P_{high} - P_{current})}{P_{high}} = c \cdot \frac{y_{lpad} \cdot \sqrt{P_{current}} \cdot (P_{current} - P_{low})}{P_{low}}$

so 
$c = \frac{L_{lpad}}{x_{lpad}} \cdot \frac{P_{high}}{\sqrt{P_{current}} \cdot (P_{high} - P_{current})}$ (2)

and if the price hits the upper limit of the range (all Tokens are sold):

$
L_{lpad} = c \cdot \frac{y_{lpad} \cdot \sqrt{P_{high}}}{P_{high} - P_{low}}
$

so 

$c = \frac{L_{lpad}}{y_{lpad}} \cdot \frac{P_{high} - P_{low}}{\sqrt{P_{high}}}$ (3)

However, as fees accumulate into the liquidity pool, the factor $c$ decreases, reflecting the 
increase of value of the LP tokens.

## Profit Withdrawal Math

Knowing what part of the total liquidity in the pool at any time belongs to the Launchpad (as others may add and/or withdraw liquidity), we can calculate what part of each token in it belongs to the Launchpad.

- Initially we can calculate the factor $c$ as:
$c_{init} = \frac{L_{lpad}}{x_{lpad}} \cdot \frac{P_{high} - P_{low}}{ \sqrt{P_{low}}}$

- Then upon each withdrawal we update $c$ from the above formulas (1), (2) or (3) depending on the price. Then we can withdraw liquidity $L_{lpad} \cdot \frac{c_{old} - c_{new}}{c_{old}}$ .

## Implementation

### Fee withdrawals

As investors in the Launchpad trade the Token, fees are collected and in the "After Swap" Hook, liquidity is withdrawn according to the Profit Withdrawal Math above. This liquidity is immediately swapped to the base asset. 

We would not want the conversion of the withdrawn liquidity to trigger another recursive liquidity withdrawal, so we need to switch off the functionality of the "After Swap" Hook, convert the withdrawn liquidity to the base asset and then turn the this functionality back on.

### Campaign End

Once the campaign ends, the "Before Swap" Hook should simply revert. At that point, the Launchpad main contract, which may still own liquidity, should withdraw its liquidity and deposit both assets $X$ and $Y$ into the startup's treasury, $X$ as unsold stock and $Y$ as
proceeds from the stock sold. 

In the future, the protocol may be enhanced with ability to revert the entire campaign if certain sales goal is not reached. This could be done by encapsulating each sale as NFT which wraps the stock purchased and record of the sale price, which could be unwrapped at will and sold back at the recorded price minus the fees already collected by the protocol.

