pragma solidity 0.5.16;
import "./SafeMath.sol";
import "./IBEP20.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = true;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract BEP20Token is Context, IBEP20, Ownable, Pausable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor(string memory name, uint8 decimals, string memory symbol) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
    _totalSupply = 2500000000 * (10 ** uint256(decimals)); 
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal whenNotPaused {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }
  
  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal whenNotPaused {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
   
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal whenNotPaused {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
  
  
}

contract DLCTOKEN is BEP20Token {
    //Initial participation project
    struct LockItem {
        uint256  releaseDate;
        uint256  amount;
    }
    
    struct Investor {
        address _address;
        uint256 amount;
    }
    
  
    address private teamWallet= "";
    address private marketingWallet = "";
    Investor private publicSaleWallet = "";
    Investor [] private partnerList;
    mapping(address => uint256) public privateSale;
    mapping (address => LockItem[]) public lockList;
    bool privateSaleFlag = false;
    //TODO: Weekly Map 
    Investor [] private privateSaleList; //List of privatesale participant
    address [] private lockedAddressList; // list of addresses that have some fund currently or previously locked
        
    constructor() public BEP20Token("DLC",18,"DLCTOKEN") {
        //Making constructor
        allocationTeam(250000000 * (10 ** uint256(18)));
        allocationMarketing(250000000 * (10 ** uint256(18)));
    }
        /**
     * @dev transfer to a given address a given amount and lock this fund until a given time
     * used for sending fund to team members, partners, or for owner to lock service fund over time
     * @return the bool true if success.
     * @param _receiver The address to transfer to.
     * @param _amount The amount to transfer.
     * @param _releaseDate The date to release token.
     */
     
    function addAddresstoPrivateSale(address _investor, uint256 _amount) public whenNotPaused {
        require(msg.sender == owner() && privateSaleFlag == false && BEP20Token.balanceOf(msg.sender) > _amount);
        //Add address to private sale array
			Investor memory investor = Investor({_address: _investor, amount:_amount});
			privateSaleList.push(investor);
			
    }
    
    function addAddresstoPartnerList(address _investor, uint256 _amount) public whenNotPaused {
        require(msg.sender == owner() && BEP20Token.balanceOf(msg.sender) > _amount);
        //Add address to private sale array
			Investor memory investor = Investor({_address: _investor, amount:_amount});
			partnerList.push(investor);
    }
    
    
     
     /**
     * @dev transfer of token to another address.
     * always require the sender has enough balance
     * @return the bool true if success. 
     * @param _receiver The address to transfer to.
     * @param _amount The amount to be transferred.
     */
     
	function transfer(address _receiver, uint256 _amount) public whenNotPaused returns (bool success) {
	    require(_receiver != address(0)); 
	    require(_amount <= getAvailableBalance(msg.sender));
        return BEP20Token.transfer(_receiver, _amount);
	}
	
	/**
     * @dev transfer of token on behalf of the owner to another address. 
     * always require the owner has enough balance and the sender is allowed to transfer the given amount
     * @return the bool true if success. 
     * @param _from The address to transfer from.
     * @param _receiver The address to transfer to.
     * @param _amount The amount to be transferred.
     */
    function transferFrom(address _from, address _receiver, uint256 _amount) public whenNotPaused returns (bool) {
        require(_from != address(0));
        require(_receiver != address(0));
        require(_amount <= BEP20Token.allowance(_from, msg.sender));
        require(_amount <= getAvailableBalance(_from));
        return BEP20Token.transferFrom(_from, _receiver, _amount);
    }

	/**
     * @dev transfer of token toPartner. 
     */
    uint [] quarterMap; 
	function allocationPartner() public {
	    require(msg.sender == owner());
	    
	    quarterMap.push(1632182400);//=Tue, 21 Sep 2021 00:00:00 GMT
        quarterMap.push(1639958400);//=Mon, 20 Dec 2021 00:00:00 GMT
  
        
        //Start Partner allocation
        for(uint i = 1; i <= 10; i ++) {
            for(uint j = 0; j < partnerList.length; j ++) {
                uint256 transferAmount = partnerList.amount.mul(amt);
                partnerList[j].amount.sub(transferAmount);
                transferAndLock(partnerList[j]._address, transferAmount, quarterMap[i]);
            }
        }
	}
	/**
     * @dev transfer token to team. 
     * always require the owner has enough balance and the sender is allowed to transfer the given amount
     */
	uint[] quarterMap1;
	function allocationTeam(uint256 amount) internal {
	    require(msg.sender == owner());
	    quarterMap1.push(1632182400);//=Tue, 21 Sep 2021 00:00:00 GMT
        quarterMap1.push(1639958400);//=Mon, 20 Dec 2021 00:00:00 GMT
        
        //Start team allocation
        for(uint i = 1; i <= 10; i ++) {
            //Percentage
            uint256 transferAmount = amount.mul(0.01);
            amount.sub(transferAmount);
            transferAndLock(teamWallet, transferAmount, quarterMap1[i]);
        }
	}
	
		function allocationMarketing(uint256 amount) internal {
	    require(msg.sender == owner());
            //Percentage
            transfer(marketingWallet, amount);
	}
	
	
	/**
     * @dev token public sale allication.
     */
     
    function allocationPublicSale(uint256 amount) public whenNotPaused {
        require(msg.sender == owner());
        transfer(publicSaleWallet, amount);
	}
	
		/**
     * @dev transfer of token on behalf of the owner to another address. 
     * always require the owner has enough balance and the sender is allowed to transfer the given amount
     * @return the bool true if success. 
     * @param _from The address to transfer from.
     * @param _receiver The address to transfer to.
     * @param _amount The amount to be transferred.
     */
	uint[]  weekly;
	function allocationPrivateSale() public whenNotPaused {
	    //Sample watter map
	    require(msg.sender == owner());
	    weekly.push(1632182400);//=Tue, 21 Sep 2021 00:00:00 GMT
        weekly.push(1639958400);//=Mon, 20 Dec 2021 00:00:00 GMT
        
        //Start privatesale
        for(uint i = 1; i <= 10; i ++) {
            for(uint j = 0; j < privateSaleList.length; j ++) {
                uint256 transferAmount = privateSaleList[j].amount.mul(0.01);
                privateSaleList[j].amount = privateSaleList.sub(transferAmount);
                transferAndLock(privateSaleList[j]._address, transferAmount, weekly[i]);
            }
        }
        privateSaleFlag = true;
	}
	
	function transferAndLock(address _receiver, uint256 _amount, uint256 _releaseDate) public whenNotPaused returns (bool success) {
	    //Require the transferAndLock for only few wallet address
	    require(msg.sender == teamWallet || msg.sender == publicSaleWallet || msg.sender ==   marketingWallet || msg.sender == owner());
        BEP20Token._transfer(msg.sender,_receiver,_amount);
    	
    	if (lockList[_receiver].length==0) lockedAddressList.push(_receiver);
    	
		
    	LockItem memory item = LockItem({amount:_amount, releaseDate:_releaseDate});
		lockList[_receiver].push(item);
		
		//Relase token every
        return true;
	}
	

	
	
    /**
     * @return the total amount of locked funds of a given address.
     * @param lockedAddress The address to check.
     */
	function getLockedAmount(address lockedAddress) public view returns(uint256 _amount) {
	    uint256 lockedAmount =0;
	    for(uint256 j = 0; j<lockList[lockedAddress].length; j++) {
	        if(now < lockList[lockedAddress][j].releaseDate) {
	            uint256 temp = lockList[lockedAddress][j].amount;
	            lockedAmount += temp;
	        }
	    }
	    return lockedAmount;
	}
	
	/**
     * @return the total amount of locked funds at the current time
     */
	function getLockedAmountTotal() public view returns(uint256 _amount) {
	    uint256 sum =0;
	    for(uint256 i = 0; i<lockedAddressList.length; i++) {
	        uint256 lockedAmount = getLockedAmount(lockedAddressList[i]);
    	    sum = sum.add(lockedAmount);
	    }
	    return sum;
	}
	
	/**
     * @return the total amount of locked funds of a given address.
     * @param lockedAddress The address to check.
     */
	function getAvailableBalance(address lockedAddress) public view returns(uint256 _amount) {
	    uint256 bal = BEP20Token.balanceOf(lockedAddress);
	    uint256 locked = getLockedAmount(lockedAddress);
	    return bal.sub(locked);
	}
	
	/**
	 * @return the total amount of circulating coins that are not locked at the current time
	 * 
	 */
	function getCirculatingSupplyTotal() public view returns(uint256 _amount) {
	    return BEP20Token.totalSupply().sub(getLockedAmountTotal());
	}
}
