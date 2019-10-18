pragma solidity 0.5.12;
import "@openzeppelin/upgrades/contracts/upgradeability/InitializableAdminUpgradeabilityProxy.sol";

interface IPrivateExchangeProxy {
    /**
    * Contract initializer.
    * @param _logic address of the initial implementation.
    * @param _admin Address of the proxy administrator.
    * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
    * It should include the signature and the parameters of the function to be called, as described in
    * https://solidity.readthedocs.io/en/v0.5.12/abi-spec.html#function-selector-and-argument-encoding.
    * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
    */
    function initialize(address _logic, address _admin, bytes calldata _data) payable external;

    /**
    * @return The address of the proxy admin.
    */
    function admin() external returns (address);

    /**
    * @return The address of the implementation.
    */
    function implementation() external returns (address);

    /**
    * @dev Changes the admin of the proxy.
    * Only the current admin can call this function.
    * @param newAdmin Address to transfer proxy administration to.
    */
    function changeAdmin(address newAdmin) external;

    /**
    * @dev Upgrade the backing implementation of the proxy.
    * Only the admin can call this function.
    * @param newImplementation Address of the new implementation.
    */
    function upgradeTo(address newImplementation) external;

    /**
    * @dev Upgrade the backing implementation of the proxy and call a function
    * on the new implementation.
    * This is useful to initialize the proxied contract.
    * @param newImplementation Address of the new implementation.
    * @param data Data to send as msg.data in the low level call.
    * It should include the signature and the parameters of the function to be called, as described in
    * https://solidity.readthedocs.io/en/v0.5.12/abi-spec.html#function-selector-and-argument-encoding.
    */
    function upgradeToAndCall(address newImplementation, bytes calldata data) payable external;
}

contract PrivateExchangeProxy is IPrivateExchangeProxy, InitializableAdminUpgradeabilityProxy {

}