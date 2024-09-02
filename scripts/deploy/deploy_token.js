const hre = require("hardhat");

async function main() {
  const Token = await hre.ethers.getContractFactory("BloomexToken");
  const token = await Token.deploy();

  await token.deployed();

  console.log("Token deployed to:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
