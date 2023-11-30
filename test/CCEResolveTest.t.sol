// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";

contract CCEResolveTest is Test {
    function setUp() public {}

    function testLabel() public {
        string memory label = getLabelFromDomain("palmcivet.eth");
        console.log("label: ", label);
        uint256 tokenId = uint256(keccak256(bytes(label)));
        console.log("tokenId:", tokenId);
    }

    // function resolveOwner(string memory _domain) private view returns (address) {
    //     bytes32 node = bytes(_domain).namehash();
    //     address owner = ENS(ENS_ADDRESS).owner(node);

    //     if (owner == NAME_WRAPPER_ADDRESS) {
    //         string memory label = getLabelFromDomain(_domain);
    //         uint256 tokenId = uint256(keccak256(bytes(label)));
    //         return INameWrapper(NAME_WRAPPER_ADDRESS).ownerOf(tokenId);
    //     }
    //     return owner;
    // }

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
}
