// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AngelGovernanceToken} from "./AngelGovernanceToken.sol";

error LockTokens__NotOwner();

contract LockTokens {
    address private immutable i_owner;
    IERC20 private angelDollar;
    AngelGovernanceToken private angelGovernanceToken;
    uint256 private swapRatio; // 30 AngelDollar for 1 AngelGovernanceToken

    event TokensLocked(address indexed user, uint256 angelAmount, uint256 governanceAmount);
    event SwapRatioUpdated(uint256 oldRatio, uint256 newRatio);

    constructor(address _angelDollar, address _angelGovernanceToken) {
        i_owner = msg.sender;
        swapRatio = 30;
        angelDollar = IERC20(_angelDollar);
        angelGovernanceToken = AngelGovernanceToken(_angelGovernanceToken);
    }

    modifier onlyOwner() {
        if (i_owner != msg.sender) revert LockTokens__NotOwner();
        _;
    }

    function setTokenAddresses(address _angelDollar, address _governanceToken) public onlyOwner {
        angelDollar = IERC20(_angelDollar);
        angelGovernanceToken = AngelGovernanceToken(_governanceToken);
    }

    function swap(uint256 amountAngelDollar) public {
        require(amountAngelDollar >= 30, "Amount must be greater than 30");
        require(angelDollar.balanceOf(msg.sender) >= amountAngelDollar, "Insufficient AngelDollar balance");
        // Calculate the corresponding amount of AngelGovernanceToken based on the swap ratio
        uint256 amountAngelGovernanceToken = amountAngelDollar / swapRatio;

        require(angelDollar.allowance(msg.sender, address(this)) >= amountAngelDollar, "Allowance not set");
        // Transfer AngelDollar from the sender to this contract
        require(angelDollar.transferFrom(msg.sender, address(this), amountAngelDollar), "AngelDollar transfer failed");

        // Transfer AngelGovernanceToken from this contract to the sender
        angelGovernanceToken.mint(msg.sender, amountAngelGovernanceToken);

        emit TokensLocked(msg.sender, amountAngelDollar, amountAngelGovernanceToken);
    }

    function withdraw(address to, uint256 amount) public onlyOwner {
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(angelDollar.transfer(to, amount), "Withdrawal failed");
    }
    /*
    // Owner can withdraw any remaining tokens left in the contract
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(owner(), amount), "Token transfer failed");
    } */

    // Owner can update the swap ratio if needed
    function updateSwapRatio(uint256 newRatio) external onlyOwner {
        require(newRatio > 0, "Swap ratio must be greater than 0");
        uint256 oldRatio = swapRatio;
        swapRatio = newRatio;
        emit SwapRatioUpdated(oldRatio, newRatio);
    }

    // Function to view the address of angelDollar
    function getAngelDollarAddress() public view returns (address) {
        return address(angelDollar);
    }

    // Function to view the address of angelGovernanceToken
    function getAngelGovernanceTokenAddress() public view returns (address) {
        return address(angelGovernanceToken);
    }

    function viewSwapRatio() public view returns (uint256) {
        return swapRatio;
    }
}
