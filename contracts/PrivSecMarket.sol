pragma solidity 0.5.12;

contract PrivSecMarket {
  address public owner;
  constructor() public {
    owner = msg.sender;
  }
}