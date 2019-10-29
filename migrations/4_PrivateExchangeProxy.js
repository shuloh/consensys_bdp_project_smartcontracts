const PrivateExchangeProxy = artifacts.require("PrivateExchangeProxy");
const PrivateExchangeLogic = artifacts.require("PrivateExchangeLogic");
const PrivateCompanyFactory = artifacts.require("PrivateCompanyFactory");

module.exports = async function(deployer, network, accounts) {
  const proxyAdmin = accounts[0];
  const logicAdmin = accounts[1];
  await deployer.deploy(PrivateExchangeProxy, {
    from: proxyAdmin
  });
  let proxy = await PrivateExchangeProxy.deployed();
  let logic = await PrivateExchangeLogic.deployed();
  let factory = await PrivateCompanyFactory.deployed();
  await proxy.initialize(
    logic.address,
    proxyAdmin,
    web3.eth.abi.encodeFunctionCall(
      {
        name: "initialize",
        type: "function",
        inputs: [
          {
            type: "address",
            name: "owner"
          },
          {
            type: "address",
            name: "companyFactory"
          },
          {
            type: "string",
            name: "exchangeTokenName"
          },
          {
            type: "string",
            name: "exchangeTokenSymbol"
          }
        ]
      },
      [logicAdmin, factory.address, "ENTANGLEMENT", "ETGMT"]
    )
  );
};
