// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

import "./MonopolyProperty.sol";
import "./MonopolyToken.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MonopolyGame is ReentrancyGuard {
    MonopolyProperty public propertyContract;
    MonopolyToken public tokenContract;

    mapping(address => uint256) public lastTransactionTime;
    mapping(address => uint256) public propertyCount;

    uint256 public constant MAX_PROPERTIES = 4;
    uint256 public constant TRANSACTION_COOLDOWN = 5 minutes;
    uint256 public constant PROPERTY_PRICE = 100 * 10**18;

    event PropertyBought(address indexed buyer, uint256 tokenId, uint256 price);
    event PropertyTransferred(address indexed from, address indexed to, uint256 tokenId);

    constructor(address _propertyContract, address _tokenContract) {
        propertyContract = MonopolyProperty(_propertyContract);
        tokenContract = MonopolyToken(_tokenContract);
    }

    function setPropertyContract(address _propertyContract) external {
        propertyContract = MonopolyProperty(_propertyContract);
    }

    function setTokenContract(address _tokenContract) external {
        tokenContract = MonopolyToken(_tokenContract);
    }

    function buyProperty(uint256 tokenId) external nonReentrant {
        require(propertyContract.ownerOfProperty(tokenId) == address(0), "Property already owned");
        require(propertyCount[msg.sender] < MAX_PROPERTIES, "Ownership limit reached");
        require(block.timestamp >= lastTransactionTime[msg.sender] + TRANSACTION_COOLDOWN, "Cooldown active");

        require(tokenContract.allowance(msg.sender, address(this)) >= PROPERTY_PRICE, "Token allowance too low");
        bool success = tokenContract.transferFrom(msg.sender, address(this), PROPERTY_PRICE);
        require(success, "Token transfer failed");

        try propertyContract.mintProperty(msg.sender, "ipfs://metadata_hash") {
            propertyCount[msg.sender]++;
            lastTransactionTime[msg.sender] = block.timestamp;
            emit PropertyBought(msg.sender, tokenId, PROPERTY_PRICE);
        } catch {
            revert("Minting property failed");
        }
    }

    function transferProperty(address to, uint256 tokenId) external nonReentrant {
        require(propertyContract.ownerOfProperty(tokenId) == msg.sender, "Not the owner");
        require(propertyCount[to] < MAX_PROPERTIES, "Recipient at max property limit");
        require(block.timestamp >= lastTransactionTime[msg.sender] + TRANSACTION_COOLDOWN, "Cooldown active");

        propertyContract.safeTransferFrom(msg.sender, to, tokenId);
        propertyCount[msg.sender]--;
        propertyCount[to]++;
        lastTransactionTime[msg.sender] = block.timestamp;

        emit PropertyTransferred(msg.sender, to, tokenId);
    }
}
