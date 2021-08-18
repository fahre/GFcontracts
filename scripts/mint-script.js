// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you’ll find the Hardhat
// Runtime Environment’s members available in the global scope.

const BigNumber = require("bignumber.js");
const Web3 = require("web3");
const fs = require("fs");

// const hre = require("hardhat");
async function main() {
  const web3 = new Web3("https://rpc-mumbai.maticvigil.com");
  const NFT_ADDRESS = "0xC52e32CaF4becF2a93074A986DF401D70E725746";
  const account = web3.eth.accounts.privateKeyToAccount(
    "3208fbf74c9377ad0e7fc164f995bb90f77063390f794d3ce9d617dce2cff467"
  );
  const nft = new web3.eth.Contract(
    JSON.parse(fs.readFileSync("./artifacts/contracts/NFT.sol/NFT.json", "utf-8")).abi,
    NFT_ADDRESS
  );

  console.log("Deploying contracts with the account:", account.address);
  const testNumber = new BigNumber(1);

  const abi = await nft.methods
    .mintNFT(
      "test",
      "Test",
      "0x3f4DE0a013C4c5c2fD890A191680D8CFdBf11E1B",
      testNumber.toFixed(),
      testNumber.toFixed(),
      "testing attention pls"
    )
    .encodeABI();
  const hashedTxn = await account.signTransaction({
    from: account.address,
    to: NFT_ADDRESS,
    data: abi,
    gas: 300000,
  });
  console.log(hashedTxn);
  console.log(
    "Minted NFT address:",
    await web3.eth.sendSignedTransaction(hashedTxn.rawTransaction)
  );
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
