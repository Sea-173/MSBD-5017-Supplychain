import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployLoyaltyPoints: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const tokenName = "LoyaltyPointsToken";
  const monthlyAverageProfit = 100000;

  await deploy("LoyaltyPoints", {
    from: deployer,
    args: [tokenName, monthlyAverageProfit, deployer],
    log: true,
    autoMine: true,
  });

  const loyaltyPoints = await hre.ethers.getContract<Contract>("LoyaltyPoints", deployer);
  console.log("👋 Deployer:", deployer);
  console.log("👋 Initial token name:", await loyaltyPoints.name);
  console.log("👋 Initial token value in USDT:", await loyaltyPoints.Token_Value_in_USDT());
  // const address = loyaltyPoints.generateMintingAddressesA(100);
  console.log("👋 address:", await loyaltyPoints.generateMintingAddressesA(100));
  // loyaltyPoints.withdrawTokens(loyaltyPoints.generateMintingAddressesA(100));
  // 转移 owner 给 0x7424B30007Cd05fEc50cC5790d1be8E58d4e0489
  const newOwner = "0x3Ae99C4621759137E10Ee75860f39C1060049bfF";
  await loyaltyPoints.transferOwnership(newOwner);
  console.log("👋 Ownership transferred to:", newOwner);
};

export default deployLoyaltyPoints;
deployLoyaltyPoints.tags = ["LoyaltyPoints"];