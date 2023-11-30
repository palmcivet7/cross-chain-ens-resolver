// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {CCEResolve} from "../src/CCEResolve.sol";
import {HelperResolveConfig} from "./HelperResolveConfig.s.sol";

contract DeployCCEResolve is Script {
    function run() external returns (CCEResolve, HelperResolveConfig) {
        HelperResolveConfig config = new HelperResolveConfig();
        (address router, address link, address receiver, uint64 chainSelector) = config.activeNetworkConfig();

        vm.startBroadcast();
        CCEResolve cceResolve = new CCEResolve(router, link, receiver, chainSelector);
        vm.stopBroadcast();
        return (cceResolve, config);
    }
}
