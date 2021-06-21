// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC20{
    
     function name() external view returns (string memory);

    function symbol() external view returns(string memory);

    function decimals() external view returns(uint256);

    function totalSupply() external view returns(uint256);
    
    function balanceOf(address account) external view returns(uint256);
    
    function transferOwnership(address to) external returns(bool);
    
    function transfer(address recipient, uint256 amount) external returns(bool);

    function allowance(address owner, address spender) external view returns(uint256);

    function approve(address spender, uint256 amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns(bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns(bool);

    function _mint(uint256 amount) external returns(bool);

    function _burn(uint256 amount) external returns(bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed user, uint256 amount);
}
contract ERC20 is IERC20{
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (uint256 => uint256) private _yearTotalSupply;
    mapping (uint256 => uint256) private _yearMinted;
    
    address private _owner;
    uint256 private _block;
    
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    constructor (string memory name_, string memory symbol_, uint256 totalSupply) {
        _owner = msg.sender;
        _block = block.number;
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply;
        _balances[msg.sender] = totalSupply;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint256) {
        return 18;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function transferOwnership(address to) external override returns(bool){
        require(msg.sender == _owner);
        _owner = to;
        return true;
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _allowances[sender][msg.sender] -= amount;
        
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        
        emit Transfer(sender, recipient, amount);
        
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external  override returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        if(subtractedValue > _allowances[msg.sender][spender]){_allowances[msg.sender][spender] = 0;}
        else{_allowances[msg.sender][spender] -= subtractedValue;}

        return true;
    }

    function _mint(uint256 amount) external override returns (bool) {
        require(msg.sender == _owner);
        require(block.number - _block >= 4851692);
        uint256 year = ((block.number - _block) - 4851692) / 2425846;
        
        if(_yearTotalSupply[year] == 0){_yearTotalSupply[year] = _totalSupply;}
        
        require(amount <= (_yearTotalSupply[year] *30 /100) - _yearMinted[year]);
        
        _yearMinted[year] += amount;
        _totalSupply += amount;
        
        _balances[msg.sender] += amount;
        
        return true;
    }

    function _burn(uint256 amount) external override returns (bool) {
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        
        emit Burn(msg.sender, amount);
        
        return true;

    }


}