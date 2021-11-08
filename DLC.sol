pragma solidity 0.5.16;
import "./SafeMath.sol";
import "./IBEP20.sol";
import "./BEP20.sol";

/**
 * @dev Implementation of DLC TOKEN
 * This contract is base on the Implementation of BEP20Token
 * src: https://github.com/binance-chain/BEPs/blob/master/BEP20.md
 */
 
//TODO: Impelement using SafeMath
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
    
    address private marketingWallet= 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
    address private teamWallet = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address private publicSaleWallet = 0x6ecaCced313Bc500aBE6E1ec34BE23888a8E777A;
   
    mapping(address => uint256) public privateSale;
    mapping (address => LockItem[]) public lockList;
   
    //TODO: Weekly Map 
    Investor[] private partnerList;
    Investor[] private privateSaleList; //List of privatesale participant
    address[] private lockedAddressList; // list of addresses that have some fund currently or previously locked
     
    //Date map
    mapping(uint => uint)private quarterMapPrivate; 
    mapping(uint => uint) quarterMapPartner; 
    mapping(uint => uint) quarterMapTeam; 
    mapping(uint => uint) private weeklyPublic;
    mapping(uint => uint) private  weekly;
    uint256 amount;
    constructor() public payable BEP20Token("DLC","DLCTOKEN") {
    BEP20Token.mint(100000000000000000000000000);
    //Add address of private sale Investor
        //Investor 1
	privateSaleList.push(Investor({_address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, amount:1000}));
		//Investor 2
	privateSaleList.push(Investor({_address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, amount:10000}));
		
    //Add address of partnerList
        //Partner 1
    partnerList.push(Investor({_address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, amount:10000}));
        //Partner 2
    partnerList.push(Investor({_address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, amount:1000000}));
    
    
    //Timeline for private sale
    quarterMapPrivate[1] = 1636346513;//=Tue, 21 Sep 2021 00:00:00 GMT
    quarterMapPrivate[2] = 1636346513;//=Mon, 20 Dec 2021 00:00:00 GMT
        //Start privatesale
    for(uint i = 1; i <3; i ++) {
        for(uint j = 0; j < privateSaleList.length; j ++) {
            uint256 transferAmount =privateSaleList[j].amount * 50 / 100;
            partnerList[j].amount -= transferAmount;
            transferAndLock(privateSaleList[j]._address, transferAmount, quarterMapPrivate[i]);
        }
    }
    
    //Timeline for Partner allocation
    	    
	quarterMapPartner[1] = 1636122900;//=Tue, 21 Sep 2021 00:00:00 GMT
    quarterMapPartner[2] = 1636123200;//=Mon, 20 Dec 2021 00:00:00 GMT
  
        
        //Start Partner allocation
    for(uint i = 1; i <3; i ++) {
        for(uint j = 0; j < partnerList.length; j ++) {
            int256 transferAmount = partnerList[j].amount * 50 /100;
            partnerList[j].amount -= transferAmount;
            transferAndLock(partnerList[j]._address, transferAmount, quarterMapPartner[i]);
        }
    }
        
    //Timeline for Public allocation
    weeklyPublic[1] = 1636120800;//=Tue, 21 Sep 2021 00:00:00 GMT
    weeklyPublic[2] = 1636121100;//=Mon, 20 Dec 2021 00:00:00 GMT
    weeklyPublic[3] = 1636121400;
       //Start publicSale
    amount = 100000;
    for(uint i = 1; i < 4; i ++) {
        uint256 transferAmount = amount * 30 /100;
        amount -= transferAmount;
        transferAndLock(publicSaleWallet, transferAmount, weeklyPublic[i]);
    }
    
    // //Timeline for team allocation
    
    quarterMapTeam[1] = 1636122300;//=Tue, 21 Sep 2021 00:00:00 GMT
    quarterMapTeam[2] = 1636122600;//=Mon, 20 Dec 2021 00:00:00 GMT
    amount = 100000;
    //Start team allocation
    for(uint i = 1; i <3; i ++) {
        //Percentage
        uint256 transferAmount = amount *50/100;
        amount -= transferAmount;
        transferAndLock(teamWallet, transferAmount, quarterMapTeam[i]);
    }
        
    //Marketing wallet allocation
    amount = 100000;
    transfer(marketingWallet, amount);
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
     * @dev transfer of token on behalf of the owner to another address. 
     * always require the owner has enough balance and the sender is allowed to transfer the given amount
     * @return the bool true if success. 
     * @param _receiver The address to transfer to.
     * @param _amount The amount to be transferred.
     */

	function transferAndLock(address _receiver, uint256 _amount, uint256 _releaseDate) internal returns (bool success) {
	    //Require the transferAndLock for only few wallet address
	   // require(msg.sender == teamWallet || msg.sender == publicSaleWallet || msg.sender ==   marketingWallet || msg.sender == owner());
        BEP20Token._transfer(msg.sender,_receiver,_amount);
    	
    	if (lockList[_receiver].length==0) lockedAddressList.push(_receiver);
		
    	LockItem memory item = LockItem({amount:_amount, releaseDate:_releaseDate});
		lockList[_receiver].push(item);
	
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
