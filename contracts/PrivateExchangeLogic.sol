pragma solidity 0.5.12;
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./IPrivateCompany.sol";
import "./IPrivateCompanyFactory.sol";

contract PrivateExchangeLogic is Initializable, Ownable {

    bool private _openMode;
    IPrivateCompanyFactory companyFactory;
    IPrivateCompany[] listedCompanies;

    //We must set the owner in the initializer func due to the proxy pattern.
    //State in this contract is meaningless through a proxy.
    function initialize(address owner) public initializer {
        _transferOwnership(owner);
        _openMode = false;
    }

    function isOpen() public view returns (bool) {
        return _openMode;
    }

    function switchOpenMode(bool value) public onlyOwner {
        _openMode = value;
    }

    function createAndListCompany(string memory name, string memory symbol, uint256 shares) public {
        require(isOpen() || isOwner(), "not in open mode, or caller not owner");
        address owner = msg.sender;
        IPrivateCompany c = companyFactory.newCompany(owner, name, symbol);
        listedCompanies.push(c);
        c.mint(msg.sender, shares);
        c.increaseAllowance(address(this), shares);
    }

    function listCompany(address c) public onlyOwner {
        listedCompanies.push(IPrivateCompany(c));
    }

    function delistCompany(address company) public onlyOwner {
        for (uint i = 0; i < listedCompanies.length; i++ )
        {
            if (address(listedCompanies[i]) == company)
            {
                listedCompanies[i] = listedCompanies[listedCompanies.length - 1];
                listedCompanies.pop();
                return;
            }
        }
    }
}