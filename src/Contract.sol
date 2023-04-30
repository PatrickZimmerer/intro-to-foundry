// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

contract Flashloaner is ReentrancyGuard {
    ERC20 public immutable damnValuableToken;
    uint256 public poolBalance;

    error TokenAddressCannotBeZero();
    error MustDepositOneTokenMinimum();
    error MustBorrowOneTokenMinimum();
    error NotEnoughTokensInPool();
    error FlashLoanHasNotBeenPaidBack();

    constructor(address tokenAddress) {
        if (tokenAddress == address(0)) revert TokenAddressCannotBeZero();
        damnValuableToken = ERC20(tokenAddress);
    }

    function depositTokens(uint256 amount) external nonReentrant {
        if (amount == 0) revert MustDepositOneTokenMinimum();
        // Transfer token from sender (approval needed)
        damnValuableToken.transferFrom(msg.sender, address(this), amount);
        poolBalance = poolBalance + amount;
    }

    function flashLoan(uint256 borrowAmount) external nonReentrant {
        if (borrowAmount == 0) revert MustBorrowOneTokenMinimum();

        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        if (balanceBefore < borrowAmount) revert NotEnoughTokensInPool();

        assert(poolBalance == balanceBefore);

        damnValuableToken.transfer(msg.sender, borrowAmount);
        IReceiver(msg.sender).receiveTokens(
            address(damnValuableToken),
            borrowAmount
        );

        uint256 balanceAfter = damnValuableToken.balanceOf(address(this));

        if (balanceAfter < balanceBefore) revert FlashLoanHasNotBeenPaidBack();
    }
}
