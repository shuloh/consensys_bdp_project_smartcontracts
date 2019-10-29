# Development

This repo contains only the truffle framework and solidity contracts behind the deployed app at <https://shuloh.github.io/entanglement-exchange>.

For the repo for the front-end react app, please use <https://github.com/shuloh/entanglement-exchange>

## Local Setup

1. In the project root dir, install all node dependencies and  
   `git clone git@github.com:shuloh/entanglement-exchange.git`  
    to create a directory called [entanglement-exchange](/entanglement-exchange) where the front-end app lives.
   > Note that when truffle compiles the contracts, the configuration specified in [truffle-config.js](truffle-config.js)
   > builds the .json abi files into the front-end app directory via the following code:  
   > `contracts_build_directory: path.join( \_\_dirname, "entanglement-exchange/src/contracts" ),`
2. In the project root dir, create a [.env](.env) file and set the `MNEMONIC` variable with your desired 12 word seed phrase.

   > MNEMONIC={...your 12 words}

   `npm run ganache` runs `ganache-cli` under the hood initialized with the mnemonic phrase set above

3. With ganache-cli running,
   `npm run migrate` runs `truffle migrate` under the hood to the local ganache blockchain,
   and builds the json .abi files to the front end directory

4. Enter the [entanglement-exchange](/entanglement-exchange) directory cloned from step 1 and install all node dependencies.
   `npm run start` to start the local development server for the create-react-app

5. Use a web3 provider such as Metamask to interact with the dApp.

   > Note that truffle migration uses accounts[0] from the MNEMONIC phrase set in .env to deploy a proxy contract (upgradeable pattern).

   > Due to the transparent proxy pattern, accounts[0] cannot interact normally with the exchange contract as it is the administrator of the proxy contract, and all calls/transactions from the proxy administrator do NOT get forwarded via delegatecall to the logic contract implementation. This is to allow the proxy administrator to upgrade the proxy and not be confused with any conflicting forwarded calls to the logic contract.

   > Therefore, the truffle migration process sets accounts[1] as the logical contract administrator. To interact as an administrator with the exchange, make sure to use accounts[1]. To interact as a normal user with the exchange, make sure to use any account that is not accounts[0] or accounts[1].

# Testing

`npm run test` runs `truffle test` under the hood

## Coverage

Solidity test coverage results from `npm run coverage` that runs `solidity-coverage`:

| File                       | % Stmts | % Branch | % Funcs | % Lines | Uncovered Lines |
| -------------------------- | ------- | -------- | ------- | ------- | --------------- |
| contracts/                 | 100     | 100      | 100     | 100     |                 |
| IPrivateCompany.sol        | 100     | 100      | 100     | 100     |                 |
| IPrivateCompanyFactory.sol | 100     | 100      | 100     | 100     |                 |
| PrivateCompany.sol         | 100     | 100      | 100     | 100     |                 |
| PrivateCompanyFactory.sol  | 100     | 100      | 100     | 100     |                 |
| PrivateExchangeLogic.sol   | 100     | 100      | 100     | 100     |                 |
| PrivateExchangeProxy.sol   | 100     | 100      | 100     | 100     |                 |
