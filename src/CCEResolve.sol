// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {LinkTokenInterface} from "@chainlink-brownie-contracts/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

interface ENS {
    function owner(bytes32 node) external view returns (address);
}

contract CCEResolve is CCIPReceiver {
    event OwnerSent(string ensDomain, address owner);

    address public constant ENS_ADDRESS = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e; // same for every chain
    address public immutable i_link;
    address public immutable i_receiver;
    uint64 public immutable i_destinationChainSelector;

    constructor(address _router, address _link, address _receiver, uint64 _destinationChainSelector)
        CCIPReceiver(_router)
    {
        i_link = _link;
        LinkTokenInterface(i_link).approve(i_router, type(uint256).max);
        i_receiver = _receiver;
        i_destinationChainSelector = _destinationChainSelector;
    }

    function resolveOwner(string memory _domain) private view returns (address) {
        bytes32 node = keccak256(abi.encodePacked(bytes32(0), keccak256(abi.encodePacked(_domain))));
        address owner = ENS(ENS_ADDRESS).owner(node);
        return owner;
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        string memory ensDomain = abi.decode(message.data, (string));
        sendResolvedRequest(ensDomain, resolveOwner(ensDomain));
    }

    function sendResolvedRequest(string memory _ensDomain, address _owner) private {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(i_receiver),
            data: abi.encode(_ensDomain, _owner),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: i_link
        });
        IRouterClient(i_router).ccipSend(i_destinationChainSelector, message);
        emit OwnerSent(_ensDomain, _owner);
    }
}
