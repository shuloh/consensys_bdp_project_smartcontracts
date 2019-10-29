pragma solidity 0.5.12;
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./IPrivateCompany.sol";
import "./IPrivateCompanyFactory.sol";

/// @author Jordan Loh Shu Peng
/// @title A Decentralized exchange of ERC20 Tokens (Private Securities) that
/// uses an internal exchange Token for pricing between tokens
contract PrivateExchangeLogic is Initializable, Ownable {
    using SafeMath for uint256;

    /**
    * @dev address of the exchange-token
    */
    IPrivateCompany public exchangeToken;

    /**
    * @dev map that keeps track of company prices
    */
    mapping(address => uint256) public listedCompanyPrices;

    /**
    * @dev array with addresses of listed companies
    */
    IPrivateCompany[] public listedCompanies;

    /**
    * @dev map with owner's owned company addresses
    */
    mapping(address => IPrivateCompany[]) public ownerCompanies;

    /**
    * @dev variable to store emergency stop variable
    */
    bool private _openMode;

    /**
    * @dev variable with company factory address
    */
    IPrivateCompanyFactory private _companyFactory;

    event ExchangeClosed();
    event ExchangeOpened();
    event CompanyPriceUpdated(address indexed company, uint256 price);
    event CompanyListed(address indexed owner, address indexed company);
    event CompanyDelisted(address indexed owner, address indexed company);
    event ExchangeTokenBought(address indexed account, uint256 amount);
    event ExchangeTokenSold(address indexed account, uint256 amount);

    event ShareTransaction(
        address indexed company,
        address indexed buyer,
        address indexed seller,
        uint256 amount,
        uint256 price
    );

    modifier onlyOpen() {
        require(isOpen(), "not in open mode");
        _;
    }

    /**
    * @dev this function is called by the proxy on initialization
    * NOTE: logic owner MUST be different from proxy owner 
    * Read more at: https://blog.openzeppelin.com/proxy-patterns/
    * @param owner logic owner of this exchange.
    * @param companyFactory address of factory
    * @param name token name for exchange-token
    * @param symbol symbol name for exchange-token
    */
    function initialize(
        address owner,
        address companyFactory,
        string memory name,
        string memory symbol
    ) public initializer {
        _transferOwnership(owner);
        _openMode = false;
        _companyFactory = IPrivateCompanyFactory(companyFactory);
        exchangeToken = _makeExchangeToken(name, symbol);
    }


    /**
    * @return total number of listed companies
    */
    function numberOfListedCompanies() view public returns(uint256) {
        return listedCompanies.length;
    }

    /**
    * @return number of companies the msg.sender owns on exchange
    */
    function numberOfOwnedCompanies() view public returns(uint256) {
        return ownerCompanies[msg.sender].length;
    }

    /**
    * @return whether exchange is open
    */
    function isOpen() public view returns (bool) {
        return _openMode;
    }

    /**
    * @return the exchange token allowance given to the exchange
    */
    function exchangeTokenStaked() public view returns(uint256) {
        return exchangeToken.allowance(msg.sender, address(this));
    }

    /**
    * @return the exchange token balance of a user
    */
    function exchangeTokenBalance() public view returns(uint256) {
        return exchangeToken.balanceOf(msg.sender);
    }
    
    /**
    * @dev allows user to use ether to exchange 1 to 1 for exchange tokens
    * note that the ether must be carried in a msg.value 
    */
    function buyExchangeToken() public payable onlyOpen {
        require(msg.value>0, "value needs to be non-zero");
        exchangeToken.mint(msg.value);
        exchangeToken.transfer(msg.sender, msg.value);
        emit ExchangeTokenBought(msg.sender, msg.value);
    }

    /**
    * @dev allows user to exchange their exchange tokens for ether
    * user must provide an allowance for the exchange to transferFrom
    * @param amount amount of exchange tokens to sell
    */
    function sellExchangeToken(uint256 amount) public payable onlyOpen {
        exchangeToken.transferFrom(msg.sender, address(this), amount);
        exchangeToken.burn(amount);
        msg.sender.transfer(amount);
    }

    /**
    * @dev issue a buy transaction on the exchange. Note amount param!
    * because we defined price as per ether unit of shares, 
    * we must divide the price by 1 ether unit 
    * when we calculate the cost to the buyer as amount is given in wei
    * @param company address of company that MUST be listed in listedCompanies 
    * @param amount amount of shares to buy in wei units
    */
    function buyCompanyShares(address company, uint256 amount) public onlyOpen {
        require(_isListedCompany(company), "not a listed company");
        uint256 price = listedCompanyPrices[company];
        address buyer = msg.sender;
        IPrivateCompany pc = IPrivateCompany(company);
        address seller = pc.owner();
        uint256 cost = amount.mul(price).div(1 ether);
        uint256 sharesAvailable = pc.allowance(seller, address(this));
        require(
            sharesAvailable >= amount,
            "seller does not have enough shares to fill transaction"
        );
        require(
            exchangeToken.allowance(buyer, address(this)) >= cost,
            "buyer does not have enough exchange tokens to fill transaction"
        );
        pc.transferFrom(seller, buyer, amount);
        exchangeToken.transferFrom(buyer, seller, cost);
        emit ShareTransaction(company, buyer, seller, amount, price);
    }

    /**
    * @dev updates the price of a listed company.
    * @param company address of company that MUST be listed in listedCompanies 
    * @param price in EE$ per ONE ETH unit of shares in uint256. 
    * 1 price = 1 wei EE$ per share
    * OR 0.000000000000000001 EE$ per ONE ETH unit of shares
    */
    function updateCompanyPrice(
        address company,
        uint256 price
    ) public onlyOpen {
        uint256 _price = listedCompanyPrices[company];
        require(_price > 0, "company is not listed");
        IPrivateCompany pc = IPrivateCompany(company);
        require(
            pc.owner() == msg.sender, 
            "price-setter is not the company owner"
        );
        require(price > 0 , "price is not set as a positive integer");
        _updateCompanyPrice(company, price);
    }

    /**
    * @dev allows user to create a company and list on exchange
    * @param name of company cannot be empty string
    * @param symbol of company cannot be empty string
    * @param price in EE$ per ONE ETH unit of shares in uint256. 
    * 1 price = 1 wei EE$ per share
    * OR 0.000000000000000001 EE$ per ONE ETH unit of shares
    */
    function createCompanyAndList(
        string memory name,
        string memory symbol,
        uint256 price
    ) public onlyOpen {
        bytes32 emptyString = keccak256(abi.encodePacked(""));
        require(
            keccak256(abi.encodePacked(name)) != emptyString,
            "empty name given"
        );
        require(
            keccak256(abi.encodePacked(symbol)) != emptyString,
            "empty symbol given"
        );
        address companyOwner = msg.sender;
        IPrivateCompany c = _createCompany(companyOwner, name, symbol);
        _listCompany(c);
        _updateCompanyPrice(address(c), price);
    }

    /**
    * @dev allows owner to list an external ERC20-compliant entity on exchange
    * @param company address of contract
    * @param price in EE$ per ONE ETH unit of shares in uint256. 
    */
    function listCompany(address company, uint256 price) public onlyOwner {
        IPrivateCompany pc = IPrivateCompany(company);
        _updateCompanyPrice(company, price);
        _listCompany(pc);
    }

    /**
    * @dev allows owner to delist an entity on exchange
    * @param company address of contract
    */
    function delistCompany(address company) public onlyOwner {
        _delistCompany(IPrivateCompany(company));
    }

    /**
    * @dev emergency stop open function used by owner
    * @param value true to open, false to close
    */
    function switchOpenMode(bool value) public onlyOwner {
        _openMode = value;
        if (value){
            emit ExchangeOpened();
        }
        else {
            emit ExchangeClosed();
        }
    }

    /**
    * @dev allows owner to provide a new company factory 
    * @param companyFactory address of new factory
    */
    function upgradeCompanyFactory(address companyFactory) public onlyOwner {
        _companyFactory = IPrivateCompanyFactory(companyFactory);
    }

    function _isListedCompany(address company) internal view returns(bool) {
        return listedCompanyPrices[company] > 0;
    }

    function _makeExchangeToken(
        string memory name,
        string memory symbol
    ) internal returns (IPrivateCompany) {
        return _createCompany(address(this), name, symbol);
    }

    function _createCompany(
        address companyOwner,
        string memory name,
        string memory symbol
    ) 
    internal returns(IPrivateCompany) {
        address c = _companyFactory.newCompany(companyOwner, name, symbol);
        return IPrivateCompany(c); 
    }

    function _updateCompanyPrice(address company, uint256 price) internal {
        listedCompanyPrices[company] = price;
        emit CompanyPriceUpdated(company, price);
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
                listedCompanies[i] =
                    listedCompanies[listedCompanies.length - 1];
                listedCompanies.pop();
                break;
            }
        }
        IPrivateCompany[] storage ownedCompanies = 
            ownerCompanies[company.owner()];
        for (uint i = 0; i < ownedCompanies.length; i++ )
        {
            if (ownedCompanies[i] == company)
            {
                ownedCompanies[i] = ownedCompanies[ownedCompanies.length - 1];
                ownedCompanies.pop();
                break;
            }
        }
        emit CompanyDelisted(company.owner(), address(company));
    }
}