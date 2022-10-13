const hre = require("hardhat");

async function main() {
  const chainBattlesFactory = await hre.ethers.getContractFactory(
    "ChainBattles"
  );
  const chainBattles = await chainBattlesFactory.deploy();
  await chainBattles.deployed();

  console.log(`ChainBattles contract deployed to: ${chainBattles.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
