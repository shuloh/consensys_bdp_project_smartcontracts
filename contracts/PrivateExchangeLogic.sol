pragma solidity 0.5.12;
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./IPrivateCompany.sol";
import "./IPrivateCompanyFactory.sol";

contract PrivateExchangeLogic is Initializable, Ownable {
    using SafeMath for uint256;

    IPrivateCompany public exchangeToken;

    mapping(address => uint256) public listedCompanyPrices;

    IPrivateCompany[] public listedCompanies;

    mapping(address => IPrivateCompany[]) public ownerCompanies;

    bool private _openMode;

    IPrivateCompanyFactory private _companyFactory;

    event ExchangeClosed();

    event ExchangeOpened();

    event CompanyListed(address indexed owner, address indexed company);

    event ExchangeTokenPurchased(address indexed account, address amount);

    event ShareTransaction(address indexed company, address indexed buyer, address indexed seller, uint256 amount, uint256 price);

    event CompanyPriceUpdated(address indexed company, uint256 price);

    //We must set the owner in the initializer func due to the proxy pattern.
    //State in this contract is meaningless through a proxy.
    function initialize(address owner, address companyFactory, string memory name, string memory symbol) public initializer {
        _transferOwnership(owner);
        _openMode = false;
        _companyFactory = IPrivateCompanyFactory(companyFactory);
        exchangeToken = _makeExchangeToken(name, symbol);
    }

    function upgradeCompanyFactory(address companyFactory) public onlyOwner {
        _companyFactory = IPrivateCompanyFactory(companyFactory);
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
        if (value){
            emit ExchangeOpened();
        }
        else {
            emit ExchangeClosed();
        }
    }

    function exchangeTokenBalance() public view returns(uint256) {
        return exchangeToken.balanceOf(msg.sender);
    }
    
    function buyExchangeToken() public payable onlyOpen {
        require(msg.value>0, "value needs to be non-zero");
        exchangeToken.mint(msg.value);
        exchangeToken.transfer(msg.sender, msg.value);
    }

    function buyCompanyShares(address company, uint256 amount) public onlyOpen {
        require(_isListedCompany(company), "not a listed company");
        uint256 price = listedCompanyPrices[company];
        require(price > 0, "company price invalid");
        address buyer = msg.sender;
        IPrivateCompany pc = IPrivateCompany(company);
        address seller = pc.owner();
        uint256 cost = amount.mul(price);
        uint256 sharesAvailable = pc.allowance(seller, address(this));
        require(sharesAvailable >= amount, "seller does not have enough shares to fill transaction");
        require(exchangeToken.allowance(buyer, address(this)) >= cost, "buyer does not have enough exchange tokens to fill transaction");
        pc.transferFrom(seller, buyer, amount);
        exchangeToken.transferFrom(buyer, seller, cost);
        emit ShareTransaction(company, buyer, seller, amount, price);
    }

    function updateCompanyPrice(address company, uint256 price) public onlyOpen {
        uint256 _price = listedCompanyPrices[company];
        require(_price > 0, "company is not listed");
        IPrivateCompany pc = IPrivateCompany(company);
        require(pc.owner() == msg.sender, "price-setter is not the company owner");
        require(price > 0 , "price is not set as a positive integer");
        _updateCompanyPrice(company, price);
    }
    function _updateCompanyPrice(address company, uint256 price) internal {
        listedCompanyPrices[company] = price;
        emit CompanyPriceUpdated(company, price);
    }

    function createCompanyAndList(string memory name, string memory symbol, uint256 price) public onlyOpen {
        address companyOwner = msg.sender;
        IPrivateCompany c = _createCompany(companyOwner, name, symbol);
        _listCompany(c);
        _updateCompanyPrice(address(c), price);
    }

    function listCompany(address company, uint256 price) public onlyOwner {
        IPrivateCompany pc = IPrivateCompany(company);
        _updateCompanyPrice(company, price);
        _listCompany(pc);
    }

    function delistCompany(address company) public onlyOwner {
        _delistCompany(IPrivateCompany(company));
    }

    function _makeExchangeToken(string memory name, string memory symbol) internal returns (IPrivateCompany) {
        return _createCompany(address(this), name, symbol);
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

    function _isListedCompany(address company) internal view returns(bool) {
        return listedCompanyPrices[company] > 0;
    }
    function _listCompany(IPrivateCompany company) internal {
        listedCompanies.push(company);
        ownerCompanies[company.owner()].push(company);
        emit CompanyListed(company.owner(), address(company));
    }

    function _delistCompany(IPrivateCompany company) internal {
        listedCompanyPrices[address(company)] = 0;
        for (uint i = 0; i < listedCompanies.length; i++ )
        {
            if (listedCompanies[i] == company)
            {
                listedCompanies[i] = listedCompanies[listedCompanies.length - 1];
                listedCompanies.pop();
                break;
            }
        }
        IPrivateCompany[] storage ownedCompanies = ownerCompanies[company.owner()];
        for (uint i = 0; i < ownedCompanies.length; i++ )
        {
            if (ownedCompanies[i] == company)
            {
                ownedCompanies[i] = ownedCompanies[ownedCompanies.length - 1];
                ownedCompanies.pop();
                break;
            }
        }
    }
}