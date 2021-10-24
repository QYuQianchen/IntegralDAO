# Integral DAO Protocol

## Installation
```bash
nvm use 16
yarn install
```
then compile
```bash
yarn build:sol
```
Paid no attention to unit testing and coverage
```bash
yarn test
yarn coverage
```
deploy to Rinkeby
```bash
yarn deploy:demo
```
Then you should be able to see some results like:
```json
Dao deployed to:  {
  governorExpectedAddress: '0xd66Feb136D2e546a1684F9D5756A496903888A55',
  governor: '0xd66Feb136D2e546a1684F9D5756A496903888A55',
  timelock: '0x6a07d91E0082c287953EE6911EAA0be80f7BF554',
  daoToken: '0xbe8F221Ce79adf50ED1B61b24cE4B3deC5E0959D',
  nftToken: '0x08D017ba93c9c79bEbCaaC440067099B55bf24Fd'
}
```
verify `daoToken`, `nftToken` and `governor` with
```sh
# for daoToken
DEPLOYED_TOKEN_ADDRESS=0xbe8F221Ce79adf50ED1B61b24cE4B3deC5E0959D && yarn hardhat verify "$DEPLOYED_TOKEN_ADDRESS" "0x08D017ba93c9c79bEbCaaC440067099B55bf24Fd" --network rinkeby
# for nftToken
yarn hardhat verify "0x08D017ba93c9c79bEbCaaC440067099B55bf24Fd" --network rinkeby
# for governor
yarn hardhat verify "0xd66Feb136D2e546a1684F9D5756A496903888A55" "0xbe8F221Ce79adf50ED1B61b24cE4B3deC5E0959D" "0x6a07d91E0082c287953EE6911EAA0be80f7BF554" --network rinkeby
```

## Test
1. Connect to the deployer wallet, and run `sync()` on the DAO token, which extracts the time integral of the demo NFT.
2. Check `getVotes` is correct
