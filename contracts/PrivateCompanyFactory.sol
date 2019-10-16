pragma solidity 0.5.12;
import "./PrivateCompany.sol";
import "./IPrivateCompany.sol";
import "./IPrivateCompanyFactory.sol";
import "@openzeppelin/contracts/access/Roles.sol";

contract PrivateCompanyFactory is IPrivateCompanyFactory {

    function newCompany(
        address owner,
        string memory name,
        string memory symbol
    )
    public returns (IPrivateCompany) {
        PrivateCompany c = new PrivateCompany(owner, name, symbol);
        return IPrivateCompany(c);
    }
}