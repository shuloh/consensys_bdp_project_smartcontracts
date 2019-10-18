pragma solidity 0.5.12;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./IPrivateCompany.sol";

contract PrivateCompany is ERC20Detailed, ERC20, Ownable {
    constructor(address intendedOwner, string memory name, string memory symbol)
    //for simplicity, all company share tokens have 18 decimals (wei)
    ERC20Detailed(name, symbol, 18)
    public { 
        //Ownable by default sets msg.sender(Factory) as owner which we might not want
        if (intendedOwner != owner()){
            _transferOwnership(intendedOwner);
        }
    }

    function mint(uint256 value) public onlyOwner{
        _mint(msg.sender, value);
    }

}