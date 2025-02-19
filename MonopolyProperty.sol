// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonopolyProperty is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    constructor() ERC721("MonopolyProperty", "MNP") Ownable(msg.sender) {}

    /// @notice Mint une nouvelle propriété
    /// @param to Adresse du propriétaire initial
    /// @param tokenURI URI des métadonnées stockées sur IPFS
    function mintProperty(address to, string memory tokenURI) external onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

    /// @notice Vérifie si un joueur possède une propriété spécifique
    function ownerOfProperty(uint256 tokenId) external view returns (address) {
        return ownerOf(tokenId);
    }
}
