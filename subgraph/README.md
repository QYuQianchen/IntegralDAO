# Subgraph for IntegralDAO Protocol
Demo on HOPR token on mainnet.

Deploy to the [legacy explorer: Integral DAo Protocol Demo](https://thegraph.com/hosted-service/subgraph/qyuqianchen/integral-dao-protocol-demo?query=Example%20Get%20Integral)

## How to run

Here's the _tl;dr_ version:

```bash
// Using hoprnet/hoprnet
$ yarn run:network
// Inside this repo
$ pbpaste | xargs -I {} echo "ETHEREUM_NETWORK=localhost\nETHEREUM_ENDPOINT={}" > .env
$ yarn prepare-local
$ yarn codegen
$ yarn pre-build
$ yarn build
$ docker-compose up
$ yarn create-local
$ yarn deploy-local
```