pragma solidity 0.5.12;
import "@openzeppelin/contracts/access/Roles.sol";
contract PrivateEquity {
    using Roles for Roles.Role;
    address private _owner;
    constructor() public {
        _owner = msg.sender;
    }
}