# Cross-Chain ENS Resolver (CCER)

This project allows users to resolve the owner address of an ENS domain across chains.

Cross Chain ENS Resolver allows users to retrieve the owner address of an ENS domain across chains. There is a CCE Request contract deployed on Avalanche Fuji, and a CCE Resolve contract on Ethereum Sepolia. The user interacts only with the CCE Request contract on Avalanche Fuji to retrieve the owner address of their queried ENS domain from Ethereum Sepolia, back to Avalanche Fuji. The user inputs the address of the CCE Resolve contract, the ENS domain to query, and the chain selector.
The ENS domain is sent to Ethereum Sepolia and used for interacting with the ENS contract on that chain to look up the owner of the domain. The owner address is then sent back to the CCE Request contract along with the ENS domain. These values are stored in state variables and an event is emitted declaring them.
Thank you for your time.

---

[CCERequest on Fuji](https://testnet.snowtrace.io/address/0x5C1E7e6AdB4EF2E7337619EAfD1C8d9Ada80690a#code-43113)

[CCEResolve on Sepolia](https://sepolia.etherscan.io/address/0x49e9e7BF2b53c075795659AC9Ce84Bd294857402#code)

[txs on CCIP](https://ccip.chain.link/tx/0x9b793c405f693dfc7c97e685655c88b423a500b4376873044292490d145e5b0d)

[tx on Fuji](https://testnet.snowtrace.io/tx/0x9cf555676adf676f150b094e06e391e66f839e066b21985c6cc1e1b049985aec?chainId=43113#eventlog)
