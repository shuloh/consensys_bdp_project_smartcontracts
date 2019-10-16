pragma solidity 0.5.12;
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol";
import "./IPrivateCompany.sol";

//Pausable is derived from ERC20, needs to be on the left of Burnable, Mintable
contract PrivateCompany is IPrivateCompany, ERC20Pausable, ERC20Mintable, ERC20Detailed, Ownable {
    constructor(address owner, string memory name, string memory symbol)
    //for simplicity, all company share tokens have 0 decimals
    ERC20Detailed(name, symbol, 0)
    public { 
        _transferOwnership(owner);
    }
}
