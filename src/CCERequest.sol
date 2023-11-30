// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {LinkTokenInterface} from "@chainlink-brownie-contracts/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract CCERequest is CCIPReceiver {
    error CCERequest__IncompatibleEnsDomain();

    event ResolutionRequested(string requestedDomain);
    event RequestResolved(string ensDomain, address resolvedAddress);

    address public immutable i_link;
    address public s_lastRequestResolved;

    constructor(address _router, address _link) CCIPReceiver(_router) {
        i_link = _link;
        LinkTokenInterface(i_link).approve(i_router, type(uint256).max);
    }

    function requestEnsResolution(address _receiver, string memory _ensDomain, uint64 _destinationChainSelector)
        external
    {
        if (!endsWithEth(_ensDomain)) revert CCERequest__IncompatibleEnsDomain();
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(_ensDomain),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: i_link
        });
        IRouterClient(i_router).ccipSend(_destinationChainSelector, message);
        emit ResolutionRequested(_ensDomain);
    }

    function endsWithEth(string memory domain) internal pure returns (bool) {
        bytes memory domainBytes = bytes(domain);
        bytes memory ethSuffix = bytes(".eth");

        uint256 domainLength = domainBytes.length;
        uint256 suffixLength = ethSuffix.length;

        if (domainLength < suffixLength) {
            return false;
        }

        // Directly compare the relevant parts of the string
        return domainBytes[domainLength - 4] == ethSuffix[0] // '.'
            && domainBytes[domainLength - 3] == ethSuffix[1] // 'e'
            && domainBytes[domainLength - 2] == ethSuffix[2] // 't'
            && domainBytes[domainLength - 1] == ethSuffix[3]; // 'h'
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        (string memory ensDomain, address resolvedAddress) = abi.decode(message.data, (string, address));
        s_lastRequestResolved = resolvedAddress;
        emit RequestResolved(ensDomain, resolvedAddress);
    }
}
