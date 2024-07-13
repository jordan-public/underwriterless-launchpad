// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoolKey} from "@pancakeswap/v4-core/src/types/PoolKey.sol";
import {CLPoolManager} from "@pancakeswap/v4-core/src/pool-cl/CLPoolManager.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@pancakeswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@pancakeswap/v4-core/src/types/BeforeSwapDelta.sol";
import {PoolId, PoolIdLibrary} from "@pancakeswap/v4-core/src/types/PoolId.sol";
import {ICLPoolManager} from "@pancakeswap/v4-core/src/pool-cl/interfaces/ICLPoolManager.sol";
import {CLBaseHook} from "./CLBaseHook.sol";
import {NonfungiblePositionManager} from "@pancakeswap/v4-periphery/src/pool-cl/NonfungiblePositionManager.sol";
import {INonfungiblePositionManager} from
    "@pancakeswap/v4-periphery/src/pool-cl/interfaces/INonfungiblePositionManager.sol";
import {Vault} from "@pancakeswap/v4-core/src/Vault.sol";
import "./interfaces/ILaunchpad.sol";

/// @notice CLLaunchpadHook is a contract that counts the number of times a hook is called
/// @dev note the code is not production ready, it is only to share how a hook looks like
contract CLLaunchpadHook is CLBaseHook {
    using PoolIdLibrary for PoolKey;
    NonfungiblePositionManager nfp;
    uint256 tokenId;
    address owner;
    uint256 end;
    bool oneWay;
    bool isToken0NonBase;

    mapping(PoolId => uint256 count) public beforeAddLiquidityCount;
    mapping(PoolId => uint256 count) public afterAddLiquidityCount;
    mapping(PoolId => uint256 count) public beforeSwapCount;
    mapping(PoolId => uint256 count) public afterSwapCount;

    constructor(ICLPoolManager _poolManager, NonfungiblePositionManager _nfp) CLBaseHook(_poolManager) {
        // Initialize PancakeSwap Pool
        //vault = new Vault();
        // poolManager = new CLPoolManager(vault, 500000);
        // vault.registerApp(address(poolManager));

        nfp = _nfp;
    }

    function setTokenId(uint256 _tokenId) external {
        require(msg.sender == owner, "CLLaunchpadHook: FORBIDDEN");
        tokenId = _tokenId;
    }

    function setOwner(address _owner) external {
        require(msg.sender == owner || owner == address(0), "CLLaunchpadHook: FORBIDDEN");
        owner = _owner;
    }

    function setEnd(uint256 _end) external {
        require(msg.sender == owner, "CLLaunchpadHook: FORBIDDEN");
        end = _end;
    }

    function setOneWay(bool _oneWay, bool _isToken0NonBase) external {
        require(msg.sender == owner, "CLLaunchpadHook: FORBIDDEN");
        oneWay = _oneWay;
        isToken0NonBase = _isToken0NonBase;
    }

    function getHooksRegistrationBitmap() external pure override returns (uint16) {
        return _hooksRegistrationBitmapFrom(
            Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: false,
                afterAddLiquidity: false,
                beforeRemoveLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: false,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnsDelta: false,
                afterSwapReturnsDelta: false,
                afterAddLiquidityReturnsDelta: false,
                afterRemoveLiquidityReturnsDelta: false
            })
        );
    }

    function afterSwap(address, PoolKey calldata key, ICLPoolManager.SwapParams calldata, BalanceDelta delta, bytes calldata)
        external
        override
        poolManagerOnly
        returns (bytes4, int128)
    {
        // collect the fees
        // /* (uint256 amount0, uint256 amount1) =*/ nfp.collect(
        //         INonfungiblePositionManager.CollectParams({
        //             tokenId: tokenId,
        //             recipient: owner,
        //             amount0Max: 999999999999999999,
        //             amount1Max: 999999999999999999
        //         })
        //     );
        //ILaunchpad(owner).proxyCollect(tokenId); - does not work because of the Locking Issue of V4 described in the README.md

        require(!oneWay || (isToken0NonBase ? delta.amount0() >= 0 : delta.amount1() >= 0), "Only one way swap allowed");

        require(block.timestamp <= end, "CLLaunchpadHook: CAMPAIGN ENDED");

        afterSwapCount[key.toId()]++;
        return (this.afterSwap.selector, 0);
    }
}
