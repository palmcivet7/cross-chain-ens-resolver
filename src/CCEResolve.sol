// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {LinkTokenInterface} from "@chainlink-brownie-contracts/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {ENSNamehash} from "@ens-namehash/contracts/ENSNameHash.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ENS {
    function owner(bytes32 node) external view returns (address);
}

interface INameWrapper {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract CCEResolve is CCIPReceiver, Ownable {
    error CCEResolve__NoLinkToWithdraw();
    error CCEResolve__LinkTransferFailed();

    using ENSNamehash for bytes;

    event OwnerSent(string ensDomain, address owner);

    address public constant ENS_ADDRESS = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e; // same for every chain
    address public constant NAME_WRAPPER_ADDRESS = 0x0635513f179D50A207757E05759CbD106d7dFcE8;
    address public immutable i_link;
    address public immutable i_receiver;
    uint64 public immutable i_destinationChainSelector;

    constructor(address _router, address _link, address _receiver, uint64 _destinationChainSelector)
        CCIPReceiver(_router)
        Ownable(msg.sender)
    {
        i_link = _link;
        LinkTokenInterface(i_link).approve(i_router, type(uint256).max);
        i_receiver = _receiver;
        i_destinationChainSelector = _destinationChainSelector;
    }

    function resolveOwner(string memory _domain) private view returns (address) {
        bytes32 node = bytes(_domain).namehash();
        address owner = ENS(ENS_ADDRESS).owner(node);

        if (owner == NAME_WRAPPER_ADDRESS) {
            string memory label = getLabelFromDomain(_domain);
            uint256 tokenId = uint256(keccak256(bytes(label)));
            return INameWrapper(NAME_WRAPPER_ADDRESS).ownerOf(tokenId);
        }
        return owner;
    }

    function getLabelFromDomain(string memory _domain) private pure returns (string memory) {
        bytes memory domainBytes = bytes(_domain);
        bytes memory labelBytes = new bytes(domainBytes.length - 4);
        assembly {
            let src := add(domainBytes, 32)
            let dest := add(labelBytes, 32)
            mstore(dest, mload(src))
        }
        return string(labelBytes);
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

    function withdrawLink() public onlyOwner {
        uint256 balance = LinkTokenInterface(i_link).balanceOf(address(this));
        if (balance == 0) revert CCEResolve__NoLinkToWithdraw();

        if (!LinkTokenInterface(i_link).transfer(msg.sender, balance)) revert CCEResolve__LinkTransferFailed();
    }
}
