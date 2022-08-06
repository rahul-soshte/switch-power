// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

//* Prosumers and Consumers can call this contract to mint Energy NFTs

contract SwitchPowerNFTMint is ERC1155 {
    uint256 private constant POWER = 0;
    address private owner;

    constructor() ERC1155("") {
        _mint(msg.sender, POWER, 10**18, "");
    }

    function mint(uint256 id, uint256 amount) external {
        _mint(msg.sender, id, amount, "");
    }
}
