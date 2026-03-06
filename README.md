# NFT Staking Vault

A professional-grade smart contract suite for incentivizing NFT long-term holding. This vault allows users to stake their NFTs and claim rewards proportionally based on the duration of the stake.

## Core Logic
* **Staking**: Transfer NFT to the vault; the contract tracks ownership and block timestamps.
* **Rewards**: A specialized `RewardToken` (ERC20) is minted or transferred to users based on a fixed "Reward Per Block" rate.
* **Withdrawal**: Users can unstake at any time, which automatically triggers a final reward claim.

## Components
* `NFTVault.sol`: The primary staking logic.
* `RewardToken.sol`: A standard ERC20 with minting permissions for the Vault.

## Setup
1. Deploy `RewardToken.sol`.
2. Deploy `NFTVault.sol` with the NFT Collection address and the Reward Token address.
3. Grant `MINTER_ROLE` or transfer tokens to the Vault contract.
