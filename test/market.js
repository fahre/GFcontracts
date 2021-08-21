const BigNumber = require("bignumber.js");

const ERC20 = artifacts.require("contracts/contracts.sol:ERC20");
const MarketContract = artifacts.require("NFTmarketplace");
const NftContract = artifacts.require("NFT");

describe("Market contract", function () {
  let accounts;

  before(async function () {
    accounts = await web3.eth.getAccounts();
    console.log(accounts);
  });

  contract("Deployment", function () {
    it("Should deploy with the right greeting", async function () {
      console.log(accounts);
      const totalSupply = new BigNumber(1e27);
      const NGL = await ERC20.new("NGL", "NGL", totalSupply.toFixed());
      console.log(NGL.address);
      const NFT = await NftContract.new(NGL.address);
      console.log(NFT.address);
      const market = await MarketContract.new(NGL.address);
      console.log(market.address);
      console.log(accounts[0]);
      const mintRes = await NFT.mintNFT(
        "test",
        "Test",
        accounts[0],
        0,
        0,
        "testing attention pls",
        {
          from: accounts[0],
        }
      );
      const nftId = 0; // always 0 since the contract is brand n ew
      console.log(await NFT.approve(market.address, nftId, { from: accounts[0] }));
      console.log(await market.createSellOrder(NFT.address, nftId, 100, { from: accounts[0] }));
    }).timeout(60000);
  });
});
