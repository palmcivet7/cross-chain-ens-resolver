// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {CCERequest} from "../src/CCERequest.sol";
import {HelperRequestConfig} from "./HelperRequestConfig.s.sol";

contract DeployCCERequest is Script {
    function run() external returns (CCERequest, HelperRequestConfig) {
        HelperRequestConfig config = new HelperRequestConfig();
        (address router, address link) = config.activeNetworkConfig();

        vm.startBroadcast();
        CCERequest cceRequest = new CCERequest(router, link);
        vm.stopBroadcast();
        return (cceRequest, config);
    }
}
