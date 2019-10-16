pragma solidity 0.5.12;
import "@openzeppelin/contracts/access/Roles.sol";


contract AccreditedInvestor {
    using Roles for Roles.Role;

    Roles.Role private _investors;

    address[] public registeredInvestors;

    event InvestorReqRegister(address indexed investor);

    event InvestorRegistered(address indexed investor);

    event InvestorRemoved(address indexed investor);

    function isInvestor(address account) public view returns (bool) {
        return _investors.has(account);
    }

    function registeredInvestorsCount() public view returns (uint count) {
        return registeredInvestors.length;
    }

    function _requestToRegisterInvestor(address account) internal {
        emit InvestorReqRegister(account);
    }

    function _registerInvestor(address account) internal {
        _investors.add(account);
        registeredInvestors.push(account);
        emit InvestorRegistered(account);
    }

    function _removeInvestor(address account) internal {
        _investors.remove(account);
        bool found = false;
        uint index = 0;
        for (uint i = 0; i < registeredInvestors.length; i++ )
        {
            if (registeredInvestors[i] == account)
            {
                found = true;
                index = i;
            }
        }
        if (found){
            registeredInvestors[index] = registeredInvestors[registeredInvestors.length - 1];
            registeredInvestors.pop();
        }
        emit InvestorRemoved(account);
    }
}