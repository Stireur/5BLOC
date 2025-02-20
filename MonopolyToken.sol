// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonopolyToken is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18;
    address public gameContract;

    constructor() ERC20("MonopolyToken", "MPT") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    modifier onlyGameContract() {
        require(msg.sender == gameContract, "Only game contract can call this");
        _;
    }

    function setGameContract(address _gameContract) external onlyOwner {
        gameContract = _gameContract;
    }

    function distributeTokens(address to, uint256 amount) external onlyOwner {
        require(amount > 0, "Montant invalide");
        _transfer(owner(), to, amount);
    }

    function transferFromGame(address from, address to, uint256 amount) external onlyGameContract {
        _transfer(from, to, amount);
    }
}
