const PrivateExchangeProxy = artifacts.require("PrivateExchangeProxy");
const PrivateExchangeLogic = artifacts.require("PrivateExchangeLogic");
contract("Proxy and Logic initializers and authority", async function(
  accounts
) {
  beforeEach(async function() {
    this.proxyAdmin = accounts[0];
    this.logicAdmin = accounts[1];
    this.normalAccount = accounts[2];
    this.proxy = await PrivateExchangeProxy.deployed();
    this.logic = await PrivateExchangeLogic.deployed();
    this.logicProxied = await PrivateExchangeLogic.at(this.proxy.address);
  });
  it("proxy initialized, logic initialized", async function() {
    assert(await this.logic.owner.call(), accounts[0]);
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
              }
            ]
          },
          [this.logicAdmin]
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
  it("exchange initialized with openMode set to false", async function() {
    const got = await this.logicProxied.isOpen.call({
      from: this.normalAccount
    });
    const want = false;
    assert.equal(got, want);
  });
  it("non-logic admin cannot call switchOpenMode onlyOwner func", async function() {
    try {
      assert(
        await this.logicProxied.switchOpenMode(true, {
          from: this.normalAccount
        }),
        false
      );
    } catch (e) {
      assert(e.toString().includes("Ownable: caller is not the owner"));
    }
  });
  it("logic admin calls switchOpenMode onlyOwner func successfully", async function() {
    assert(
      await this.logicProxied.switchOpenMode(true, { from: this.logicAdmin })
    );
  });
  it("logicProxy openMode updated from false to true", async function() {
    let got = await this.logicProxied.isOpen.call({ from: this.normalAccount });
    let want = true;
    assert.equal(got, want);
  });
});
