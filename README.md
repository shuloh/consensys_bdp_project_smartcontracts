# App Usage (Ropsten testnet)

[Entanglement exchange](https://shuloh.github.io/entanglement-exchange) (EE) is a dApp on the Ethereum Ropsten testnet that allows business-owners to list their company on a decentralized platform and raise capital, and allows private investors to purchase the shares of these companies.

EE uses an internal ERC20-compliant token called EE$ that serves as the currency for which company shares are transacted at.
At the moment, EE$ is marked as 1-to-1 to the value of Ether.

An investor that wishes to purchase a company's shares needs to convert their ether holdings to EE\$ on the User page of the app before using EE\$ to purchase the various listed company shares on the exchange.

Likewise, a company owner that earns EE$ from the sale of the company's shares needs can sell their EE$ for ether. Alternatively, they can use their EE\$ to conduct a share-buyback of their own company or use them to invest in the shares of other companies.

EE leverages the `allowance` and `transferFrom` functionalities of the ERC20 standard to allow investors to swap their EE$ for a company's shares. In other words, users never actually transfer their company shares or EE$ into the exchange's wallet in order for a share transaction to take place. Instead, they 'stake' their shares and EE$ to an allowance account that allows the exchange to call `transferFrom` both ways from the seller's shares account and buyer's EE$ account.

```
    function buyCompanyShares(address company, uint256 amount) public onlyOpen {
        require(_isListedCompany(company), "not a listed company");
        uint256 price = listedCompanyPrices[company];
        address buyer = msg.sender;
        IPrivateCompany pc = IPrivateCompany(company);
        address seller = pc.owner();
        uint256 cost = amount.mul(price).div(1 ether);
        uint256 sharesAvailable = pc.allowance(seller, address(this));
        require(
            sharesAvailable >= amount,
            "seller does not have enough shares to fill transaction"
        );
        require(
            exchangeToken.allowance(buyer, address(this)) >= cost,
            "buyer does not have enough exchange tokens to fill transaction"
        );
        pc.transferFrom(seller, buyer, amount);
        exchangeToken.transferFrom(buyer, seller, cost);
        emit ShareTransaction(company, buyer, seller, amount, price);
    }

```

## Steps to list a company

By clicking on the '+' button on the Home page, a company owner can list their company on the platform. The following inputs need to be provided: name, symbol, and their desired price per share that they wish to sell their shares at.

Next, after the transaction completes and their company card appears on the homepage, they can click the edit icon button on the card to interact with the company.
The React app only exposes owner functionalities if it detects the user is the owner.

Next, the company owner chooses how much shares they would like to mint. This is reflected in the totalSupply of the shares of the company. They would then be required to specify how much of the minted shares they would like to list on the exchange. The listing increases the shares allowance account of the exchange for the exchange to conduct share transactions with buyers.

## Steps to invest in a company

An investor-based user is required to buy EE$ on the User page with Ether. Once the transaction completes, the user should see an updated EE$ balance on the right top bar of the App. Next, they would have to 'stake' the amount of EE$ on the exchange, which increase the EE$ allowance of the exchange. Once the transaction completes, the updated EE\$ allowance will be reflected also on the right top bar.

After a user has sufficient EE\$ staked on the exchange allowance, the user can then proceed to the Home page and click on the edit icon of any company they would like to invest. This brings up a dialogue in which the user can specify the amount of shares the user would like to purchase on that company.

# Development

This repo contains only the truffle framework and solidity contracts behind the deployed app at <https://shuloh.github.io/entanglement-exchange>.

For the repo of the front-end react app, please use <https://github.com/shuloh/entanglement-exchange>

To run the full app locally, you are required to clone the git repo of front-end react app into this project's root folder, as outlined below.

## Local Setup

1. In the project root dir, install all node dependencies and  
   `git clone git@github.com:shuloh/entanglement-exchange.git`  
    to create a directory called [entanglement-exchange](/entanglement-exchange) where the front-end app lives.
   > Note that when truffle compiles the contracts, the configuration specified in [truffle-config.js](truffle-config.js)
   > builds the .json abi files into the front-end app directory via the following code:
   ```
   contracts_build_directory:
       path.join( \_\_dirname, "entanglement-exchange/src/contracts" ),
   ```
2. In the project root dir, create a [.env](.env) file and set the `MNEMONIC` variable with your desired 12 word seed phrase.

   > MNEMONIC={...your 12 words}

   `npm run ganache` runs `ganache-cli` under the hood initialized with the mnemonic phrase set above

3. With ganache-cli running,
   `npm run migrate` runs `truffle migrate` under the hood to the local ganache blockchain,
   and builds the json .abi files to the front end directory

4. Enter the [entanglement-exchange](/entanglement-exchange) directory cloned from step 1 and install all node dependencies.
   `npm run start` to start the local development server for the create-react-app

5. Use a web3 provider such as Metamask to interact with the dApp.

## Important Note

The project configuration in truffle migration uses accounts[0] from the `MNEMONIC` phrase set in .env to deploy [PrivateExchangeProxy.sol](contracts/PrivateExchangeProxy.sol) that is the main contract that the App interfaces with. PrivateExchangeProxy adheres to the upgradeable transparent proxy contract pattern from the OpenZeppelin libraries.

Due to the transparent proxy pattern, accounts[0] is set as the proxy's administrator and CANNOT interact with the logic/implementation/functionalities of the exchange contract. This is because all calls/transactions from the proxy administrator do NOT get forwarded via delegatecall to the logic contract implementation in the transparent proxy pattern. This is to allow the proxy administrator to upgrade the proxy and not be confused with any conflicting forwarded calls to the logic contract that has the same function signature.

The project configuration sets accounts[1] as the logical contract administrator. To interact as the logical administrator of the exchange, make sure to use accounts[1]. To interact as a normal user with the exchange, make sure to use any account that is not accounts[0] or accounts[1].

# Testing

`npm run test` runs `truffle test` under the hood

Tests are written in JavaScript within the Truffle framework located in the [test](/test) directory

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

## Design Pattern Decisions

See [design_pattern_decisions](design_pattern_decisions.md)

## Avoiding Common Attacks

See [avoiding_common_attacks.md](avoiding_common_attacks.md)

## Services & Libaries

ENS Ethereum Name Service. The proxy contract that the App interfaces with lives on Ropsten `entangle.eth`. When the App starts, it resolves `entangle.eth` from the ENS Resolver. This allows a change in the proxy address by going to the ENS to change the address resolution and we would save the trouble modifying the config json files of the front-end app.

OpenZeppelin libraries are heavily used by the smart contracts. Notable libraries include:

```
@openzeppelin/upgrades/contracts/upgradeability/InitializableAdminUpgradeabilityProxy.sol
@openzeppelin/upgrades/contracts/Initializable.sol;
@openzeppelin/contracts/ownership/Ownable.sol;
@openzeppelin/contracts/math/SafeMath.sol;
@openzeppelin/contracts/token/ERC20/ERC20.sol;
@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol;
```

## Deployed addresses on Ropsten

[deployed_addresses.txt](deployed_addresses.txt). Note that the state of the contract `PrivateExchangeLogic.sol` deployed is essentially meaningless. This is because we are using `PrivateExchangeProxy.sol` as the interfacing contract that forwards to the logic and functions provided by the logic contract, the data state of the contract actually lives at the address of PrivateExchangeProxy.
https://docs.openzeppelin.com/sdk/2.5/pattern.html  
https://blog.openzeppelin.com/the-transparent-proxy-pattern
