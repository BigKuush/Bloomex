const hre = require("hardhat");

async function updateContracts() {
  const tokenAddress = '0x...'; // Адрес токена
  const Token = await hre.ethers.getContractAt("BloomexToken", tokenAddress);

  // Обновление параметров
  const tx = await Token.updateSomeParameter(new_value);
  await tx.wait();
  console.log("Contracts updated successfully");
}

updateContracts()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
