// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFunding {
    IERC20 private angelDollar;

    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function setTokenAddresses(address _angelDollar) public {
        angelDollar = IERC20(_angelDollar);
    }

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);
        campaign.amountCollected = campaign.amountCollected + amount;

        bool sent = angelDollar.transferFrom(msg.sender, address(this), amount);

        require(sent, "Transfer failed!");
    }

    function withdrawFromCampaign(uint256 _id, uint256 amount, address to) public payable {
        Campaign storage campaign = campaigns[_id];

        require(msg.sender == campaign.owner, "only owner of this campaign can withdraw");
        require(amount <= campaign.amountCollected, "can't withdraw more than total collection");

        campaign.amountCollected = campaign.amountCollected - amount;

        require(angelDollar.transfer(to, amount), "Withdrawal failed");
    }

    function getDonators(uint256 _id) public view returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    function getAngelDollarAddress() public view returns (address) {
        return address(angelDollar);
    }
}
