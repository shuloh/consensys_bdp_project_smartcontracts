const PrivateExchangeProxy = artifacts.require("PrivateExchangeProxy");
const PrivateExchangeLogic = artifacts.require("PrivateExchangeLogic");
const PrivateCompanyFactory = artifacts.require("PrivateCompanyFactory");

module.exports = async (deployer, network, accounts) => {
  const proxy = await deployer.deploy(PrivateExchangeProxy, {
    from: accounts[0]
  });
  const logic = await deployer.deploy(PrivateExchangeLogic, {
    from: accounts[0]
  });
  await deployer.deploy(PrivateCompanyFactory, proxy.address, {
    from: accounts[0]
  });
};
