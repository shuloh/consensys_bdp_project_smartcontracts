pragma solidity 0.5.12;
import "@openzeppelin/contracts/access/Roles.sol";
contract PrivateExchange {
    struct Company {
        string name;
        address addr;
    }
    using Roles for Roles.Role;

    address private _owner;
    bool public openMode;

    Roles.Role private _companies;

    Company[] public listedCompanies;

    constructor () internal {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Caller is not the exchange owner");
        _;
    }
    function switchOpenMode(bool value) public onlyOwner
    {
        openMode = value;
    }

    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }


//Companies
    event CompanyRequestedToDelist(address indexed company);
    event CompanyRequestedToList(address indexed company);
    event CompanyListed(address indexed company);
    event CompanyDelisted(address indexed company);
    modifier onlyCompany() {
        require(isCompany(msg.sender), "Caller is not a listed company");
        _;
    }
    function isCompany(address account) public view returns (bool) {
        return _companies.has(account);
    }

    function requestToListCompany(string memory name) public {
        _requestToListCompany(msg.sender);
        if (openMode) {
            _listCompany(msg.sender, name);
        }
    }

    function requestToDelistCompany() public {
        _requestToDelistCompany(msg.sender);
        if (openMode) {
            _delistCompany(msg.sender);
        }
    }

    function _requestToListCompany(address account) internal {
        emit CompanyRequestedToList(account);
    }
    function _requestToDelistCompany(address account) internal {
        emit CompanyRequestedToDelist(account);
    }

    function listCompany(address account, string memory name) public onlyOwner {
        _listCompany(account, name);
    }

    function delistCompany(address account) public onlyOwner {
        _delistCompany(account);
    }

    function _listCompany(address account, string memory name) internal {
        _companies.add(account);
        listedCompanies.push(Company(name,account));
        emit CompanyListed(account);
    }

    function _delistCompany(address account) internal {
        _companies.remove(account);
        bool found = false;
        uint index = 0;
        for (uint i = 0; i < listedCompanies.length; i++ )
        {
            if (listedCompanies[i].addr == account)
            {
                found = true;
                index = i;
            }
        }
        if (found){
            listedCompanies[index] = listedCompanies[listedCompanies.length - 1];
            listedCompanies.pop();
        }
        emit CompanyDelisted(account);
    }

}