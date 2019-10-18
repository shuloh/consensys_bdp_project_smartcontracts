const PrivateExchangeProxy = artifacts.require("PrivateExchangeProxy");
const PrivateExchangeLogic = artifacts.require("PrivateExchangeLogic");
const PrivateCompanyFactory = artifacts.require("PrivateCompanyFactory");
const IPrivateCompany = artifacts.require("IPrivateCompany");
const PrivateCompany = artifacts.require("PrivateCompany");

contract("Private Exchange Actions", async function(accounts) {
  before(async function() {
    this.proxyAdmin = accounts[0];
    this.logicAdmin = accounts[1];
    this.normalAccount = accounts[2];
    this.proxy = await PrivateExchangeProxy.deployed();
    this.logic = await PrivateExchangeLogic.deployed();
    this.companyFactory = await PrivateCompanyFactory.deployed();
    this.logicProxied = await PrivateExchangeLogic.at(this.proxy.address);
    //initializer function has been tested below in Setup test
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
    );
  });

  it("exchange initialized with openMode set to false", async function() {
    const got = await this.logicProxied.isOpen.call({
      from: this.normalAccount
    });
    const want = false;
    assert.equal(got, want);
  });

  it("non-exchange owner cannot call switchOpenMode onlyOwner func", async function() {
    try {
      assert.equal(
        await this.logicProxied.switchOpenMode(true, {
          from: this.normalAccount
        }),
        false
      );
    } catch (e) {
      assert(e.toString().includes("Ownable: caller is not the owner"));
    }
  });

  it("cannot call createAndListCompany when OpenMode is false", async function() {
    try {
      assert.equal(
        await this.logicProxied.createCompanyAndList("COMPANY1", "COY1", {
          from: this.normalAccount
        }),
        false
      );
    } catch (e) {
      assert(e.toString().includes("not in open mode"));
    }
  });

  it("logic admin calls switchOpenMode onlyOwner func successfully", async function() {
    await this.logicProxied.switchOpenMode(true, { from: this.logicAdmin });
  });

  it("logicProxy openMode updated from false to true", async function() {
    let got = await this.logicProxied.isOpen.call({ from: this.normalAccount });
    let want = true;
    assert.equal(got, want);
  });

  it("logicAdmin can createCompanyAndList when OpenMode is true", async function() {
    await this.logicProxied.createCompanyAndList("COMPANY1", "COY1", {
      from: this.logicAdmin
    });
  });

  it("logicAdmin has 1 company on platform", async function() {
    const ownedCompanies = await this.logicProxied.numberOfOwnedCompanies.call({
      from: this.logicAdmin
    });
    assert.equal(ownedCompanies, 1);
  });

  it("logicAdmin can mint 1000 shares and list them on platform", async function() {
    const coy1address = await this.logicProxied.ownerCompanies.call(
      this.logicAdmin,
      0,
      { from: this.logicAdmin }
    );
    const coy1 = await IPrivateCompany.at(coy1address);
    await coy1.mint(1000, { from: this.logicAdmin });
    await coy1.approve(this.proxy.address, 1000, { from: this.logicAdmin });
  });

  it("normalUser can createCompanyAndList", async function() {
    assert(
      await this.logicProxied.createCompanyAndList("COMPANY2", "COY2", {
        from: this.normalAccount
      })
    );
  });

  it("normalUser has 1 company on platform", async function() {
    const ownedCompanies = await this.logicProxied.numberOfOwnedCompanies.call({
      from: this.normalAccount
    });
    assert.equal(ownedCompanies, 1);
  });

  it("normalUser can mint 1000 shares and list them on platform", async function() {
    const index = 0;
    const coy2address = await this.logicProxied.ownerCompanies.call(
      this.normalAccount,
      index,
      { from: this.normalAccount }
    );
    const coy2 = await IPrivateCompany.at(coy2address);
    await coy2.mint(1000, { from: this.normalAccount });
    await coy2.approve(this.proxy.address, 1000, { from: this.normalAccount });
  });

  it("normalUser can create more than 1 company on platform", async function() {
    assert(
      await this.logicProxied.createCompanyAndList("COMPANY3", "COY3", {
        from: this.normalAccount
      })
    );
    const ownedCompanies = await this.logicProxied.numberOfOwnedCompanies.call({
      from: this.normalAccount
    });
    assert.equal(ownedCompanies, 2);
    const index = 1;
    const coy3address = await this.logicProxied.ownerCompanies.call(
      this.normalAccount,
      1,
      { from: this.normalAccount }
    );
    const coy3 = await IPrivateCompany.at(coy3address);
    assert(await coy3.mint(2000, { from: this.normalAccount }));
    assert(
      await coy3.approve(this.proxy.address, 2000, { from: this.normalAccount })
    );
  });

  it("total number of listed companies is 3", async function() {
    const got = await this.logicProxied.numberOfListedCompanies.call({
      from: this.normalAccount
    });
    const want = 3;
    assert.equal(got.toNumber(), want);
  });

  it("check properties of the 3 companies", async function() {
    for (var i = 0; i < 3; i++) {
      const a = await this.logicProxied.listedCompanies.call(i, {
        from: this.normalAccount
      });
      const c = await IPrivateCompany.at(a);
      const owner = await c.owner.call();
      const name = await c.name.call();
      const symbol = await c.symbol.call();
      const sharesListed = (await c.allowance.call(
        owner,
        this.proxy.address
      )).toNumber();

      const wantName = "COMPANY" + (i + 1);
      assert.equal(name, wantName);

      const wantSymbol = "COY" + (i + 1);
      assert.equal(symbol, wantSymbol);

      const wantOwner =
        i == 0
          ? this.logicAdmin
          : i == 1
          ? this.normalAccount
          : i == 2
          ? this.normalAccount
          : address(0);
      assert.equal(owner, wantOwner);

      const wantSharesListed =
        i == 0 ? 1000 : i == 1 ? 1000 : i == 2 ? 2000 : 0;
      assert.equal(sharesListed, wantSharesListed);
    }
  });
});
