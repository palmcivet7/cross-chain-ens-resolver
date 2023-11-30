// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";

contract HelperRequestConfig is Script {
    struct NetworkConfig {
        address router;
        address link;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 43113) {
            activeNetworkConfig = getAvalancheFujiConfig();
        } else {
            return;
        }
    }

    function getAvalancheFujiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            router: 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8, // https://docs.chain.link/ccip/supported-networks/testnet#avalanche-fuji
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846 // https://testnet.snowtrace.io/token/0x0b9d5d9136855f6fec3c0993fee6e9ce8a297846
        });
    }
}
