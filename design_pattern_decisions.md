# Design Pattern Decisions

## Interoperability

The internal exchange token EE\$ and the various company shares (represented as tokens) all adhere to the ERC20 standard so that they easily be distributed, shared, and understood. Although users can only create and list companies on the platform, the contract allows the logical administrator of the exchange to list an already existing ERC20-compliant company token/shares that adheres to the specification and interface of the exchange.

## Upgradeability

The app uses the transparent proxy pattern by OpenZeppelin to allow future improvements and bug fixes to the exchange. The interface contract of the app is the address of `PrivateExchangeProxy.sol` but the proxy forwards all non-admin calls and transactions to the deployed logic contract at `PrivateExchangeLogic.sol` There is a separation of roles between the proxy administrator that can upgrade the implementaiton of the exchange, and the logical administrator that can call 'owner' functions of the exchange implementation.

The exchange uses an external factory contract to generate new company entites and its initial exchange Token. This external factory serves as boilerplate and is upgradeable via a change in the address of the factory that can only be called by the logical administrator.

## Decentralization

The exchange never actually holds the shares of company or the EE$ tokens of a user and behaves more like an Escrow. Users allocate an allowance for the exchange to conduct transactions. When the exchange transfers EE$ or shares out from an investor or company owner via the `transferFrom` function, these EE\$ or shares always go to the counterparty directly in a single transaction. If any conditions fail in the transaction, the transaction reverts and the funds of both parties are safe.

## Emergency Circuit-Breaker

The exchange has an open/close mode that will allow the owner to prevent all transactions from happening on the exchange in the event of an emergency or a bug discovery. This is reflected in the modifier `isOpen` in the `PrivateExchangeLogic.sol` contract.
