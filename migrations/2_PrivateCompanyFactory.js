const PrivateCompanyFactory = artifacts.require("PrivateCompanyFactory");

module.exports = async function(deployer, network, accounts) {
  const proxyAdmin = accounts[0];
  await deployer.deploy(PrivateCompanyFactory, {
    from: proxyAdmin
  });
};
