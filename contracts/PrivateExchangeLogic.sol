pragma solidity 0.5.12;
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./IPrivateCompany.sol";
// import "./IPrivateCompanyFactory.sol";
import "./IPrivateCompanyFactory.sol";

contract PrivateExchangeLogic is Initializable, Ownable {
    using SafeMath for uint256;

    IPrivateCompany public exchangeToken;

    mapping(address => uint256) public listedCompanyPrices;

    IPrivateCompany[] public listedCompanies;

    mapping(address => IPrivateCompany[]) public ownerCompanies;

    bool private _openMode;

    IPrivateCompanyFactory private _companyFactory;

    event CompanyListed(address indexed owner, address indexed company);

    event ExchangeTokenPurchased(address indexed account, address amount);

    event ShareTransaction(address indexed company, address indexed buyer, address indexed seller, uint256 amount, uint256 price);

    event CompanyPriceChanged(address indexed company, uint256 price);

    //We must set the owner in the initializer func due to the proxy pattern.
    //State in this contract is meaningless through a proxy.
    function initialize(address owner, address companyFactory, string memory name, string memory symbol) public initializer {
        _transferOwnership(owner);
        _openMode = false;
        _companyFactory = IPrivateCompanyFactory(companyFactory);
        exchangeToken = _makeExchangeToken(name, symbol);
    }

    function _makeExchangeToken(string memory name, string memory symbol) internal returns (IPrivateCompany) {
        return _createCompany(owner(), name, symbol);
    }

    function numberOfListedCompanies() view public returns(uint256) {
        return listedCompanies.length;
    }

    function numberOfOwnedCompanies() view public returns(uint256) {
        return ownerCompanies[msg.sender].length;
    }

    modifier onlyOpen() {
        require(isOpen(), "not in open mode");
        _;
    }

    function isOpen() public view returns (bool) {
        return _openMode;
    }

    function switchOpenMode(bool value) public onlyOwner {
        _openMode = value;
    }
    
    function buyExchangeToken() public payable onlyOpen {
        exchangeToken.mint(msg.value);
        exchangeToken.transfer(msg.sender, msg.value);
    }

    function buyCompanyShares(uint256 index, uint256 amount) public onlyOpen {
        IPrivateCompany pc = listedCompanies[index];
        uint256 price = listedCompanyPrices[address(pc)];
        require(price > 0, "company price invalid");
        address buyer = msg.sender;
        address seller = pc.owner();
        uint256 cost = amount.mul(price);
        // exchangeToken.transferFrom(buyer, seller, )
        pc.transferFrom(seller, buyer, amount);
        exchangeToken.transferFrom(buyer, seller, cost);
        emit ShareTransaction(address(pc), buyer, seller, amount, price);
    }

    function setCompanyPrice(address company, uint256 price) public onlyOpen {
        IPrivateCompany pc = IPrivateCompany(company);
        require(pc.owner() == msg.sender, "price-setter is not the company owner");
        require(price > 0 , "price is not set as a positive integer");
        listedCompanyPrices[company] = price;
        emit CompanyPriceChanged(company, price);
    }

    function createCompanyAndList(string memory name, string memory symbol) public onlyOpen {
        address companyOwner = msg.sender;
        IPrivateCompany c = _createCompany(companyOwner, name, symbol);
        _listCompany(c);
    }

    function listCompany(address company) public onlyOwner onlyOpen {
        IPrivateCompany pc = IPrivateCompany(company);
        _listCompany(pc);
    }

    function delistCompany(address company) public onlyOwner {
        _delistCompany(IPrivateCompany(company));
    }

    function _createCompany(
        address companyOwner,
        string memory name,
        string memory symbol
    ) 
    internal returns(IPrivateCompany) {
        //EXTERNAL CONTRACT CALL
        address c = _companyFactory.newCompany(companyOwner, name, symbol);
        return IPrivateCompany(c); 
    }

    function _listCompany(IPrivateCompany company) internal {
        listedCompanies.push(company);
        ownerCompanies[company.owner()].push(company);
        emit CompanyListed(company.owner(), address(company));
    }

    function _delistCompany(IPrivateCompany company) internal {
        for (uint i = 0; i < listedCompanies.length; i++ )
        {
            if (listedCompanies[i] == company)
            {
                listedCompanies[i] = listedCompanies[listedCompanies.length - 1];
                listedCompanies.pop();
                return;
            }
        }
        IPrivateCompany[] storage ownedCompanies = ownerCompanies[company.owner()];
        for (uint i = 0; i < ownedCompanies.length; i++ )
        {
            if (ownedCompanies[i] == company)
            {
                ownedCompanies[i] = ownedCompanies[ownedCompanies.length - 1];
                ownedCompanies.pop();
                return;
            }
        }
    }
}