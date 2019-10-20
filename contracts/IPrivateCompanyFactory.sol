pragma solidity 0.5.12;
import "./IPrivateCompany.sol";

interface IPrivateCompanyFactory {
    event newCompanyCreated(address indexed owner, address indexed company);
    function newCompany(address intendedOwner, string calldata name, string calldata symbol) external returns (address);
}