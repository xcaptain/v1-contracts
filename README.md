## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
source .env

# 部署 DeSwapToken 合约
forge script script/DeSwapToken.s.sol:DeSwapTokenScript --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv

# 部署 DeSwapTimelockController 合约
forge script script/DeSwapTimelockController.s.sol:DeSwapTimelockControllerScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

# 部署 DeSwapGovernor 合约，依赖 DST 和 timelock 合约地址
forge script script/DeSwapGovernor.s.sol:DeSwapGovernorScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

# 部署测试的usdc合约
forge script script/TestUSDC.s.sol:TestUSDCScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

# 部署看涨期权合约
forge script script/OptionsNFT.s.sol:OptionsNFTScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

### Manually Verify
```shell
forge verify-contract --watch --chain-id 11155111 --constructor-args $(cast abi-encode "constructor(address,address,address,string,string)" 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9 0xFCAE2250864A678155f8F4A08fb557127053E59E 0x25D30E1Bb90F197FED0eF5D8f097b3F020ff61c1 "WETH/USDC Options" "WETH/USDC") 0x142fa3a0D502C2Eb0DBa7b74F756fd6745a44d0d src/OptionsNFT.sol:OptionsNFT
```

verify on mumbai testnet:

```shell
forge verify-contract --watch --chain-id 80001 --constructor-args $(cast abi-encode "constructor(address)" 0x7e727520B29773e7F23a8665649197aAf064CeF1) 0x68C36e8d2fB887e7f06a700Ef89fB7671b49E1bd --verifier-url $MUMBAI_VERIFIER_URL --etherscan-api-key $MUMBAI_API_KEY src/DeSwapToken.sol:DeSwapToken
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## 合约地址



| options | DeSwapToken | DeSwapTimelockController | DeSwapGovernor | weth | usdc | network |
| --- | --- | --- | --- | --- | --- | --- |
| 0x142fa3a0D502C2Eb0DBa7b74F756fd6745a44d0d | 0x68C36e8d2fB887e7f06a700Ef89fB7671b49E1bd |  0xD686D2c83B86Ed6A9d5A1e817fA5f4c1269deedC | 0x6D4e5958F2386D8bCFa4e716d5A13fbEB509D188 | 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9 | 0x6CcB30b54Bf2B1Cf47E093B92aECCE404F9824Cd | sepolia |


## TODO
- [ ] Set collaborators. [https://docs.opensea.io/docs/contract-level-metadata](https://docs.opensea.io/docs/contract-level-metadata)
- [ ] Update external_link, logo in contractURI
- [x] support puts options.
- [x] opensea svg content type wrong(must add xmln=xxx)
- [ ] approve just once.(EIP2612 or approve max)
- [ ] not check transferFrom return value
- [ ] reuse calls/puts
- [x] create3 ensure same address
- [ ] learn to create and manage a DAO
