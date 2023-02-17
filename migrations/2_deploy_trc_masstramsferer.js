var TrcMassTransferer = artifacts.require("./TrcMassTransferer.sol");

module.exports = function(deployer) {
  deployer.deploy(TrcMassTransferer);
};
