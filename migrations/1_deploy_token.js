var EIP20Token = artifacts.require("./EIP20Token.sol");

module.exports = function(deployer) {
  deployer.deploy(EIP20Token);
};
