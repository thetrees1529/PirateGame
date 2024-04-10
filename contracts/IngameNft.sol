//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;
import "@thetrees1529/solutils/contracts/gamefi/Nft.sol";

contract IngameNft is Nft {

    error NotOwnedOrApprovedFor(uint tokenId);

    constructor(string memory uri, string memory name, string memory symbol) Nft(uri, name, symbol) {}
    
    //gas optimization for game interactions
    function requireOwnsOrIsApprovedForList(uint[] calldata tokenIds) external view  {
        for(uint i = 0; i < tokenIds.length; i++) {
            if(!(ownerOf(tokenIds[i]) == msg.sender || isApprovedForAll(ownerOf(tokenIds[i]), msg.sender) || getApproved(tokenIds[i]) == msg.sender)) {
                revert NotOwnedOrApprovedFor(tokenIds[i]);
            }
        }
    }


}