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

# 部署测试的usdc合约
forge script script/TestUSDC.s.sol:TestUSDCScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

# 部署看涨期权合约
forge script script/OptionsNFT.s.sol:OptionsNFTScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

# 部署 DeSwapToken 合约
forge script script/DeSwapToken.s.sol:DeSwapTokenScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

# 部署 DeSwapTimelockController 合约
forge script script/DeSwapTimelockController.s.sol:DeSwapTimelockControllerScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

# 部署 DeSwapGovernor 合约
forge script script/DeSwapGovernor.s.sol:DeSwapGovernorScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

### Manually Verify
```shell
forge verify-contract --watch --chain-id 11155111 --constructor-args $(cast abi-encode "constructor(address,address,string,string)" 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9 0xFCAE2250864A678155f8F4A08fb557127053E59E 0x720aC46FdB6da28FA751bc60AfB8094290c2B4b7 "WETH/USDC Options" "WETH/USDC") 0x1773d25e51ffac3d188842824f22c4f8bb963586 src/OptionsNFT.sol:OptionsNFT
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
| 0x72cc35eF6E55B94bBcb216B8D1b31C8E37994ea6 | 0xACA8cC8BC17D7A3e6cB62065F2C79dC66FbBC86C |  0x7557fc1e59e52D28546A9042579a4E2873c8a9F4 | 0x5A3036AAfd7213bF330d08273cee0C8734b7312E | 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9 | 0xFCAE2250864A678155f8F4A08fb557127053E59E | sepolia |
| 0x72cc35eF6E55B94bBcb216B8D1b31C8E37994ea6 | 0xACA8cC8BC17D7A3e6cB62065F2C79dC66FbBC86C |  0x25D30E1Bb90F197FED0eF5D8f097b3F020ff61c1 | 0xBC798828A55F102CB8Ac6BDE9b1Fdda6A7eb0A91 | 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9 | 0xFCAE2250864A678155f8F4A08fb557127053E59E | sepolia |


## TODO
- [ ] Set collaborators. [https://docs.opensea.io/docs/contract-level-metadata](https://docs.opensea.io/docs/contract-level-metadata)
- [ ] Update external_link, logo in contractURI
- [x] support puts options.
- [ ] opensea svg content type wrong(must add xmln=xxx)
- [ ] approve just once.(EIP2612 or approve max)
- [ ] not check transferFrom return value
- [ ] reuse calls/puts
- [ ] create3 ensure same address
- [ ] learn to create and manage a DAO
