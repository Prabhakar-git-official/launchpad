// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    /*
    Transfer the ownership from owner to new owner
    */
    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}


// ----------------------------------------------------------------------------
// BEP Token Standard #20 Interface
// ----------------------------------------------------------------------------
interface IToken {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
}
interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract RobinPresale is Owned {
    using SafeMath for uint256;
   
    bool public isPresaleOpen;
   
    //@dev ERC20 token address and decimals
    address public tokenAddress;
    address public BUSDAddress;
    uint256 public tokenDecimals = 9;
   
    //@dev amount of tokens per ether 1 indicates 1 token per eth
    uint256 public tokenRatePerEth = 3000000;
    //@dev decimal for tokenRatePerEth,
    //2 means if you want 100 tokens per eth then set the rate as 100 + number of rateDecimals i.e => 10000
    uint256 public rateDecimals = 2;
   
    //@dev max and min token buy limit per account
    uint256 public minEthLimit = 10 finney;
    uint256 public maxEthLimit = 10 ether;
   
    mapping(address => uint256) public usersInvestments;
   
    constructor() public {
        owner = msg.sender;
    }
    /*
     start the presale for usersInvestments
     */
     
    function startPresale() external onlyOwner{
        require(!isPresaleOpen, "Presale is open");
       
        isPresaleOpen = true;
    }
   
    /*
    close the presale contract after usersInvestments to be ended
    */
   
    function closePrsale() external onlyOwner{
        require(isPresaleOpen, "Presale is not open yet.");
       
        isPresaleOpen = false;
    }
   
    /*
    set the token contract address for transfering the tokens to the usersInvestments
    */
   
    function setTokenAddress(address token) external onlyOwner {
        require(tokenAddress == address(0), "Token address is already set.");
        require(token != address(0), "Token address zero not allowed.");
       
        tokenAddress = token;
    }
     function setBUSDAddress(address BUSD) external onlyOwner {
        require(BUSDAddress == address(0), "Token address is already set.");
        require(BUSD != address(0), "Token address zero not allowed.");
       
        BUSDAddress = BUSD;
    }
   
    function setTokenDecimals(uint256 decimals) external onlyOwner {
       tokenDecimals = decimals;
    }
   
    function setMinEthLimit(uint256 amount) external onlyOwner {
        minEthLimit = amount;    
    }
   
    function setMaxEthLimit(uint256 amount) external onlyOwner {
        maxEthLimit = amount;    
    }
   
    function setTokenRatePerEth(uint256 rate) external onlyOwner {
        tokenRatePerEth = rate;
    }
   
    function setRateDecimals(uint256 decimals) external onlyOwner {
        rateDecimals = decimals;
    }
    /*
    when calling the receive function user must
    send the amount as ether or BNB or finney to
    the token contract.
    */
   
     function receive() external payable{
        require(isPresaleOpen, "Presale is not open.");
       require(
                usersInvestments[msg.sender].add(msg.value) <= maxEthLimit
                && usersInvestments[msg.sender].add(msg.value) >= minEthLimit,
                "Amount should be less than 10 for ether and greater that 10 for finney"
            );
           
       
        //@dev calculate the amount of tokens to transfer for the given eth
        uint256 tokenAmount = getTokensPerEth(msg.value);
       
        require(IToken(tokenAddress).transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
       
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);
       
        //@dev send received funds to the owner
        owner.transfer(msg.value);
    }
    //  function swapByBUSD(uint256 amount) public returns(bool){
    //     require(isPresaleOpen, "Presale is not open.");
    //    /*require(
    //             usersInvestments[msg.sender].add(msg.value) <= maxEthLimit
    //             && usersInvestments[msg.sender].add(msg.value) >= minEthLimit,
    //             "Amount should be less than 10 for ether and greater that 10 for finney"
    //         );
    //      */  
       
    //     //@dev calculate the amount of tokens to transfer for the given eth
    //     //uint256 tokenAmount = getTokensPerEth(amount);
       
    //    IBEP20(BUSDAddress).transferFrom(msg.sender,owner, amount);
    //    return true;
    //     //require(IToken(tokenAddress).transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
       
    //     //usersInvestments[msg.sender] = usersInvestments[msg.sender].add(amount);
       
    //     //@dev send received funds to the owner
    //     //owner.transfer(msg.value);
    // }
    bool public val;
    // function click(uint256 amount) external payable{
    //      require(isPresaleOpen, "Presale is not open.");
    //    /*require(
    //             usersInvestments[msg.sender].add(msg.value) <= maxEthLimit
    //             && usersInvestments[msg.sender].add(msg.value) >= minEthLimit,
    //             "Amount should be less than 10 for ether and greater that 10 for finney"
    //         );
    //      */  
       
    //     //@dev calculate the amount of tokens to transfer for the given eth
    //     uint256 tokenAmount = getTokensPerEth(amount);
       
    //     swapByBUSD(amount);
    //     require(IToken(tokenAddress).transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
       
    //     usersInvestments[msg.sender] = usersInvestments[msg.sender].add(amount);
    // }
   
    function getTokensPerEth(uint256 amount) public view returns(uint256) {
        return amount.mul(tokenRatePerEth).div(
            10**(uint256(18).sub(tokenDecimals).add(rateDecimals))
            );
    }
   
    /*
    After presale is closed ,the unsold tokens can be burned.
    */
   
    function burnUnsoldTokens() external onlyOwner {
        require(!isPresaleOpen, "You cannot burn tokens untitl the presale is closed.");
       
        IToken(tokenAddress).burnTokens(IToken(tokenAddress).balanceOf(address(this)));  
    }
   
    /*
    After presale is closed the owner can transfer the unsold to the
    token owner address by getUnsoldTokens.
    */
   
    function getUnsoldTokens() external onlyOwner {
        require(!isPresaleOpen, "You cannot get tokens until the presale is closed.");
       
        IToken(tokenAddress).transfer(owner, IToken(tokenAddress).balanceOf(address(this)) );
    }
}
