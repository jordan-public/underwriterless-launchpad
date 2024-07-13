// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import "./interfaces/ILaunchpad.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IToken.sol";
import "./Token.sol";
import {CLPoolManager} from "@pancakeswap/v4-core/src/pool-cl/CLPoolManager.sol";
import {Vault} from "@pancakeswap/v4-core/src/Vault.sol";
import {Currency} from "@pancakeswap/v4-core/src/types/Currency.sol";
import {SortTokens} from "@pancakeswap/v4-core/test/helpers/SortTokens.sol";
import {PoolKey} from "@pancakeswap/v4-core/src/types/PoolKey.sol";
import {CLSwapRouter} from "@pancakeswap/v4-periphery/src/pool-cl/CLSwapRouter.sol";
import {NonfungiblePositionManager} from "@pancakeswap/v4-periphery/src/pool-cl/NonfungiblePositionManager.sol";
import {INonfungiblePositionManager} from
    "@pancakeswap/v4-periphery/src/pool-cl/interfaces/INonfungiblePositionManager.sol";
import {Constants} from "@pancakeswap/v4-core/test/pool-cl/helpers/Constants.sol";
import {CLPoolParametersHelper} from "@pancakeswap/v4-core/src/pool-cl/libraries/CLPoolParametersHelper.sol";
// import {CLCounterHook} from "../src/pool-cl/CLCounterHook.sol";
// import {CLTestUtils} from "./utils/CLTestUtils.sol";
import {PoolIdLibrary} from "@pancakeswap/v4-core/src/types/PoolId.sol";
import {ICLSwapRouterBase} from "@pancakeswap/v4-periphery/src/pool-cl/interfaces/ICLSwapRouterBase.sol";
import {CLLaunchpadHook} from "./CLLaunchpadHook.sol";
import {TickMath} from "@pancakeswap/v4-core/src/pool-cl/libraries/TickMath.sol";

contract Launchpad is ILaunchpad{
    address public lastToken;
    address public owner;
    IToken public baseToken;
    Vault vault;
    CLPoolManager poolManager;
    NonfungiblePositionManager nfp;
    CLSwapRouter swapRouter;
    using CLPoolParametersHelper for bytes32;

    IToken[] public tokens;
    mapping (address => PoolKey) keys;
    mapping (address => uint128) liquiditiesPerToken;
    mapping (address => uint256) liquidityIdsPerToken;
    mapping (address => address) liquidityOwners;

    constructor(IToken _baseToken) {
        owner = msg.sender;
        baseToken = _baseToken;
    }

    function launchToken(string memory symbol, string memory name, uint160 priceLow, uint160 priceHigh, bool oneWay, uint256 launchAmount, uint256 duration) external returns (address tokenAddress) {
        // Create the token
        IToken token = new Token(symbol, name, launchAmount);
        tokens.push(token);
        tokenAddress = address(token);
        lastToken = tokenAddress; // For convenience

        liquidityOwners[tokenAddress] = msg.sender;

        // Initialize PancakeSwap Pool
        vault = new Vault();
        poolManager = new CLPoolManager(vault, 500000);
        vault.registerApp(address(poolManager));

        nfp = new NonfungiblePositionManager(vault, poolManager, address(0), address(0));
        swapRouter = new CLSwapRouter(vault, poolManager, address(0));

        // Add liquidity
        address[2] memory approvalAddress = [address(nfp), address(swapRouter)];
        for (uint256 i; i < approvalAddress.length; i++) {
            baseToken.approve(approvalAddress[i], type(uint256).max);
            token.approve(approvalAddress[i], type(uint256).max);
        }

        bool order = address(baseToken) < address(token);
        (address a0, address a1) = order ? (address(baseToken), address(token)) : (address(token), address(baseToken));

        (Currency currency0, Currency currency1) = (Currency.wrap(a0), Currency.wrap(a1));

        CLLaunchpadHook hook = new CLLaunchpadHook(poolManager);

        // create the pool key
        PoolKey memory key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            hooks: hook,
            poolManager: poolManager,
            fee: uint24(3000), // 0.3% fee
            // tickSpacing: 10
            parameters: bytes32(uint256(hook.getHooksRegistrationBitmap())).setTickSpacing(10)
        });
        keys[address(token)] = key;

        // initialize pool at 1:1 price point (assume stablecoin pair)
        poolManager.initialize(key, Constants.SQRT_RATIO_1_1, new bytes(0));

        // Convert prices from uint160 to int24 (SqrtPriceX96 to tick)
        int24 tickLower = TickMath.getTickAtSqrtRatio(priceLow);
        int24 tickUpper = TickMath.getTickAtSqrtRatio(priceHigh);

        // Add liquidity
        INonfungiblePositionManager.MintParams memory mintParams = INonfungiblePositionManager.MintParams({
            poolKey: key,
            tickLower: order ? tickLower : tickUpper,
            tickUpper: order ? tickUpper : tickLower,
            salt: bytes32(0),
            amount0Desired: order ? launchAmount : 0,
            amount1Desired: order ? 0 : launchAmount,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        (liquidityIdsPerToken[address(token)], liquiditiesPerToken[address(token)], , ) = nfp.mint(mintParams);
    }

    function buy(address tokenAddress, uint128 amount) external {
        trade(tokenAddress, amount, true);
    }
        
    function sell(address tokenAddress, uint128 amount) external {
        trade(tokenAddress, amount, true);
    }

    function trade(address tokenAddress, uint128 amount, bool isBuy) internal {
        bool order = address(baseToken) < tokenAddress;

        ICLSwapRouterBase.V4CLExactInputSingleParams memory params = ICLSwapRouterBase
        .V4CLExactInputSingleParams({
            poolKey: keys[tokenAddress],
            zeroForOne: isBuy ? !order : order,
            recipient: msg.sender,
            amountIn: amount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0,
            hookData: new bytes(0)
        });
        
        /* uint256 amtOut = */ swapRouter.exactInputSingle(params, block.timestamp); 
    }

    function finishCampaign(address tokenAddress) external {
        uint256 balanceTokenBefore = IToken(tokenAddress).balanceOf(address(this));
        uint256 balanceBaseBefore = baseToken.balanceOf(tokenAddress);
        // Approve LP withdrawal
        // Not needed according to Chef

        // Withdraw LP
        nfp.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: liquidityIdsPerToken[tokenAddress],
                liquidity: liquiditiesPerToken[tokenAddress],
                amount0Min: 0,
                amount1Min: 0,
                deadline: type(uint256).max
            })
        );
        

        // Send the assets to owner
        uint256 toSendToken = IToken(tokenAddress).balanceOf(address(this)) - balanceTokenBefore;
        uint256 toSendBase = baseToken.balanceOf(address(this)) - balanceBaseBefore;
        IToken(tokenAddress).transfer(liquidityOwners[tokenAddress], toSendToken);
        // Send both assets to liquidityOwners[atokenAddress]
        baseToken.transfer(liquidityOwners[tokenAddress], toSendBase);

        // Destroy the LP
        // No need - there may be someone else holding this LP: nfp.burn(liquidityIdsPerToken[adress(token)]);
    }
}
