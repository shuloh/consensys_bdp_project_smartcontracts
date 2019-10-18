pragma solidity 0.5.12;
import "./PrivateCompany.sol";
import "./IPrivateCompanyFactory.sol";

contract PrivateCompanyFactory is IPrivateCompanyFactory {

    function newCompany(
        address intendedOwner,
        string memory name,
        string memory symbol
    )
    public returns (address) {
        PrivateCompany c = new PrivateCompany(intendedOwner, name, symbol);
        return address(c);
    }
}