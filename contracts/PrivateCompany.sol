pragma solidity 0.5.12;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./IPrivateCompany.sol";

contract PrivateCompany is ERC20Detailed, ERC20, Ownable {
    /**
    * @dev PrivateCompany implements the ERC20 Libraries. 18 decimals enforced.
    * @param intendedOwner address of owner, because factory makes this entity,
    * Ownable by default sets factory as owner, so we have to transfer ownership
    * @param name of company
    * @param symbol of company
    */
    constructor(address intendedOwner, string memory name, string memory symbol)
    ERC20Detailed(name, symbol, 18)
    public { 
        _transferOwnership(intendedOwner);
    }

    function mint(uint256 value) public onlyOwner{
        _mint(msg.sender, value);
    }

    function burn(uint256 value) public onlyOwner{
        _burn(msg.sender, value);
    }
}