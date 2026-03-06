// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTVault is Ownable, ReentrancyGuard {
    IERC721 public immutable nftCollection;
    IERC20 public immutable rewardToken;

    uint256 public rewardRatePerHour = 10 ether; 

    struct Stake {
        address owner;
        uint256 timestamp;
    }

    // Mapping from tokenId to Stake info
    mapping(uint256 => Stake) public vault;

    event Staked(address indexed user, uint256 tokenId, uint256 timestamp);
    event Unstaked(address indexed user, uint256 tokenId, uint256 timestamp);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(address _nftCollection, address _rewardToken) Ownable(msg.sender) {
        nftCollection = IERC721(_nftCollection);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256[] calldata tokenIds) external nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nftCollection.ownerOf(tokenId) == msg.sender, "Not the owner");

            nftCollection.transferFrom(msg.sender, address(this), tokenId);

            vault[tokenId] = Stake({
                owner: msg.sender,
                timestamp: block.timestamp
            });

            emit Staked(msg.sender, tokenId, block.timestamp);
        }
    }

    function unstake(uint256[] calldata tokenIds) external nonReentrant {
        _claimRewards(tokenIds, true);
    }

    function claim(uint256[] calldata tokenIds) external nonReentrant {
        _claimRewards(tokenIds, false);
    }

    function _claimRewards(uint256[] calldata tokenIds, bool _unstake) internal {
        uint256 totalReward = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            Stake memory stakedItem = vault[tokenId];
            require(stakedItem.owner == msg.sender, "Not the staker");

            uint256 stakingDuration = block.timestamp - stakedItem.timestamp;
            totalReward += (stakingDuration * rewardRatePerHour) / 3600;

            if (_unstake) {
                delete vault[tokenId];
                nftCollection.transferFrom(address(this), msg.sender, tokenId);
                emit Unstaked(msg.sender, tokenId, block.timestamp);
            } else {
                vault[tokenId].timestamp = block.timestamp;
            }
        }

        if (totalReward > 0) {
            rewardToken.transfer(msg.sender, totalReward);
            emit RewardPaid(msg.sender, totalReward);
        }
    }

    function setRewardRate(uint256 _rate) external onlyOwner {
        rewardRatePerHour = _rate;
    }
}
