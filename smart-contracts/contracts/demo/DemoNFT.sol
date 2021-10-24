// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.6;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../extension/ERC721Snapshot.sol";

/**
 * A demo ERC721 contract that is compatible with Intergral DAO protocol
 */
contract DemoNFT is Ownable, ERC721Snapshot {
    using Counters for Counters.Counter;

    // The internal token ID tracker
    Counters.Counter private _tokenIdCounter;

    /**
     * Create a demo ERC721 for integral protocol
     */
    constructor() ERC721("Integral DAO Protocol Demo NFT", "iNFT") {
        // mint for deployer who is also the owner at deployment
        safeMint(msg.sender);
    }

    function safeMint(address to) public onlyOwner {
        _safeMint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }
}