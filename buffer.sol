// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface IERC20{

  function transfer(address recipient, uint256 amount) external;
  
  function transferFrom(address sender, address recipient, uint256 amount) external;

}

interface INFT{
    
    function aboutNFT(uint256 ID) external view returns(string memory name, string memory symbol, address owner, uint256 category, uint256 level, uint256 boxed1, uint256 boxed2, uint256 x, uint256 y, string memory more);
    
    function nglOfNFT(uint256 ID) external view returns(uint256 category, uint256 ngl);
    
    function transferFrom(address from, address to, uint256 tokenId) external;
    
    function burnNFT(uint256 ID) external;
    
    function boxedNFT(uint256 ID, uint256 index) external view returns(uint256);
    
    function removeNGL(uint256 ID, uint256 amount, address to) external;
    
    function unboxNFT(uint256 character, uint256 nftIndex) external;
    
}

interface Ibuffer{
    
    function aboutGame(uint256 game) external view returns(address owner, uint256 field, uint256 share, uint256 total, uint256 ending, uint256 fee, uint256 participants);
   
   function aboutUser(address user) external view returns(uint256 character, uint256 game, uint256 gameIndex);
   
   function startGame(uint256 miningFeild, uint256 duration, uint256 participationFee, uint256 minersShare, uint256 toBeWithdrawn) external;
   
   function deployCharacter(uint256 ID) external;
   
   function removeCharacter() external;
   
   function joinGame(uint256 game) external;
   
   function leaveGame(uint256 game) external;
   
   function endGame(uint256 game) external;
   
   function destoryNFT(uint256 character, uint256 indexOfNftToDestroy) external;
}

contract buffer is Ibuffer{
    
    IERC20 NGL;
    INFT NFT;
    
    address private _contractOwner;
    
   mapping(address => uint256) private _NFTowner;
   mapping(uint256 => address) private _owner;
   
   mapping(address => uint256) private _game;
   
   mapping(address => uint256) private _NFTminingFieldOwner;
   mapping(uint256 => address) private _miningFieldOwner;
   
   uint256 _games = 1;
   mapping(uint256 => address) private _fieldOwner;
   mapping(uint256 => uint256) private _field; //NFT ID
   mapping(uint256 => uint256) private _minersShare;
   mapping(uint256 => uint256) private _toBeWithdrawn;
   mapping(uint256 => uint256) private _endingBlock;
   mapping(uint256 => uint256) private _participationFee;
   mapping(uint256 => uint256) private _participants;
   mapping(uint256 => mapping (uint256 => address)) private _participant;
   mapping(address => uint256) private _gameIndex;
   //mapping
   
   function aboutGame(uint256 game) external view override returns(address owner, uint256 field, uint256 share, uint256 total, uint256 ending, uint256 fee, uint256 participants){
       owner = _fieldOwner[game];
       field = _field[game];
       share = _minersShare[game];
       total = _toBeWithdrawn[game];
       ending = _endingBlock[game];
       fee = _participationFee[game];
       participants = _participants[game];
   }
   
   function aboutUser(address user) external view override returns(uint256 character, uint256 game, uint256 gameIndex){
       character = _NFTowner[user];
       game = _game[msg.sender];
       if(game != 0){gameIndex = _gameIndex[msg.sender];}
       else{gameIndex = 0;}
   }
   
   function startGame(uint256 miningFeild, uint256 duration, uint256 participationFee, uint256 minersShare, uint256 toBeWithdrawn) external override {
       require(duration >= 43200);
       (uint256 category, uint256 ngl) = NFT.nglOfNFT(miningFeild);
       require(category == 1 && ngl > 0);
       NFT.transferFrom(msg.sender, address(this), miningFeild);
       _NFTminingFieldOwner[msg.sender] = miningFeild;
       _miningFieldOwner[miningFeild] = msg.sender;
       
       uint256 game = _games;
       _fieldOwner[game] = msg.sender;
       _field[game] = miningFeild;
       _minersShare[game] = minersShare;
       _toBeWithdrawn[game] = toBeWithdrawn;
       _endingBlock[game] = block.number + duration;
       _participationFee[game] = participationFee;
   }
   
   function deployCharacter(uint256 ID) external override {
       (uint256 category, ) = NFT.nglOfNFT(ID);
       require(category == 0);
       NFT.transferFrom(msg.sender, address(this), ID);
       _NFTowner[msg.sender] = ID;
       _owner[ID] = msg.sender;
   }
   
   function removeCharacter() external override {
       require(_game[msg.sender] == 0);
       uint256 nft = _NFTowner[msg.sender];
       require(nft != 0);
       NFT.transferFrom(address(this), msg.sender, nft);
       _NFTowner[msg.sender] = 0;
       _owner[nft] = address(0);
   }
   
   function joinGame(uint256 game) external override {
       uint256 index = _participants[game];
       require(game < _games && game != 0 && index < 20 && _NFTowner[msg.sender] != 0 && _game[msg.sender] == 0 && block.number < _endingBlock[game]);
       if(_participationFee[game] > 0){NGL.transferFrom(msg.sender, _fieldOwner[game], _participationFee[game]);}
       if(_participant[game][index] != address(0)){_participant[game][index] = msg.sender; _gameIndex[msg.sender] = index;}
       else{
           for(uint256 t; t < 20; ++t){
               if(_participant[game][t] == address(0)){_participant[game][t] = msg.sender; _gameIndex[msg.sender] = t; break;}
               
           }
       }
       _game[msg.sender] == game;
       ++_participants[game];
   }
   
   function leaveGame(uint256 game) external override {
       require(game < _games && _game[msg.sender] == game); 
       --_participants[game];
       _participant[game][_gameIndex[msg.sender]] = address(0);
       _game[msg.sender] = 0;
   }
   
   function endGame(uint256 game) external override {
       require(block.number >= _endingBlock[game]);
       (, uint256 ngl) = NFT.nglOfNFT(_field[game]);
       uint256 toBeWithdrawn = _toBeWithdrawn[game] * ngl / 10000;
       uint256 minerShare = toBeWithdrawn * _minersShare[game] / 10000;
       uint256 miners;
       for(uint256 t; t < 10; ++t){
           if(_participant[game][t] != address(0)){++miners;}
       }
       minerShare = minerShare / miners;
       NFT.removeNGL(_field[game], toBeWithdrawn, address(this));
       
       uint256 claimedRewards = minerShare * miners;
       for(uint256 t; t < 10; ++t){
           address user = _participant[game][t];
           if(user != address(0)){NGL.transfer(user, minerShare); _game[user] = 0;}
       }
       
       address owner = _fieldOwner[game];
       NGL.transfer(owner, toBeWithdrawn - claimedRewards);
       NFT.transferFrom(address(this), owner, _field[game]);
   }
   
   function destoryNFT(uint256 character, uint256 indexOfNftToDestroy) external override {
       require(msg.sender == _contractOwner);
       uint256 nft = NFT.boxedNFT(character, indexOfNftToDestroy);
       NFT.unboxNFT(character, indexOfNftToDestroy);
       NFT.burnNFT(nft);
   }
   
}
