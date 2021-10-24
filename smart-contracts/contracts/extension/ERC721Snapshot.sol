// SPDX-License-Identifier: MIT

/**
 * @title Basic snapshot of an ERC-721 token
 * Simplified snapshot on the balance, which essentially treat it as ERC20.
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../interface/IIntegral.sol";
import "../library/BalanceSnapshot.sol";

abstract contract ERC721Snapshot is IIntegral, BalanceSnapshot, ERC721 {
    /**
     * @dev Queries the balance of `account` at a specific `blockNumber`
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number when the balance is queried
     * @return The balance at `blockNumber`
     */
    function balanceOfAt(address account, uint32 blockNumber) external view returns (uint224) {
        return _balanceAt(account, blockNumber);
    }

    /**
     * @dev Queries the weight of `account` at a specific `blockNumber`
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number when the balance is queried
     * @return The weight at `blockNumber`
     */
    function weightOfAt(address account, uint32 blockNumber) external view returns (uint224) {
        return _weightAt(account, blockNumber);
    }

    /**
     * @dev Queries the increment in weight of `account` at a specific `blockNumber`
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number when the balance is queried
     * @return The increment in weight at `blockNumber`
     */
    function weightChangeSince(address account, uint32 blockNumber) external view returns (uint224) {
        return _weightChangeSince(account, blockNumber);
    }

    /**
     * @dev hooks into OpenZeppelin's `ERC721._transfer`
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
        
        if (from != to) {
            if (from != address(0)) {
                // update from
                _updateValueAtNow(from, _balanceAt(from, uint32(block.number)) - 1);
            }
            if (to != address(0)) {
                // update to
               _updateValueAtNow(to, _balanceAt(to, uint32(block.number)) + 1);
            }
        }
    }
}
