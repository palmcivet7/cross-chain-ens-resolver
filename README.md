# Cross-Chain ENS Resolver (CCER)

This project allows users to resolve the owner address of an [ENS domain](https://app.ens.domains/) across chains using [Chainlink CCIP](https://docs.chain.link/ccip).

[Video Demonstration](https://www.youtube.com/watch?v=-FomV7XvyBA)

## Table of Contents

- [Cross-Chain ENS Resolver (CCER)](#cross-chain-ens-resolver-ccer)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)
  - [Demonstrations](#demonstrations)
  - [License](#license)

## Overview

Cross-Chain ENS Resolver allows users to retrieve the owner address of an ENS domain across chains. There is a [CCERequest contract](https://github.com/palmcivet7/cross-chain-ens-resolver/blob/main/src/CCERequest.sol) deployed on [Avalanche Fuji](https://testnet.snowtrace.io/address/0x5C1E7e6AdB4EF2E7337619EAfD1C8d9Ada80690a#code-43113), and a [CCEResolve contract](https://github.com/palmcivet7/cross-chain-ens-resolver/blob/main/src/CCEResolve.sol) on [Ethereum Sepolia](https://sepolia.etherscan.io/address/0x49e9e7BF2b53c075795659AC9Ce84Bd294857402#code).

The user interacts only with the CCERequest contract on Avalanche Fuji to retrieve the owner address of their queried ENS domain from Ethereum Sepolia, back to Avalanche Fuji. The user inputs the `address of the CCEResolve contract`, the `ENS domain to query as a string`, and the `chain selector`.

The ENS domain is sent to Ethereum Sepolia and used for interacting with the [ENS contract](https://sepolia.etherscan.io/address/0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e#code) on that chain to look up the owner of the domain. The `owner address` is then sent back to the CCERequest contract along with the `ENS domain`. These values are stored in state variables and an event is emitted declaring them.

## Usage

The user calls the `requestEnsResolution()` function on the `CCERequest` contract. This uses CCIP to send the queried ENS domain to the `CCEResolve` contract.

The `CCEResolve` contract converts the domain to an ENS compatible namehash with [this library](https://github.com/JonahGroendal/ens-namehash), uses that to call the `owner()` function on the `ENS` contract, and then sends the response and the domain back to the `CCERequest` contract with CCIP.

When the response is received back on the original chain/contract, an event is emitted with both the `ENS domain` and the `owner address`. The last queried and resolved domain and owner are stored in state variables.

## Demonstrations

[CCERequest on Fuji](https://testnet.snowtrace.io/address/0x5C1E7e6AdB4EF2E7337619EAfD1C8d9Ada80690a#code-43113)

[CCEResolve on Sepolia](https://sepolia.etherscan.io/address/0x49e9e7BF2b53c075795659AC9Ce84Bd294857402#code)

[txs on CCIP](https://ccip.chain.link/tx/0x9b793c405f693dfc7c97e685655c88b423a500b4376873044292490d145e5b0d)

[tx on Fuji](https://testnet.snowtrace.io/tx/0x9cf555676adf676f150b094e06e391e66f839e066b21985c6cc1e1b049985aec?chainId=43113#eventlog)

## License

This project is licensed under the [MIT License](https://opensource.org/license/mit/).
