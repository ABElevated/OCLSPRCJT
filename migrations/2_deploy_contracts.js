var OclsToken = artifacts.require("./OclsToken.sol");
var OclsPresale = artifacts.require("./OclsPresale.sol");

module.exports = function(deployer) {
  deployer.deploy(OclsToken);
  deployer.link(OclsToken, OclsPresale);
  deployer.deploy(OclsPresale, "0x687A3e732D5e3cA30A268f47Cc63657fD243109d", 40, 80);
};
