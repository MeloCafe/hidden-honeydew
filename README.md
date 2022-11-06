## build abi

```bash
forge build --extra-output-files abi
```

## scripts

### vault

#### deploy

```bash
source .env

forge script script/MeloVaultDeploy.s.sol:MeloVaultDeploy \
  --rpc-url $RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast -vvvv

# optionally, add `--chain-id 5` to deploy to testnet
```

### unfunge

#### deploy

```bash
source .env

export FUNGIBLE_TOKEN_ADDRESS=0x...
export AMOUNT_PER_NFT=1000000000000000000

forge script script/MeloVaultDeploy.s.sol:MeloVaultDeploy \
  --rpc-url $RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast -vvvv

# optionally, add `--chain-id 5` to deploy to testnet
```
