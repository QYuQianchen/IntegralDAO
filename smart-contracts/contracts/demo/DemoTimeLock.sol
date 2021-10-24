// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract DemoTimeLock is TimelockController {
    constructor(
        address[] memory proposers,
        address[] memory executors
    ) TimelockController(2, proposers, executors) {}
}