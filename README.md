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
