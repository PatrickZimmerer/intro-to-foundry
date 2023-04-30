// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

contract Flashloaner is ReentrancyGuard {
    ERC20 public immutable damnValuableToken;
    uint256 public poolBalance;

    error TokenAddressCannotBeZero();

    constructor(address tokenAddress) {
        if (tokenAddress == address(0)) revert TokenAddressCannotBeZero();
        damnValuableToken = ERC20(tokenAddress);
    }
}
