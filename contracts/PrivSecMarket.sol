pragma solidity 0.5.12;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Roles.sol";
contract PrivSecMarket {
    using Roles for Roles.Role;
    address private _owner;
    mapping(address=>address) public securities_shares;
    mapping(address=>IERC721) public securities;
    mapping(address=>IERC20) public shares;
    constructor() public {
        _owner = msg.sender;
    }
}