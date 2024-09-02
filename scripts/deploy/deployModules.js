const hre = require("hardhat");

async function main() {
  const StunessTokenization = await hre.ethers.getContractFactory("BusinessTokenization");
  const tokenization = await BisunessTokenization.deploy();
  await tokenization.deployed();
  console.log("Business Tokenization Module deployed to:", tokenization.address);

  // Повторите для других модулей
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
