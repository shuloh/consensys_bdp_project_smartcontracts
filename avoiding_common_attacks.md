# Avoiding common attacks

## Transaction Ordering (ERC20 double-spend vulnerability)

ERC20 suffers from the double-spend attack from the implementation of the `approve` function. Consider Alice initially providing Bob an allowance of 10 tokens to spend from her account. Should Alice consider to lower her allowance by calling `approve` again to set the new allowance at 5 tokens, Bob can see this transaction broadcasted on the blockchain and quickly try to front run this transaction and spend the initial 10 allowance. Should Bob's spend transaction be ordered ahead of Alice's update allowance transaction, Bob can potentially spend another 5 tokens because Alice's update allowance has actually updated the allowance from 0 to 5 (since Bob has previously spent the allowance from 10 to 0) and not from 10 to 5 as expected.

To avoid this attack, this project NEVER uses the `approve` function and instead leverages the increaseAllowance and decreaseAllowance functions implemented by OpenZeppelin. This atomically modifies the allowance account to a higher or lower amount that avoids the potential vulerability outlined above.

## Reentrancy

To mitigate possible reentrancy attacks, all functions implemented in the smart contracts used by the exchange follows the pattern of modifying internal state before any external contract calls as much as possible. As an example, the buy transaction only makes the `transferFrom` calls to the exchangeToken and company contracts at the last possible execution. Furthermore, functions in the smart contract use heavily the `require` conditional checks as a further precautionary measure at various points along the execution of a function to revert as early as possible when the function call is expected to fail.
