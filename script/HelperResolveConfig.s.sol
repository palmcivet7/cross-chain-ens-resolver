// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperResolveConfig is Script {
    struct NetworkConfig {
        address router;
        address link;
        address receiver;
        uint64 chainSelector;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            return;
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            router: 0xD0daae2231E9CB96b94C8512223533293C3693Bf, // https://docs.chain.link/ccip/supported-networks/testnet#ethereum-sepolia
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789, // https://sepolia.etherscan.io/token/0x779877A7B0D9E8603169DdbD7836e478b4624789
            receiver: 0x5C1E7e6AdB4EF2E7337619EAfD1C8d9Ada80690a, // https://testnet.snowtrace.io/address/0x5C1E7e6AdB4EF2E7337619EAfD1C8d9Ada80690a#code-43113
            chainSelector: 14767482510784806043 // https://docs.chain.link/ccip/supported-networks/testnet#avalanche-fuji
        });
    }
}
