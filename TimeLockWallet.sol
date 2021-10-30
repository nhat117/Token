pragma solidity ^0.4.0;

import "./DLC_Final.sol";

contract TimeLockWallet {
    // BEP20 basic token contract being held
    BEP20Token private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    address private _creator;

    uint256 private _createdTime;
//Set contract owner
    modifier onlyOwner {
        require(msg.sender == _beneficiary);
        _;
    }
    /**
     * init function 
     * accept DLC BEP20Token 
     */
    function init(
        BEP20Token token_,
        address beneficiary_,
        address creator_,
        uint256 releaseTime_
    ) external {
        // solhint-disable-next-line not-rely-on-time
        require(
            releaseTime_ > block.timestamp,
            "TokenTimelock: release time is before current time"
        );
        _token = token_;
        _beneficiary = beneficiary_;
        _creator = creator_;
        _createdTime = block.timestamp;
        _releaseTime = releaseTime_;
    }

    /**
     * @return the token being held.
     */
    function token() public view  returns (BEP20Token) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view  returns (address) {
        return _beneficiary;
    }

    function creator() public view returns (address) {
        return _creator;
    }

    function createdTime() public view returns (uint256) {
        return _createdTime;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function releaseToken() public  onlyOwner {
        // solhint-disable-next-line not-rely-on-time
        require(
            block.timestamp >= releaseTime(),
            "TokenTimelock: current time is before release time"
        );

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        token().transfer(beneficiary(), amount);
    }


    function getBalance() public view returns (uint256) {
        return token().balanceOf(address(this));
    }

    function getWalletDetails()
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _beneficiary,
            _creator,
            _releaseTime,
            _createdTime,
            address(this).balance,
            token().balanceOf(address(this))
        );
    }
}

