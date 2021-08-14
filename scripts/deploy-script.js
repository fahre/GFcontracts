// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you’ll find the Hardhat
// Runtime Environment’s members available in the global scope.
const hre = require("hardhat");
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(deployer.address);
  const Buffer = await ethers.getContractFactory("buffer");
  const buffer = await Buffer.deploy();
  const Market = await ethers.getContractFactory("NFTmarketplace");
  const market = await Market.deploy(deployer.address);
  const LockContract = await ethers.getContractFactory("lockContract");
  const lockContract = await LockContract.deploy(deployer.address);
  console.log("NFT deployed to:", nft.address);
  console.log("Buffer deployed to:", buffer.address);
  console.log("Market deployed to:", market.address);
  console.log("LockContract deployed to:", lockContract.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 
