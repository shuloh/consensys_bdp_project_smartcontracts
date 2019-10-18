const PrivateExchangeProxy = artifacts.require("PrivateExchangeProxy");
const PrivateExchangeLogic = artifacts.require("PrivateExchangeLogic");
const PrivateCompanyFactory = artifacts.require("PrivateCompanyFactory");

module.exports = async function(deployer, network, accounts) {
  const proxyAdmin = accounts[0];
  await deployer.deploy(PrivateExchangeProxy, {
    from: proxyAdmin
  });
  await deployer.deploy(PrivateCompanyFactory, {
    from: proxyAdmin
  });
  await deployer.deploy(PrivateExchangeLogic, {
    from: proxyAdmin
  });
};
