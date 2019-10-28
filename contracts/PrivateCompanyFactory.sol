pragma solidity 0.5.12;
import "./PrivateCompany.sol";
import "./IPrivateCompanyFactory.sol";

contract PrivateCompanyFactory is IPrivateCompanyFactory {

    /**
    * @dev see IPrivateCompanyFactory.newCompany
    */
    function newCompany(
        address intendedOwner,
        string memory name,
        string memory symbol
    )
    public returns (address) {
        PrivateCompany c = new PrivateCompany(intendedOwner, name, symbol);
        emit newCompanyCreated(intendedOwner, address(c));
        return address(c);
    }
}