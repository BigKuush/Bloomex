const hre = require("hardhat");

async function main() {
  const tokenAddress = '0x...'; // Адрес уже развернутого токена
  const Token = await hre.ethers.getContractAt("BloomexToken", tokenAddress);

  // Установка параметров
  const tx = await Token.setSomeParameter(value);
  await tx.wait();
  console.log("Initial setup completed");
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
