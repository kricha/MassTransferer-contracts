// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// import {Ownable} from "./Ownable.sol";
import {PausableWithOwner} from "./PausableWithOwner.sol";

/**
 * @dev Interface of the TRC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {TRC20Detailed}.
 */
interface ITRC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender) external view returns (uint256);

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

contract TrcMassTransferer is PausableWithOwner {
    event MassTransferComplete(address indexed token, uint256 total);

    mapping(address => uint8) internal noFeeSenders;
    uint256 internal fee = 50e6;
    uint8 internal maxTransfersNumber = 200;
    bool internal stopped = false;
    string internal newContract = "0x0";

    constructor() {}

    modifier whenNotStopped() {
        require(!stopped, string(bytes.concat("Contract is stopped, new at: ", bytes(newContract))));
        _;
    }

    function setStopped(bool _state) external onlyOwner {
        stopped = _state;
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setMaxTransfersNumber(uint8 _count) external onlyOwner {
        maxTransfersNumber = _count;
    }

    function getFee() external view returns (uint256) {
        return noFeeSenders[msg.sender] == 1 ? 0 : fee;
    }

    function setNewContract(string calldata _addr) external onlyOwner {
        newContract = _addr;
    }

    function addNoFeeAddress(address _address) external onlyOwner {
        noFeeSenders[_address] = 1;
    }

    function delNoFeeAddress(address _address) external onlyOwner {
        delete noFeeSenders[_address];
    }

    // sending tokens with simple recipients and amounts arrays
    function sendToken(address _token, address[] memory _recipients, uint256[] memory _amounts)
        public
        payable
        whenNotPaused
        whenNotStopped
    {
        _makeTransfer(_token, _recipients, _amounts);
    }

    function sendMain(address[] memory _recipients, uint256[] memory _amounts)
        external
        payable
        whenNotStopped
        whenNotPaused
    {
        _makeTransfer(address(0x0), _recipients, _amounts);
    }

    function _makeTransfer(address _token, address[] memory _recipients, uint256[] memory _amounts) private {
        // check if lenght of recipients and amounts is same
        require(_recipients.length == _amounts.length, "invalid recipient and amount arrays");
        // check if transfers count is less or eq than limit
        require(_recipients.length <= maxTransfersNumber, "max transfers number exceeded");
        uint256 _total = 0;
        // calculate fee for request
        uint256 _totalFee = noFeeSenders[msg.sender] == 0 ? _recipients.length * fee : 0;
        require(msg.value >= _totalFee, "no fee provided");

        for (uint256 i = 0; i < _amounts.length; i++) {
            _total += _amounts[i];
        }

        if (_token == address(0x0)) {
            require(msg.value >= _total + _totalFee, "not enough value");
            for (uint256 i = 0; i < _recipients.length; i++) {
                (bool success,) = _recipients[i].call{value: _amounts[i]}("");
                require(success, "Transfer failed.");
            }
        } else {
            ITRC20 token = ITRC20(_token);

            uint256 _balance = token.balanceOf(msg.sender);
            require(_balance >= _total, "not enough token balance");

            uint256 _allowance = token.allowance(msg.sender, address(this));
            require(_allowance >= _total, "not enough token allowance");

            for (uint256 i = 0; i < _recipients.length; i++) {
                token.transferFrom(msg.sender, _recipients[i], _amounts[i]);
            }
        }

        emit MassTransferComplete(_token, _total);
    }

    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "zero balance.");
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    function withdrawToken(ITRC20 _token) external onlyOwner {
        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "zero balance");
        _token.transfer(owner(), amount);
    }

    receive() external payable {}
    fallback() external payable {}
}
