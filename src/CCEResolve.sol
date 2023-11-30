// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {LinkTokenInterface} from "@chainlink-brownie-contracts/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

interface ENS {
    function resolver(bytes32 node) external view returns (Resolver);
}

interface Resolver {
    function addr(bytes32 node) external view returns (address);
}

contract ENSResolver is CCIPReceiver {
    event ResolvedRequestSent(string ensDomain, address resolver);

    address public immutable i_ens;
    address public immutable i_link;
    address public immutable i_receiver;
    uint64 public immutable i_destinationChainSelector;

    constructor(address _router, address _link, address _receiver, uint64 _destinationChainSelector, address _ens)
        CCIPReceiver(_router)
    {
        i_link = _link;
        LinkTokenInterface(i_link).approve(i_router, type(uint256).max);
        i_receiver = _receiver;
        i_destinationChainSelector = _destinationChainSelector;
        i_ens = _ens;
    }

    function resolve(string memory _domain) private view returns (address) {
        bytes32 node = keccak256(abi.encodePacked(bytes32(0), keccak256(abi.encodePacked(_domain))));
        Resolver resolver = ENS(i_ens).resolver(node);
        return resolver.addr(node);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        string memory ensDomain = abi.decode(message.data, (string));
        sendResolvedRequest(ensDomain, resolve(ensDomain));
    }

    function sendResolvedRequest(string memory _ensDomain, address _resolver) private {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(i_receiver),
            data: abi.encode(_ensDomain, _resolver),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: i_link
        });
        IRouterClient(i_router).ccipSend(i_destinationChainSelector, message);
        emit ResolvedRequestSent(_ensDomain, _resolver);
    }
}
