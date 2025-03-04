const ControleMarchandise = artifacts.require("ControleMarchandise");

module.exports = function (deployer) {
  deployer.deploy(ControleMarchandise);
};