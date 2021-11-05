pragma solidity 0.5.16;
import "./SafeMath.sol";
import "./IBEP20.sol";
import "./BEP20.sol";
/**
 * @dev Implementation of DLC TOKEN
 * This contract is base on the Implementation of BEP20Token
 * src: https://github.com/binance-chain/BEPs/blob/master/BEP20.md
 */

contract DLCTOKEN is BEP20Token{
    //Initial participation project
    struct LockItem {
        uint256  releaseDate;
        uint256  amount;
    }
    
    struct Investor {
        address _address;
        uint256 amount;
    }
    
    /**
     * @dev add address of fund receiver for the initial fund allocation 
    */
    address private teamWallet= 0xB1C594206145e3401e4005A69114134c2E2a3fB3;
    address private marketingWallet = 0x4fcD01Edf05b1EBD8f66638f6C9d0312Df8af4ce;
    address private publicSaleWallet = 0x6ecaCced313Bc500aBE6E1ec34BE23888a8E777A;
   
    mapping(address => uint256) public privateSale;
    mapping (address => LockItem[]) public lockList;
    bool privateSaleFlag = false;
    //TODO: Weekly Map 
    Investor[] private partnerList;
    Investor [] private privateSaleList; //List of privatesale participant
    address [] private lockedAddressList; // list of addresses that have some fund currently or previously locked
        
    constructor() public payable BEP20Token("DLC","DLCTOKEN") {
        //Making constructor
        // allocationTeam(250000000 * (10 ** uint256(18)));
        // allocationMarketing(250000000 * (10 ** uint256(18)));
    }
    /**
     * @dev add address and investment amount to private sale
     * used for adding Investor address to privateSale;
     * require the action start befor start privatesale
     * @param _investor to input address of investor contract or wallet
     * @param _amount The amount to transfer.
     */
     
    function addAddresstoPrivateSale(address _investor, uint256 _amount) public whenNotPaused {
        require(msg.sender == owner() && privateSaleFlag == false && BEP20Token.balanceOf(msg.sender) > _amount);
        //Add address to private sale array
		Investor memory investor = Investor({_address: _investor, amount:_amount});
		privateSaleList.push(investor);
    }
    
    /**
     * @dev add address and investment amount to partnerList sale
     * used for adding Investor address to privateSale;
     * require the action start befor start privatesale
     * @param _investor to input address of investor contract or wallet
     * @param _amount The amount to transfer.
     */
    function addAddresstoPartnerList(address _investor, uint256 _amount) public whenNotPaused {
        require(msg.sender == owner() && BEP20Token.balanceOf(msg.sender) > _amount);
        //Add address to private sale array
			Investor memory investor = Investor({_address: _investor, amount:_amount});
			partnerList.push(investor);
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
	    
	    quarterMap.push(1636122900);//=Tue, 21 Sep 2021 00:00:00 GMT
        quarterMap.push(1636123200);//=Mon, 20 Dec 2021 00:00:00 GMT
  
        
        //Start Partner allocation
        for(uint i = 0; i <quarterMap.length; i ++) {
            for(uint j = 0; j < partnerList.length; j ++) {
                uint256 transferAmount = partnerList[j].amount.mul(5* (10 ** uint256(17)));
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
	    quarterMap1.push(1636122300);//=Tue, 21 Sep 2021 00:00:00 GMT
        quarterMap1.push(1636122600);//=Mon, 20 Dec 2021 00:00:00 GMT
        
        //Start team allocation
        for(uint i = 0; i <quarterMap1.length; i ++) {
            //Percentage
            uint256 transferAmount = amount.mul(5* (10 ** uint256(17)));
            amount.sub(transferAmount);
            transferAndLock(teamWallet, transferAmount, quarterMap1[i]);
        }
	}
	
		function allocationMarketing(uint256 amount) public {
	    require(msg.sender == owner());
            //Percentage
            transfer(marketingWallet, amount);
	}
	
	
	/**
     * @dev token public sale allication.
     */
     
    uint[]  weeklyPublic;
    function allocationPublicSale(uint256 amount) public whenNotPaused {
        require(msg.sender == owner());
        weeklyPublic.push(1636120800);//=Tue, 21 Sep 2021 00:00:00 GMT
        weeklyPublic.push(1636121100);//=Mon, 20 Dec 2021 00:00:00 GMT
        weeklyPublic.push(1636121400);
        //Start privatesale
        
        for(uint i = 0; i < weeklyPublic.length; i ++) {
            uint256 transferAmount = amount.mul(3* (10 ** uint256(17)));
            amount = amount.sub(transferAmount);
            transferAndLock(publicSaleWallet, transferAmount, weeklyPublic[i]);
        }
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
	    weekly.push(1636121700);//=Tue, 21 Sep 2021 00:00:00 GMT
        weekly.push(1636122000);//=Mon, 20 Dec 2021 00:00:00 GMT
        //Start privatesale
        for(uint i = 0; i <weekly.length; i ++) {
            for(uint j = 0; j < privateSaleList.length; j ++) {
                uint256 transferAmount = privateSaleList[j].amount.mul(5* (10 ** uint256(17)));
                privateSaleList[j].amount = privateSaleList[j].amount.sub(transferAmount);
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
