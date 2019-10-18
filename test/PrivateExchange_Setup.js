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
    this.proxy = await PrivateExchangeProxy.deployed();
    this.logic = await PrivateExchangeLogic.deployed();
    this.companyFactory = await PrivateCompanyFactory.deployed();
    this.logicProxied = await PrivateExchangeLogic.at(this.proxy.address);
  });

  it("proxy initialized, logic initialized", async function() {
    assert(
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
          [
            this.logicAdmin,
            this.companyFactory.address,
            "ENTANGLEMENT",
            "ETGMT"
          ]
        )
      )
    );
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
});
