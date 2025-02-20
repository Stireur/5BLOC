// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonopolyProperty is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;
    address public gameContract;

    constructor() ERC721("MonopolyProperty", "MNP") Ownable(msg.sender) {}

    modifier onlyGameContract() {
        require(msg.sender == gameContract, "Only game contract can call this");
        _;
    }

    function setGameContract(address _gameContract) external onlyOwner {
        gameContract = _gameContract;
    }

    function mintProperty(address to, string memory tokenURI) external onlyGameContract {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

    function ownerOfProperty(uint256 tokenId) external view returns (address) {
        return ownerOf(tokenId);
    }
}
