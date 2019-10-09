const PrivSecMarket = artifacts.require("PrivSecMarket");

module.exports = function(deployer) {
  deployer.deploy(PrivSecMarket);
};
