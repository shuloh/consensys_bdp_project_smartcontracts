const PrivateExchangeProxy = artifacts.require("PrivateExchangeProxy");
const PrivateExchangeLogic = artifacts.require("PrivateExchangeLogic");
const PrivateCompanyFactory = artifacts.require("PrivateCompanyFactory");

contract("Proxy and Logic initializers and authority", async function(
  accounts
) {
  before(async function() {
    this.proxyAdmin = accounts[0];
    this.logicAdmin = accounts[1];
    this.normalAccount = accounts[2];
    this.newProxyAdmin = accounts[3];
    this.proxy = await PrivateExchangeProxy.deployed();
    this.logic = await PrivateExchangeLogic.deployed();
    this.companyFactory = await PrivateCompanyFactory.deployed();
    this.logicProxied = await PrivateExchangeLogic.at(this.proxy.address);
    this.newLogicUpgrade = await PrivateExchangeLogic.new();
    this.newLogicUpgradeAndCall = await PrivateExchangeLogic.new();
  });

  it("proxy initialized, logic initialized", async function() {
    await this.proxy.initialize(
      this.logic.address,
      this.proxyAdmin,
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
        [this.logicAdmin, this.companyFactory.address, "ENTANGLEMENT", "ETGMT"]
      )
    ),
      { from: this.proxyAdmin };
  });
  it("proxy admin confirmed", async function() {
    const got = await this.proxy.admin.call({ from: this.proxyAdmin });
    const want = this.proxyAdmin;
    assert.equal(got, want);
  });

  it("logic admin confirmed", async function() {
    const got = await this.logicProxied.owner.call({
      from: this.normalAccount
    });
    const want = this.logicAdmin;
    assert.equal(got, want);
  });
  it("right implementation address", async function() {
    const got = await this.proxy.implementation.call({
      from: this.proxyAdmin
    });
    const want = this.logic.address;
    assert.equal(got, want);
  });
  it("change admin of proxy possible", async function() {
    await this.proxy.changeAdmin(this.newProxyAdmin, {
      from: this.proxyAdmin
    });
    const got = await this.proxy.admin.call({ from: this.newProxyAdmin });
    const want = this.newProxyAdmin;
    assert.equal(got, want);
  });
  it("upgrade of logic proxied contract possible", async function() {
    await this.proxy.upgradeTo(this.newLogicUpgrade.address, {
      from: this.newProxyAdmin
    });
    const got = await this.proxy.implementation.call({
      from: this.newProxyAdmin
    });
    const want = this.newLogicUpgrade.address;
    const got2 = await this.logicProxied.owner.call({
      from: this.normalAccount
    });
    const want2 = this.logicAdmin;
    assert.equal(got2, want2);
    await this.logicProxied.reinitialize(
      this.logicAdmin,
      this.companyFactory.address,
      "TESTNAME",
      "TESTSYM",
      { from: this.logicAdmin }
    );
  });
  it("upgrade and call of logic proxied contract possible", async function() {
    console.log(this.newLogicUpgradeAndCall.address);
    await this.proxy.upgradeToAndCall(
      this.newLogicUpgradeAndCall.address,
      web3.eth.abi.encodeFunctionCall(
        {
          name: "reinitialize",
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
        [this.logicAdmin, this.companyFactory.address, "ENTANGLEMENT", "ETGMT"]
      ),
      {
        from: this.proxyAdmin
      }
    );
    // const got = await this.proxy.implementation.call({
    //   from: this.newProxyAdmin
    // });
    // const want = this.newLogicUpgradeAndCall.address;
    // assert.equal(got, want);
  });
});
