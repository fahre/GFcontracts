// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface IERC20{

  function transfer(address recipient, uint256 amount) external;
  
  function transferFrom(address sender, address recipient, uint256 amount) external;

}

interface INFT{
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    
    function balanceOf(address user) external view returns(uint256);
    
    function ownerOf(uint256 ID) external view returns(address);
    
    function aboutNFT(uint256 ID) external view returns(string memory name, string memory symbol, address owner, uint256 category, uint256 level, uint256 boxed1, uint256 boxed2, uint256 x, uint256 y, string memory more);
    
    function boxedNFTs(uint256 ID) external view returns(uint256);
    
    function boxedNFT(uint256 ID, uint256 index) external view returns(uint256);
    
    function forgeResult(uint256 firstNFT, uint256 secondNFT) external view returns(uint256 category, string memory name, string memory symbol);
    
    function modStats(address user) external view returns(bool);
    
    function transferFrom(address from, address to, uint256 tokenId) external;
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    
    function approve(address to, uint256 tokenId) external;
    
    function editCategory(uint256 category, bool destructable) external;
    
    function addMod(address user) external;
    
    function removeMod(address user) external;
    
    function mintNFT(string calldata name, string calldata symbol, address owner, uint256 category, uint256 level, string calldata more) external returns(uint256);
    
    function burnNFT(uint256 ID) external;
    
    function setlevelsPrices(uint256 ID, uint256 level1, uint256 level2, uint256 level3, uint256 level4, uint256 level5, uint256 level6, uint256 level7, uint256 level8, uint256 level9, uint256 level10) external;
    
    function upgrade(uint256 ID) external;
    
    function boxNFT(uint256 character, uint256 nft) external;
    
    function unboxNFT(uint256 character, uint256 nftIndex) external;
    
    function provideWithNGL(uint256 ID, uint256 amount) external;
    
    function removeNGL(uint256 ID, uint256 amount, address to) external;
    
    function moveBuilding(uint256 ID, uint256 newX, uint256 newY) external;
    
    function createForgeEquation(uint256 category1, uint256 category2, uint256 resultingCategory) external;
    
    function forge(uint256 tokenID, uint256 tokenID1) external returns(uint256);
    
    function unForge(uint256 tokenID) external returns(uint256 token1, uint256 token2);
    
}

contract NFT is INFT{
    
    IERC20 NGL;
    
    address private _contractOwner;
    uint256 private _NFTcount;
    
    mapping(address => bool) private _mod;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => mapping(uint256 => bool))) private _allowance;
    
    mapping(uint256 => string) private _name;
    mapping(uint256 => string) private _symbol;
    mapping(uint256 => address) private _owner;
    mapping(uint256 => uint256) private _category;
    
    mapping(uint256 => uint256) private _NGLbalance;
    
    mapping(uint256 => uint256) private _level;
    mapping(uint256 => mapping(uint256 => uint256)) private _levelPrice;
    mapping(uint256 => mapping(uint256 => uint256)) private _boxedNFT;
    mapping(uint256 => uint256) private _boxedNFTs;
    mapping(uint256 => string) private _more;
    
    mapping(uint256 => uint256) private _x;
    mapping(uint256 => uint256) private _y;
    
    mapping(uint256 => bool) private _forged;
    mapping(uint256 /*category*/ => mapping(uint256 /*category*/ => uint256 /*resulting category*/)) private _forgeEquation;
    mapping(uint256 /*category*/ => mapping(uint256 /*category*/ => string /*name of resulting category*/)) private _forgeName;
    mapping(uint256 /*category*/ => mapping(uint256 /*category*/ => string /*symbol of resulting category*/)) private _forgeSymbol;
    mapping(uint256 => uint256) private _boxed1; //first boxed NFT
    mapping(uint256 => uint256) private _boxed2; //second boxed NFT
    
    //Categories
    mapping(uint256 => bool) private _destructable;
    
    
    constructor(address NGLtoken){
        NGL = IERC20(NGLtoken);
        _contractOwner = msg.sender; 
    }
    
    function balanceOf(address user) external view override returns(uint256){
        return _balances[user];
    }
    
    function ownerOf(uint256 ID) external view override returns(address){
        return _owner[ID];
    }
    
    function aboutNFT(uint256 ID) external view override returns(string memory name, string memory symbol, address owner, uint256 category, uint256 level, uint256 boxed1, uint256 boxed2, uint256 x, uint256 y, string memory more){
        name = _name[ID];
        symbol = _symbol[ID];
        owner = _owner[ID];
        category = _category[ID];
        level = _level[ID];
        boxed1 = _boxed1[ID];
        boxed2 = _boxed2[ID];
        more = _more[ID];
        x = _x[ID];
        y = _y[ID];
    }
    
    function boxedNFTs(uint256 ID) external view override returns(uint256){
     return _boxedNFTs[ID];   
    }
    
    function boxedNFT(uint256 ID, uint256 index) external view override returns(uint256){
        return _boxedNFT[ID][index];
    }
    
    function forgeResult(uint256 firstNFT, uint256 secondNFT) external view override returns(uint256 category, string memory name, string memory symbol){
        category = _forgeEquation[firstNFT][secondNFT];
        name = _forgeName[firstNFT][secondNFT];
        symbol = _forgeSymbol[firstNFT][secondNFT];
    }
    
    function modStats(address user) external view override returns(bool){
        return _mod[user];
    }
    
    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(_owner[tokenId] == from);
        require(from == msg.sender || _allowance[from][msg.sender][tokenId]);
        if(_allowance[from][msg.sender][tokenId]){_allowance[from][msg.sender][tokenId] = false;}
        _balances[from] -= 1;
        _balances[to] += 1;
        _owner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        require(_owner[tokenId] == from);
        require(from == msg.sender || _allowance[from][msg.sender][tokenId]);
        if(_allowance[from][msg.sender][tokenId]){_allowance[from][msg.sender][tokenId] = false;}
        _balances[from] -= 1;
        _balances[to] += 1;
        _owner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    
    function approve(address to, uint256 tokenId) external override {
        require(msg.sender == _owner[tokenId]);
        _allowance[msg.sender][to][tokenId] = true;
        emit Approval(_owner[tokenId], to, tokenId);
    }
    
    function editCategory(uint256 category, bool destructable) external override {
        require(msg.sender == _contractOwner);
        _destructable[category] = destructable;
    }
    
    function addMod(address user) external override {
        require(msg.sender == _contractOwner);
        _mod[user] = true;
    }
    
    function removeMod(address user) external override {
        require(msg.sender == _contractOwner);
        _mod[user] = false;
    }
    
    function mintNFT(string calldata name, string calldata symbol, address owner, uint256 category, uint256 level, string calldata more) external override returns(uint256) {
        require(msg.sender == _contractOwner);
        return MintNFT(name, symbol, owner, category, level, more);
    }
    
    function burnNFT(uint256 ID) external override {
        require(_destructable[ID]);
        require(_owner[ID] == msg.sender);
        _owner[ID] = address(0);
        _balances[msg.sender] -= 1;
        emit Transfer(msg.sender, address(0), ID);
    }
    
    function setlevelsPrices(uint256 ID, uint256 level1, uint256 level2, uint256 level3, uint256 level4, uint256 level5, uint256 level6, uint256 level7, uint256 level8, uint256 level9, uint256 level10) external override {
        require(msg.sender == _contractOwner || _mod[msg.sender]);
        _levelPrice[ID][0] = level1;
        _levelPrice[ID][1] = level2;
        _levelPrice[ID][2] = level3;
        _levelPrice[ID][3] = level4;
        _levelPrice[ID][4] = level5;
        _levelPrice[ID][5] = level6;
        _levelPrice[ID][6] = level7;
        _levelPrice[ID][7] = level8;
        _levelPrice[ID][8] = level9;
        _levelPrice[ID][9] = level10;
    }
    
    function upgrade(uint256 ID) external override {
        uint256 price = _levelPrice[ID][_level[ID]];
        require(price > 0);
        NGL.transferFrom(msg.sender, address(this), price);
        ++_level[ID];
    }
    
    function boxNFT(uint256 character, uint256 nft) external override {
        require(_owner[character] == msg.sender || _owner[nft] == msg.sender);
        require(_category[character] == 0);
        _boxedNFT[character][_boxedNFTs[character]] = nft;
        _owner[nft] == address(0);
        ++_boxedNFTs[character];
    }
    
    function unboxNFT(uint256 character, uint256 nftIndex) external override {
        require(_owner[character] == msg.sender);
        uint256 nft = _boxedNFT[character][nftIndex];
        require(nft != 0);
        _boxedNFT[character][nftIndex] = 0;
        _owner[nft] = msg.sender;
    }
    
    function provideWithNGL(uint256 ID, uint256 amount) external override {
        require(_owner[ID] == msg.sender);
        NGL.transferFrom(msg.sender, address(this), amount);
        _NGLbalance[ID] += amount;
    }
    
    function removeNGL(uint256 ID, uint256 amount, address to) external override {
        require(_mod[msg.sender]);
        _NGLbalance[ID] -= amount;
        NGL.transfer(to, amount);
    }
    
    function moveBuilding(uint256 ID, uint256 newX, uint256 newY) external override {
        require(msg.sender == _owner[ID] && _mod[msg.sender]);
        _x[ID] = newX;
        _y[ID] = newY;
    }
    
    function createForgeEquation(uint256 category1, uint256 category2, uint256 resultingCategory) external override {
        require(msg.sender == _contractOwner);
        _forgeEquation[category1][category2] = resultingCategory;
    }
    
    function forge(uint256 tokenID, uint256 tokenID1) external override returns(uint256){
        require(_owner[tokenID] == msg.sender && _owner[tokenID1] == msg.sender);
        require(_forgeEquation[tokenID][tokenID1] != 0);
        _owner[tokenID] = address(0);
        _owner[tokenID1] = address(0);
        _balances[msg.sender] -= 1;
        emit Transfer(msg.sender, address(0), tokenID);
        emit Transfer(msg.sender, address(0), tokenID1);
        uint256 nft =  MintNFT(_forgeName[tokenID][tokenID1], _forgeSymbol[tokenID][tokenID1], msg.sender, _forgeEquation[tokenID][tokenID1], 0, ""); 
        _boxed1[nft] = tokenID;
        _boxed2[nft] = tokenID1;
        return nft;
    }
    
    function unForge(uint256 tokenID) external override returns(uint256 token1, uint256 token2){
        require(_owner[tokenID] == msg.sender);
        _owner[tokenID] = address(0);
        emit Transfer(msg.sender, address(0), tokenID);
        token1 = _boxed1[tokenID];
        token2 = _boxed2[tokenID];
        _owner[token1] = msg.sender;
        _owner[token2] = msg.sender;
        emit Transfer(address(0), _owner[token1], token1);
        emit Transfer(address(0), _owner[token2], token2);
    }
    
    function MintNFT(string memory name, string memory symbol, address owner, uint256 category, uint256 level, string memory more) internal returns(uint256) {
        uint256 nft = _NFTcount;
        _name[nft] = name;
        _symbol[nft] = symbol;
        _owner[nft] = owner;
        _category[nft] = category;
        _level[nft] = level;
        _more[nft] = more;
        ++_NFTcount;
        ++_balances[owner];
        emit Transfer(address(0), owner, nft);
        return nft;
    }
 //   function boxNFT(uint256 NFT, uint256 ToBeBoxedNFT) external{}
}
