pragma solidity 0.5.12;

interface IPrivateCompany {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool); 

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);    

    function decimals() external view returns (uint8); 

    function owner() external view returns (address);

    function isOwner() external view returns (bool);

    //onlyOwner
    function renounceOwnership() external;

    //onlyOwner
    function transferOwnership(address newOwner) external;

    //onlyOwner
    function mint(uint256 amount) external;

    //onlyOwner
    function burn(uint256 amount) external;

}
