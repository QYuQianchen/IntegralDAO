// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Required interface for using integral DAO.
 */
interface IIntegral {

    /**
     * @dev Returns the weight of an account at a given block number.
     */
    function weightOfAt(address account, uint32 blockNumber) external view returns (uint224);

    /**
     * @dev Returns the increment of weight since a given block number.
     */
    function weightChangeSince(address account, uint32 blockNumber) external view returns (uint224);
}