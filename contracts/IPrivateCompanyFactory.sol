pragma solidity 0.5.12;
import "./IPrivateCompany.sol";

interface IPrivateCompanyFactory {
    function newCompany(address owner, string calldata name, string calldata symbol) external returns (IPrivateCompany);
}