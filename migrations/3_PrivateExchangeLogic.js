const PrivateExchangeLogic = artifacts.require("PrivateExchangeLogic");

module.exports = async function(deployer, network, accounts) {
  const proxyAdmin = accounts[0];
  await deployer.deploy(PrivateExchangeLogic, {
    from: proxyAdmin
  });
};
